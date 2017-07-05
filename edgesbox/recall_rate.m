% Demo for Edge Boxes (please see readme.txt first).
close all;
clear
dbstop if error;
%% load pre-trained edge detection model and set opts (see edgesDemo.m)
model=load('models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;
addpath(genpath('C:\Program Files\MATLAB\R2012b\toolbox\toolbox-master\'));
%% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .85;     % step size of sliding window search0.65
opts.beta  = .8;     % nms threshold for object proposals0.75
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 200;  % max number of boxes to detect 1e4

%% detect Edge Box bounding box proposals (see edgeBoxes.m)
I = imread('coke0164.jpg');%('carscale0160.jpg');%('Tiger0291.jpg');%('coke0164.jpg');%%%('lemming0373.jpg');%('singer2.jpg');%('couple.jpg');%('basketball1.jpg');%('lemming0373.jpg');%('motorrolling0001.jpg');%('0066.jpg')%
gt=[111	98	25	101];%jogging 0001
gt=[179	79	31	116];%jogging 0066
gt = [67,248,54,90]; %lemming
gt=[312,200,48,80];%coke0164
% gt =[120	164	96	52];%carscale
%gt=[206,100,76,84]; %tiger
%  gt=[198,214,34,81];%basketball
%  gt=[130	13	24	84];%couple
%  gt=[309,142,66,118];%singer2
 %gt=[117,68,122,125];%motorroling
opts.minBoxArea = 0.7*gt(3)*gt(4);
%opts.maxAspectRatio = 1.0*max(gt(3)/gt(4),gt(4)./gt(3));
opts.maxBoxArea = 1.42*gt(3)*gt(4);
opts.aspectRatio = gt(3)/gt(4);
%% for entire image 

 colorpool=['g','y','m','b','b','b','b','b','b','b','b','b','b','b','b'];

%% for im patch surrounding obj 
model.opts.multiscale=0; model.opts.sharpen=0; model.opts.nThreads=4;
  opts.alpha = .85;     % step size of sliding window search0.65
  opts.beta  = .8;   
  opts.minScore = .005;  % min score of boxes to detect
  
  opts.minBoxArea = 0.5*gt(3)*gt(4);
%opts.maxAspectRatio = 1.0*max(gt(3)/gt(4),gt(4)./gt(3));
 opts.maxBoxArea = 2*gt(3)*gt(4);
 opts.aspectRatio = gt(3)/gt(4);
  factor= 2.5%1.2^4;
  [patch,diff] =  my_get_subwindow(I,floor(gt([2,1])+gt([4,3])./2),factor*gt([4,3]));
  bbs=edgeBoxes(patch,model,opts);
  bbs2(:,1) = bbs(:,1);  %gt(1) - (factor-1)./2*gt(3)+
  bbs2(:,2) = bbs(:,2);%gt(2) -(factor-1)./2*gt(4)+
  bbs2(:,3) = bbs(:,3); 
  bbs2(:,4) = bbs(:,4);%
  [pm]=size(patch,1);
  [pn]=size(patch,2);
  %diff = factor*gt([3,4])-[pn pm];
  gt2 =[(factor-1)./2* gt([3,4])-diff   gt([3,4])];
 
%   figure,imshow(patch,'border','tight','initialmagnification','fit');
%   set (gcf,'Position',[200,200,200+size(patch,2),200+size(patch,1)]);
%   axis normal;
%   rectangle('Position',[gt2(1) gt2(2) gt2(3) gt2(4)],'edgecolor','r');
%     for jj=1:8
% %        figure,imshow(patch,'border','tight','initialmagnification','fit');
% %        set (gcf,'Position',[200,200,200+size(patch,2),200+size(patch,1)]);
% %        axis normal;
%        %rectangle('Position',[gt2(1) gt2(2) gt2(3) gt2(4)],'edgecolor','r');
%        hold on,rectangle('Position',[bbs2(jj,1) bbs2(jj,2) bbs2(jj,3) bbs2(jj,4)],'edgecolor',colorpool(jj));
%     end
recall = zeros(10,1);
ll=0;
for num = 1:8
ll=ll+1;
opts.maxBoxes = num*50;  % max number of boxes to detect 1e4
ind = zeros(200,1);
kk=0;
gt3 = [gt2([1,2]) gt2([1,2])+gt([3,4])];
for ii = 1:size(bbs2,1)
    bb=bbs2(ii,1:4);
    bb=[bb(1) bb(2) bb(3)+bb(1) bb(4)+bb(2)];
    ovlp= boxoverlap(bb,gt3);
    if ovlp>0.7
        kk=kk+1;
        ind(kk)=ii;
    end
end
recall(ll)= numel(nonzeros(ind));
end 
plot(recall)
%     bb=bbs2(ind(jj),1:4);
%     figure,imshow(patch,'border','tight','initialmagnification','fit');
%     set (gcf,'Position',[200,200,200+size(patch,2),200+size(patch,1)]);
%     axis normal;
%     rectangle('Position',[bb(1) bb(2) bb(3) bb(4)],'edgecolor','y');
% end
  
