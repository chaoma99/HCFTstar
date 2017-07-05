% Demo for Edge Boxes (please see readme.txt first).
close all;
clear
dbstop if error;
%% load pre-trained edge detection model and set opts (see edgesDemo.m)
model=load('models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;
addpath(genpath('C:\Program Files\MATLAB\R2012b\toolbox\toolbox-master'));
addpath(genpath('E:\tracking\Diagnose\'));
%% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .85;     % step size of sliding window search0.65
opts.beta  = .8;     % nms threshold for object proposals0.75
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 200;  % max number of boxes to detect 1e4

%% detect Edge Box bounding box proposals (see edgeBoxes.m)
I = imread('lemming0376.jpg');%('coke0160.jpg');%('singer2.jpg');%('couple.jpg');%('basketball1.jpg');%('lemming0373.jpg');%('motorrolling0001.jpg');%('0066.jpg')%
gt=[111	98	25	101];%jogging 0001
gt=[179	79	31	116];%jogging 0066
gt = [67,248,54,90]; %lemming370
gt = [61,227,57,92];%lemming376
% gt=[312,200,48,80];%coke0164
% gt=[278,176,48,80];%coke0160
%  gt=[198,214,34,81];%basketball
%  gt=[130	13	24	84];%couple
%  gt=[309,142,66,118];%singer2
pos =[326 114];
 %gt=[117,68,122,125];%motorroling
opts.minBoxArea = 0.7*gt(3)*gt(4);
%opts.maxAspectRatio = 1.0*max(gt(3)/gt(4),gt(4)./gt(3));
opts.maxBoxArea = 1.42*gt(3)*gt(4);
opts.aspectRatio = gt(3)/gt(4);
%% for entire image 
 colorpool=['y','y','y','y','y','y','y','y','y','y','y','y','y','y','y'];
%% for im patch surrounding obj 
model.opts.multiscale=0; model.opts.sharpen=0; model.opts.nThreads=4;
  opts.alpha = .85;     % step size of sliding window search0.65
  opts.beta  = .8;   
  opts.minScore = .005;  % min score of boxes to detect
  opts.maxBoxes = 200;  % max number of boxes to detect 1e4
  opts.minBoxArea = 0.8*gt(3)*gt(4);
%opts.maxAspectRatio = 1.0*max(gt(3)/gt(4),gt(4)./gt(3));
 opts.maxBoxArea = 1.2*gt(3)*gt(4);
 opts.aspectRatio = gt(3)/gt(4);
  factor= 2.8%1.2^4;
  [patch,diff] =  my_get_subwindow(I,pos,factor*gt([4,3])); %floor(gt([2,1])+gt([4,3])./2)
  bbs=myedgeBoxes(patch,model,opts);
  
  bbs2(:,1) = bbs(:,1)+pos(2) - (factor)./2*gt(3);
  bbs2(:,2) = bbs(:,2)+pos(1) -(factor)./2*gt(4);
  bbs2(:,3) = bbs(:,3); 
  bbs2(:,4) = bbs(:,4);%
  bbs2(:,5) = bbs(:,5);
  [pm]=size(patch,1);
  [pn]=size(patch,2);
  %diff = factor*gt([3,4])-[pn pm];
  gt2 =[(factor-1)./2* gt([3,4])-diff   gt([3,4])];
 
  figure,imshow(I,'border','tight','initialmagnification','fit');
  hold on,rectangle('Position',[pos(2)-gt(3)./2 pos(1)-gt(4)./2 gt(3) gt(4)],'edgecolor','g','LineWidth',2,'LineStyle','--'); 
  hold on,rectangle('Position',[pos(2)-factor*gt(3)./2 pos(1)-factor*gt(4)./2 factor*gt(3) factor*gt(4)],'edgecolor','y','LineWidth',2,'LineStyle','--')
  set (gcf,'Position',[100,100,100+size(I,2),100+size(I,1)]);
  axis normal;
%  % E=edgesDetect(I,model)
  figure,imshow(I,'border','tight','initialmagnification','fit');
  rectangle('Position',[gt(1) gt(2) gt(3) gt(4)],'edgecolor','r');
  for jj=1:8
   % figure,imshow(patch)
   hold on,rectangle('Position',[bbs2(jj,1) bbs2(jj,2) bbs2(jj,3) bbs2(jj,4)],'edgecolor',colorpool(jj));
  end
  len = size(bbs2,1);
objmap = computeObjectnessMap(I,bbs2(1:floor(len./3),:));
% figure,imagesc(objmap)%imshow(mat2gray(objmap));
% hold on,rectangle('Position',[gt(1) gt(2) gt(3) gt(4)],'edgecolor','r','LineWidth',2,'LineStyle','--');  
% %hold on,rectangle('Position',[pos(2)-gt(3)./2 pos(1)-gt(4)./2 gt(3) gt(4)],'edgecolor','g','LineWidth',2,'LineStyle','--'); 
% %hold on,rectangle('Position',[pos(2)-factor*gt(3)./2 pos(1)-factor*gt(4)./2 factor*gt(3) factor*gt(4)],'edgecolor','y','LineWidth',2,'LineStyle','--');    
%% train stage
I1 = imread('lemming0001.jpg');
gt = [40,199,61,103];
[patch,diff] =  my_get_subwindow(I1,floor(gt([2,1])+gt([4,3])./2),factor*gt([4,3]));
bbs3=myedgeBoxes(patch,model,opts);
tmplPos=[];
tmplNeg=[];
gt2 = [(factor-1)./2* gt([3,4])-diff   gt([3,4])];
gt3 = [gt2([1,2]) gt2([1,2])+gt([3,4])];
for ii = 1:size(bbs3,1)
    bb=bbs3(ii,1:4);
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
%  for ii = 1:8
%     tmpl = tmplPos(ii,:);      
%     subpatch = get_subwindow(patch,tmpl([2,1]),tmpl([4,3]));
%     figure,imshow(subpatch,'border','tight','initialmagnification','fit');
%  end
 config;
 seq.opt = opt;
 svm_model = train_onlineSVM(single(patch),tmplPos,tmplNeg,seq);
%% test image
 I3 = imread('lemming0376.jpg');%('coke0164.jpg');%('singer2.jpg');%('couple.jpg');%('basketball1.jpg');%('lemming0373.jpg');%('motorrolling0001.jpg');%('0066.jpg')%
configGlobalParam;
gt = [61,227,57,92];%lemming376
 [patch,diff] =  my_get_subwindow(I,pos,factor*gt([4,3]));
 %floor(gt([2,1])+gt([4,3])./2)
 bbs=myedgeBoxes(patch,model,opts);
 tmpl=zeros(size(bbs,1),4);
 for ii=1:size(bbs,1)
     bb=bbs(ii,:);   
     temp = ([bb(1)+bb(3)./2 bb(2)+bb(4)./2 bb(3) bb(4)]);
     tmpl(ii,:)=temp;
 end
 tmpl = double(tmpl);
 [feat, seq.opt] = globalParam.FeatureExtractor(single(patch), tmpl, seq.opt);
 prob    = globalParam.ObservationModelTest(feat, svm_model); 
 [re_prob,ind]=sort(prob,'descend');
 for ii=1:size(bbs,1)
  bbs2(ii,1) = bbs(ind(ii),1)+pos(2)-factor*gt(3)./2;
  bbs2(ii,2) = bbs(ind(ii),2)+pos(1)-factor*gt(4)./2;
  bbs2(ii,3) = bbs(ind(ii),3); 
  bbs2(ii,4) = bbs(ind(ii),4);%
  bbs2(ii,5) = bbs(ii,5); %score unchanged, but [x,y,w,h] changed
 end
  figure,imshow(I3,'border','tight','initialmagnification','fit');
  hold on,rectangle('Position',[pos(2)-gt(3)./2 pos(1)-gt(4)./2 gt(3) gt(4)],'edgecolor','g','LineWidth',2,'LineStyle','--'); 
  hold on,rectangle('Position',[pos(2)-factor*gt(3)./2 pos(1)-factor*gt(4)./2 factor*gt(3) factor*gt(4)],'edgecolor','y','LineWidth',2,'LineStyle','--');
  set (gcf,'Position',[100,100,100+size(I,2),100+size(I,1)]);
  axis normal;
  figure,imshow(I3,'border','tight','initialmagnification','fit');
  rectangle('Position',[gt(1) gt(2) gt(3) gt(4)],'edgecolor','r');
  for jj=1:8
       % figure,imshow(patch)
       hold on,rectangle('Position',[bbs2(jj,1) bbs2(jj,2) bbs2(jj,3) bbs2(jj,4)],'edgecolor',colorpool(jj));
  end
 hold on,rectangle('Position',[gt(1)-(1.4-1)./2*gt(3) gt(2)-(1.4-1)./2*gt(4) 1.4*gt(3) 1.4*gt(4)],'edgecolor','g','LineWidth',2,'LineStyle','--')
len = size(bbs2,1);
objmap = computeObjectnessMap(I3,bbs2(1:floor(len./3),:));
%figure,imagesc(objmap);%imshow(mat2gray(objmap));
% hold on,rectangle('Position',[gt(1) gt(2) gt(3) gt(4)],'edgecolor','r','LineWidth',2,'LineStyle','--');  
% hold on,rectangle('Position',[pos(2)-gt(3)./2 pos(1)-gt(4)./2 gt(3) gt(4)],'edgecolor','g','LineWidth',2,'LineStyle','--'); 
% hold on,rectangle('Position',[pos(2)-factor*gt(3)./2 pos(1)-factor*gt(4)./2 factor*gt(3) factor*gt(4)],'edgecolor','y','LineWidth',2,'LineStyle','--');   
