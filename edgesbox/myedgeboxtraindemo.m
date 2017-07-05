% Demo for Edge Boxes (please see readme.txt first).
%close all;
clear
dbstop if error;
%% load pre-trained edge detection model and set opts (see edgesDemo.m)
model=load('models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;
% addpath(genpath('C:\Program Files\MATLAB\R2012b\toolbox\toolbox-master'));
% addpath(genpath('C:\Users\carrierlxk\Desktop\RNN��LSTM\codes\Diagnose\'));
%% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .85;     % step size of sliding window search0.65
opts.beta  = .8;     % nms threshold for object proposals0.75
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 200;  % max number of boxes to detect 1e4

%% detect Edge Box bounding box proposals (see edgeBoxes.m)
I = imread('peppers.png');%('coke0160.jpg');% ('lemming0370.jpg');%('singer2.jpg');%('couple.jpg');%('basketball1.jpg');%('lemming0373.jpg');%('motorrolling0001.jpg');%('0066.jpg')%
gt=[111	98	25	101];%jogging 0001
gt=[179	79	31	116];%jogging 0066
gt = [67,248,54,90]; %lemming
% gt=[312,200,48,80];%coke0164
gt=[278,176,48,80];%coke0160
%  gt=[198,214,34,81];%basketball
%  gt=[130	13	24	84];%couple
%  gt=[309,142,66,118];%singer2
 %gt=[117,68,122,125];%motorroling
 gt = [120 164 96 52];%carscale
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
  opts.maxBoxes = 200;  % max number of boxes to detect 1e4
  opts.minBoxArea = 0.7*gt(3)*gt(4);
%opts.maxAspectRatio = 1.0*max(gt(3)/gt(4),gt(4)./gt(3));
  opts.maxBoxArea = 1.24*gt(3)*gt(4);
  opts.aspectRatio = gt(3)/gt(4);
  factor= 3%1.2^4;
  [patch,diff] =  my_get_subwindow(I,floor(gt([2,1])+gt([4,3])./2),factor*gt([4,3]));
  bbs=myedgeBoxes(patch,model,opts);
  
  bbs2(:,1) = gt(1) - (factor-1)./2*gt(3)+bbs(:,1);
  bbs2(:,2) = gt(2) - (factor-1)./2*gt(4)+bbs(:,2);
  bbs2(:,3) = bbs(:,3); 
  bbs2(:,4) = bbs(:,4);%
  [pm]=size(patch,1);
  [pn]=size(patch,2);
  %diff = factor*gt([3,4])-[pn pm];
  gt2 =[(factor-1)./2* gt([3,4])-diff   gt([3,4])];
%  
  figure,imshow(I,'border','tight','initialmagnification','fit');
%   set (gcf,'Position',[160,300,160+size(patch,2),300+size(patch,1)]);
%   axis normal;
%   rectangle('Position',[gt2(1) gt2(2) gt2(3) gt2(4)],'edgecolor','r');
temppool = {'r','r','r','g','g','g','r','g'}
temppool1 = {'g','g','g','r','r','r','g','g'}
    for jj=1:8
       figure,imshow(I,'border','tight','initialmagnification','fit')
       %set (gcf,'Position',[200,200,200+size(patch,2),200+size(patch,1)]);
       hold on,rectangle('Position',[bbs2(jj,1) bbs2(jj,2) bbs2(jj,3) bbs2(jj,4)],'edgecolor',temppool1{jj}); %'b'colorpool(jj)
    end


tmplPos=[];
tmplNeg=[];
gt3 = [gt2([1,2]) gt2([1,2])+gt([3,4])];
for ii = 1:size(bbs,1)
    bb=bbs(ii,1:4);
    bb1=[bb(1) bb(2) bb(3)+bb(1) bb(4)+bb(2)];
    ovlp= boxoverlap(bb1,gt3);
    if ovlp>0.5
       temp=([bb(1)+bb(3)./2 bb(2)+bb(4)./2 bb(3) bb(4)]);
       tmplPos=[tmplPos;temp];
    else 
       temp = ([bb(1)+bb(3)./2 bb(2)+bb(4)./2 bb(3) bb(4)]);
       tmplNeg=[tmplNeg;temp];
    end
end
 tmplPos = double(tmplPos);
 tmplNeg = double(tmplNeg);
%  config;
%  seq.opt = opt;
 svm_model = train_onlineSVM(single(patch),tmplPos,tmplNeg,seq);
 %% test image
 I = imread('coke0164.jpg');%('lemming0373.jpg');%('singer2.jpg');%('couple.jpg');%('basketball1.jpg');%('lemming0373.jpg');%('motorrolling0001.jpg');%('0066.jpg')%
 configGlobalParam;
 gt=[312,200,48,80];%coke0164
 [patch,diff] =  my_get_subwindow(I,floor(gt([2,1])+gt([4,3])./2),factor*gt([4,3]));
 bbs3=myedgeBoxes(patch,model,opts);
 tmpl=zeros(size(bbs3,1),4);
 for ii=1:size(bbs3,1)
     bb=bbs3(ii,:);   
     temp = ([bb(1)+bb(3)./2 bb(2)+bb(4)./2 bb(3) bb(4)]);
     tmpl(ii,:)=temp;
 end
 tmpl = double(tmpl);
 [feat, seq.opt] = globalParam.FeatureExtractor(single(patch), tmpl, seq.opt);
 prob    = globalParam.ObservationModelTest(feat, svm_model); 
 [re_prob,ind]=sort(prob,'descend');
 figure,imshow(I,'border','tight','initialmagnification','fit');
%  set (gcf,'Position',[200,200,200+size(patch,2),200+size(patch,1)]);
%  axis normal;
% rectangle('Position',[gt2(1) gt2(2) gt2(3) gt2(4)],'edgecolor','r');
 colorpool=['g','y','y','b','b','b','b','b','b','b','b','b','b','b','b']; 
% bbs4(:,[1,2]) = gt([1,2]) - (factor-1)./2*gt([3,4])+bbs3(:,[1,2]);
 bbs4(:,1) = gt(1) - (factor-1)./2*gt(3)+bbs3(:,1);
 bbs4(:,2) = gt(2) - (factor-1)./2*gt(4)+bbs3(:,2);
 bbs4(:,3) = bbs3(:,3);
 bbs4(:,4) = bbs3(:,4);
 for ii=1:6
    bb = bbs4(ind(ii),:);
    bb1 = [bb(1) bb(2) bb(3) bb(4)]; 
    rectangle('Position',[bb1(1) bb1(2) bb1(3) bb1(4)],'edgecolor','g'); %
 end
  
