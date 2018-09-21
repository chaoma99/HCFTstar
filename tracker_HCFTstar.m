function [positions, time,rect_position] = tracker_HCFTstar(video_path, img_files, pos, target_sz, ...
    padding, lambda, output_sigma_factor, interp_factor, cell_size, show_visualization,config)
%foucs on change samples for  the appearance update 
warning off;
% ================================================================================
% Environment setting
% ================================================================================
indLayers = [37, 28, 19];   % The CNN layers Conv5-4, Conv4-4, and Conv3-4 in VGG Net
nweights  = [1, 0.5, 0.25]; % Weights for combining correlation filter responses
numLayers = length(indLayers);
% Get image size and search window size
im_sz     = size(imread([video_path img_files{1}]));
window_sz = get_search_window(target_sz, im_sz, padding);% floor(2.5*target_sz);%
search_area = prod(target_sz / config.features.cell_size * 2.8);
cell_selection_thresh = 0.75^2;
filter_max_area =50^2;
if search_area < cell_selection_thresh * filter_max_area  
    config.features.cell_size = min(4, max(1, round(sqrt(prod(target_sz * 2.8)/...
        (cell_selection_thresh * filter_max_area)))));
end
cell_size=    config.features.cell_size;
app_sz = target_sz+2*3;
config.window_sz=window_sz;
config.app_sz=app_sz;
[ratio1 ,ratio2]=deal(window_sz(1)/target_sz(1) , window_sz(2)/target_sz(2));
%addpath('edgesbox');

model=load('edgesbox/models/forest/modelBsds'); 
model=model.model;
model.opts.multiscale=0; 
model.opts.sharpen=0; 
model.opts.nThreads=4;
opts = edgeBoxes;
opts.alpha = 0.85;
opts.beta=0.8;
opts.maxBoxes=200;
opts.minScore = 0.0005;
opts.kappa =1.4;
% Compute the sigma for the Gaussian function label
output_sigma = sqrt(prod(target_sz)) * output_sigma_factor / cell_size;
current_target_sz= target_sz;
current_window_sz = window_sz;
%create regression labels, gaussian shaped, with a bandwidth
%proportional to target size    d=bsxfun(@times,c,[1 2]);

l1_patch_num = floor(window_sz/ cell_size);
% Pre-compute the Fourier Transform of the Gaussian function label
yf = fft2(gaussian_shaped_labels(output_sigma, l1_patch_num));
app_yf=fft2(gaussian_shaped_labels(output_sigma, floor(app_sz / cell_size)));
% Pre-compute and cache the cosine window (for avoiding boundary discontinuity)
cos_window = hann(size(yf,1)) * hann(size(yf,2))';
cos_window1 = ones(size(app_yf,1),size(app_yf,2));
% Create video interface for visualization
if(show_visualization)
    update_visualization = show_video(img_files, video_path);
end

% Initialize variables for calculating FPS and distance precision
time      = 0;
positions = zeros(numel(img_files), 2);
rect_position = zeros(numel(img_files), 4);
nweights  = reshape(nweights,1,1,[]);
max_response=0;
% Note: variables ending with 'f' are in the Fourier domain.
model_xf     = cell(1, numLayers);
model_alphaf = cell(1, numLayers);
app_xf=0;
app_alphaf=0;
% ================================================================================
% Start tracking
% ================================================================================
for frame = 1:numel(img_files),
    im = imread([video_path img_files{frame}]); % Load the image at the current frame
    org_im = im;
    if ismatrix(im)
        im = cat(3, im, im, im);
    end
    
    tic();
    % ================================================================================
    % Predicting the object position from the learned object model
    % ================================================================================
    if frame > 1
        % Extracting hierarchical convolutional features
        feat = extractFeature(im, pos, window_sz, cos_window, indLayers);
        % Predict position
        [pos,~]  = predictPosition(feat, pos, indLayers, nweights, cell_size, l1_patch_num, ...
            model_xf, model_alphaf);
        feat1 = extractHOGFeature(rgb2gray(im), pos, app_sz,cos_window1, config);
        zf = fft2(feat1);
        kzf=gaussian_correlation(zf, app_xf, config.kernel_sigma);
        response = fftshift(real(ifft2(app_alphaf.*kzf)));
        max_response = max(response(:));
        % motion response
        patch = get_subwindow(im, pos, current_window_sz);
        patch = imresize(patch,config.window_sz,'bilinear');
        % Extracting hierarchical convolutional features
        feat2  = get_hog_features(patch, config,cos_window);
        %feat2 = extractFeature1(rgb2gray(im), pos, current_window_sz,cos_window, config);
        zf = fft2(feat2);
        kzf=gaussian_correlation(zf, scale_model.xf, config.kernel_sigma);
        response = fftshift(real(ifft2(scale_model.alphaf.*kzf)));
        motion_response = max(response(:));
        if  max_response< config.motion_thresh
               patch1 = get_subwindow(im,pos,window_sz); 
               if size(patch1,1)>1&&size(patch1,2)>1
                   opts.minBoxArea= 0.8*target_sz(1)*target_sz(2);
                   opts.maxBoxArea=1.2*target_sz(1)*target_sz(2);
                   opts.maxAspectRatio= 1.5*max(target_sz(1)/target_sz(2),target_sz(2)/target_sz(1));
                   opts.aspectRatio = target_sz(2)/target_sz(1);
                   bbs= myedgeBoxes(patch1,model,opts);
                   bbs1 = [bbs(:,1)+bbs(:,3)./2 bbs(:,2)+bbs(:,4)./2  bbs(:,3) bbs(:,4)];
                   [ind,maxProb] = prorej(single(patch1),bbs1,svm_model);                 
                   % svm_model.lastProb = maxProb;
                   num = floor(size(bbs,1)./2);
                   bbs2 =  bbs(ind(1:num),:);
                   [pos,~,max_response] = rp_detect(im,pos,window_sz,bbs2,target_sz,app_sz,app_model,config,max_response,current_target_sz,0);
               end
        else
            win_sz = floor(1.4*current_target_sz);
            patch1 = get_subwindow(im,pos,win_sz);
            if size(patch1,3)<2, patch1 = cat(3,patch1,patch1,patch1);   end
            opts1.minBoxArea = 0.3*current_target_sz(1)*current_target_sz(2);                            
            opts1.maxAspectRatio = 1.5*max(current_target_sz(1)/current_target_sz(2), current_target_sz(2)/current_target_sz(1));
            bbs = edgeBoxes(patch1,model,opts1);
            [ind] = proRej(bbs,win_sz([2,1]), current_target_sz([2,1]));
            if (nonzeros(ind))
                responind = zeros(numel(nonzeros(ind)),1);
                for kk=1:numel(nonzeros(ind))
                    bb=bbs(ind(kk),:);
                    proposal_sz = floor([ratio1 ratio2].*[bb(4) bb(3)]);                  
                    proposal_loc = floor(pos - win_sz./2+[bb(2) bb(1)]+[bb(4)./2 bb(3)./2]);
                    patch2 = get_subwindow(im,proposal_loc,proposal_sz);                       
              %patch2 = patch1(bb(2):1:bb(2)+bb(4),bb(1):1:(bb(1)+bb(3)),:);                
                    patch2 = imresize(patch2,config.window_sz);                
                    feat1 =  get_hog_features(patch2,config,cos_window);    
                    model_alpha = real(ifft2(scale_model.alphaf));
                    kf = gaussian_correlation(fft2(feat1), scale_model.xf, config.kernel_sigma);             
                    response1 = (model_alpha .* ifft2(kf));
                    responind(kk) = sum(response1(:));
                end
                if motion_response<max(responind(:))                
                   [~,indx] = max(responind(:)); % most index whose response bigger than v
                   bb = bbs(ind(indx),:);      
                    if  bb(4)*bb(3)< 1.2*(prod(current_target_sz)) &&bb(4)*bb(3)>0.7*(prod(current_target_sz))
                      pos2= (pos - win_sz./2)+ [bb(2) bb(1)];
                      pos3 = pos2 + ([bb(4)./2 bb(3)./2]); % patch3= get_subwindow(im,pos3,window_sz);
                      %pos = pos+floor( 0.1*(pos3-pos));                     
                      current_target_sz = current_target_sz+(0.6*([bb(4) bb(3)]- current_target_sz));
                    end
                end
           end
          end   
        
    end
    
    % ================================================================================
    % Learning correlation filters over hierarchical convolutional features
    % ================================================================================
    % Extracting hierarchical convolutional features
    current_window_sz= current_target_sz.*[ratio1 ratio2]; % for scale estimation
    patch = get_subwindow((org_im), pos, current_window_sz);
    patch = imresize(patch,config.window_sz);
    sxf = fft2(get_hog_features(patch, config,cos_window)); %feat  = get_hog_features(patch, config,cos_window);
    skf = gaussian_correlation(sxf, sxf, config.kernel_sigma);
    new_alphaf_num = yf .* skf;
    new_alphaf_den = skf .* (skf + lambda);
    if frame == 1,  %first frame, train with a single image
      alphaf_num = new_alphaf_num;
      alphaf_den = new_alphaf_den;  
      scale_model.xf = sxf;
      svm_model = online_svm_train(im,pos,window_sz,target_sz,opts,model); 
    else
        scale_model.xf = (1 - interp_factor) * scale_model.xf + interp_factor * sxf; 
        alphaf_num = (1 - interp_factor) * alphaf_num + interp_factor * new_alphaf_num;
        alphaf_den = (1 - interp_factor) * alphaf_den + interp_factor * new_alphaf_den; 
            
         if max_response>config.appearance_thresh %0.38
            svm_model = online_svm_update(im,pos,window_sz,target_sz,opts,model,svm_model);
         end    
    end
     scale_model.alphaf = alphaf_num./alphaf_den; 
     
    feat  = extractFeature(im, pos, window_sz, cos_window, indLayers);
    % Model update
    [model_xf, model_alphaf] = updateModel(feat, yf, interp_factor, lambda, frame, ...
        model_xf, model_alphaf);
    
    feat1 = extractHOGFeature(rgb2gray(im), pos, app_sz, cos_window1, config);
    [app_xf, app_alphaf] = updateApp(feat1, app_yf, interp_factor, lambda, frame, ...
        app_xf, app_alphaf,max_response,config);
    app_model.xf = app_xf;
    app_model.alphaf = app_alphaf;
    % ================================================================================
    % Save predicted position and timing
    % ================================================================================
    positions(frame,:) = pos;
    rect_position(frame,:) = [pos([2,1]) - floor(current_target_sz([2,1])/2), current_target_sz([2,1])];
    time = time + toc();
    
    % Visualization
    if show_visualization,
        box = [pos([2,1]) - current_target_sz([2,1])/2, current_target_sz([2,1])];
        stop = update_visualization(frame, box);
        if stop, break, end  %user pressed Esc, stop early
        drawnow
        % 			pause(0.05)  % uncomment to run slower
    end
end

end


function [pos,max_response] = predictPosition(feat, pos, indLayers, nweights, cell_size, l1_patch_num, ...
    model_xf, model_alphaf)

% ================================================================================
% Compute correlation filter responses at each layer
% ================================================================================
res_layer = zeros([l1_patch_num, length(indLayers)]);

for ii = 1 : length(indLayers)
    zf = fft2(feat{ii});
    kzf=sum(zf .* conj(model_xf{ii}), 3) / numel(zf);    
    tt= real(fftshift(ifft2(model_alphaf{ii} .* kzf)));  %equation for fast detection
    res_layer(:,:,ii)=tt/max(tt(:));
end

% Combine responses from multiple layers (see Eqn. 5)
response = sum(bsxfun(@times, res_layer, nweights), 3);

% ================================================================================
% Find target location
% ================================================================================
% Target location is at the maximum response. we must take into
% account the fact that, if the target doesn't move, the peak
% will appear at the top-left corner, not at the center (this is
% discussed in the KCF paper). The responses wrap around cyclically.
max_response = max(response(:));
[vert_delta, horiz_delta] = find(response == max(response(:)), 1);
vert_delta  = vert_delta  - floor(size(zf,1)/2);
horiz_delta = horiz_delta - floor(size(zf,2)/2);

% Map the position to the image space
pos = pos + cell_size * [vert_delta - 1, horiz_delta - 1];


end


function [model_xf, model_alphaf] = updateModel(feat, yf, interp_factor, lambda, frame, ...
    model_xf, model_alphaf)

numLayers = length(feat);

% ================================================================================
% Initialization
% ================================================================================
xf       = cell(1, numLayers);
alphaf   = cell(1, numLayers);

% ================================================================================
% Model update
% ================================================================================
for ii=1 : numLayers
    xf{ii} = fft2(feat{ii});
    kf = sum(xf{ii} .* conj(xf{ii}), 3) / numel(xf{ii});
    alphaf{ii} = yf./ (kf+ lambda);   % Fast training
end
% Model initialization or update
if frame == 1,  % First frame, train with a single image
    for ii=1:numLayers
        model_alphaf{ii} = alphaf{ii};
        model_xf{ii} = xf{ii};
    end
else   
    % Online model update using learning rate interp_factor
    for ii=1:numLayers
        model_alphaf{ii} = (1 - interp_factor) * model_alphaf{ii} + interp_factor * alphaf{ii};
        model_xf{ii}     = (1 - interp_factor) * model_xf{ii}     + interp_factor * xf{ii};
    end
end
end

function [app_xf, app_alphaf] = updateApp(feat, yf, interp_factor, lambda, frame, ...
    app_xf, app_alphaf,max_response,config)

    xf = fft2(feat);
    kf = gaussian_correlation(xf, xf, config.kernel_sigma);
    %kf = sum(xf .* conj(xf), 3) / numel(xf);
    alphaf = yf./ (kf+ lambda);   % Fast training
% Model initialization or update
if frame == 1,  % First frame, train with a single image
        app_alphaf = alphaf;
        app_xf = xf;  
else
    if max_response>config.appearance_thresh
    % Online model update using learning rate interp_factor  
        app_alphaf = (1 - interp_factor) * app_alphaf + interp_factor * alphaf;
        app_xf    = (1 - interp_factor) * app_xf    + interp_factor * xf;
    end
end


end

function feat  = extractFeature(im, pos, window_sz, cos_window, indLayers)

% Get the search window from previous detection
patch = get_subwindow(im, pos, window_sz);
% Extracting hierarchical convolutional features
feat  = get_features(patch, cos_window, indLayers);

end

function feat  = extractHOGFeature(im, pos, window_sz, cos_window, config)

% Get the search window from previous detection
patch = get_subwindow(im, pos, window_sz);
% Extracting hierarchical convolutional features
feat  = get_hog_features(patch, config,cos_window);

end
