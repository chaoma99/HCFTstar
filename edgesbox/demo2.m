clear;
close all;
model=load('models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=0; model.opts.nThreads=4;
I = imread('carscale0160.jpg');%
gt = [120 164 96 52];%carscale
load('bbs4.mat');
figure,imshow(I,'border','tight','initialmagnification','fit');
%   set (gcf,'Position',[160,300,160+size(patch,2),300+size(patch,1)]);
%   axis normal;
%   rectangle('Position',[gt2(1) gt2(2) gt2(3) gt2(4)],'edgecolor','r');
temppool = {'r','r','r','g','g','g','r','g'}
temppool1 = {'g','g','g','r','r','r','g','g'}
for jj=1:8
   %figure,imshow(I,'border','tight','initialmagnification','fit')
   %set (gcf,'Position',[200,200,200+size(patch,2),200+size(patch,1)]);
   hold on,rectangle('Position',[bbs2(jj,1) bbs2(jj,2) bbs2(jj,3) bbs2(jj,4)],'edgecolor',temppool1{jj}); %'b'colorpool(jj)
end 
figure,imshow(I,'border','tight','initialmagnification','fit')
hold on,rectangle('Position',[bbs2(1,1) bbs2(1,2) bbs2(1,3) bbs2(1,4)],'edgecolor',temppool1{jj}); %'b'colorpool(jj)

I = imread('carscale0178.jpg');
gt =[123 159 129 61];
figure,imshow(I,'border','tight','initialmagnification','fit');
hold on, rectangle('Position',[gt(1) gt(2) gt(3) gt(4)],'edgecolor','g','linewidth',2); %,

factor = 1.4;
[patch,diff] =  my_get_subwindow(I,floor(gt([2,1])+gt([4,3])./2),factor*gt([4,3]));
opts.alpha = .65;     % step size of sliding window search0.65
opts.beta  = .75;   
opts.minScore = .0005;  % min score of boxes to detect
opts.maxBoxes = 200;  % max number of boxes to detect 1e4
opts.minBoxArea = 0.3*gt(3)*gt(4);
opts.kappa =1.4;
%opts.maxAspectRatio = 1.0*max(gt(3)/gt(4),gt(4)./gt(3));
%opts.maxBoxArea = 1.24*gt(3)*gt(4);
%opts.aspectRatio = gt(3)/gt(4);
bbs=edgeBoxes(patch,model,opts);
[ind] = proRej(bbs,1.4*gt([3,4]),gt([3,4]));%region proposal
for ii=1:length(nonzeros(ind))
bbs2 = bbs(ind(ii),:);
bbs3(:,1) = gt(1) - (factor-1)./2*gt(3)+bbs2(:,1);
bbs3(:,2) = gt(2) - (factor-1)./2*gt(4)+bbs2(:,2);
bbs3(:,3) = bbs2(:,3); 
bbs3(:,4) = bbs2(:,4);%
%figure,imshow(I,'border','tight','initialmagnification','fit');
hold on,rectangle('Position',[bbs3(1,1) bbs3(1,2) bbs3(1,3) bbs3(1,4)],'edgecolor','b');
end



 