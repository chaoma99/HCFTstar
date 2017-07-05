% Demo for Edge Boxes (please see readme.txt first).
close all;
clear
dbstop if error;
%% load pre-trained edge detection model and set opts (see edgesDemo.m)

model=load('models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

%% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .85;     % step size of sliding window search0.65
opts.beta  = .8;     % nms threshold for object proposals0.75
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 200;  % max number of boxes to detect 1e4

%% detect Edge Box bounding box proposals (see edgeBoxes.m)
I = imread('motorrolling0001.jpg');%('basketball1.jpg');
%gt=[111	98	25	101];%jogging
gt=[198,214,34,81];%basketball
gt=[117,68,122,125];%motorroling
opts.minBoxArea = 0.5*gt(3)*gt(4);
%opts.maxAspectRatio = 1.0*max(gt(3)/gt(4),gt(4)./gt(3));
opts.maxBoxArea = 2*gt(3)*gt(4);
opts.aspectRatio = gt(3)/gt(4);
 bbs=edgeBoxes(I,model,opts);
 bbs1=[];
 bsize = size(bbs,1);
 for ii=1:bsize
     bb=bbs(ii,:);
     square = bb(3)*bb(4);
     if square<2*gt(3)*gt(4)
        bbs1=[bbs1;bb];
     end
 end
 
%% show evaluation results (using pre-defined or interactive boxes)

figure,imshow(I);
rectangle('Position',gt,'edgecolor','r');
colorpool=['g','y','m','b','b','b','b','b','b','b','b','b','b','b','b'];
for ii=1:10
    bb=bbs(ii,:);
    rectangle('Position',[bb(1) bb(2) bb(3) bb(4)],'edgecolor',colorpool(ii));
end
gt1 = [gt(1) gt(2) gt(3)+gt(1) gt(4)+gt(2)];
ind=zeros(200,1);
kk=0;
for ii = 1:size(bbs,1)
    bb=bbs(ii,1:4);
    bb=[bb(1) bb(2) bb(3)+bb(1) bb(4)+bb(2)];
    ovlp= boxoverlap(bb,gt1);
    if ovlp>0.7
        kk=kk+1;
        ind(kk)=ii;
    end
end
for jj=1:numel(nonzeros(ind))
    bb=bbs(ind(jj),1:4);
    figure,imshow(I);
    rectangle('Position',[bb(1) bb(2) bb(3) bb(4)],'edgecolor','y');
end
%% surrounding 
 factor=1.2^4;
  [patch] = get_subwindow(I,floor(gt([2,1])+gt([4,3])./2),factor*gt([4,3]));
  bbs=edgeBoxes(patch,model,opts);
  bbs2(:,1) = gt(1) - (factor-1)./2*gt(3)+bbs(:,1); 
  bbs2(:,2) = gt(2) -(factor-1)./2*gt(4)+bbs(:,2);%
  bbs2(:,3) = bbs(:,3); 
  bbs2(:,4) = bbs(:,4);%
  figure,imshow(I);
   rectangle('Position',[gt(1) gt(2) gt(3) gt(4)],'edgecolor','r');
    for jj=1:10
       hold on,rectangle('Position',[bbs2(jj,1) bbs2(jj,2) bbs2(jj,3) bbs2(jj,4)],'edgecolor',colorpool(jj));
    end
    
    for ii = 1:size(bbs2,1)
    bb=bbs2(ii,1:4);
    bb=[bb(1) bb(2) bb(3)+bb(1) bb(4)+bb(2)];
    ovlp= boxoverlap(bb,gt1);
    if ovlp>0.7
        kk=kk+1;
        ind(kk)=ii;
    end
end
for jj=1:numel(nonzeros(ind))
    bb=bbs2(ind(jj),1:4);
    figure,imshow(I);
    rectangle('Position',[bb(1) bb(2) bb(3) bb(4)],'edgecolor','y');
end
  
