load('bbs2.mat');
I = imread('coke0160.jpg');%
gt=[278,176,48,80];
 figure,imshow(I,'border','tight','initialmagnification','fit');
%   set (gcf,'Position',[160,300,160+size(patch,2),300+size(patch,1)]);
%   axis normal;
%   rectangle('Position',[gt2(1) gt2(2) gt2(3) gt2(4)],'edgecolor','r');
temppool = {'r','r','r','g','g','g','r','g'}
temppool1 = {'g','g','g','r','r','r','g','g'}
for jj=1:8
  % figure,imshow(I,'border','tight','initialmagnification','fit')
   %set (gcf,'Position',[200,200,200+size(patch,2),200+size(patch,1)]);
   hold on,rectangle('Position',[bbs2(jj,1) bbs2(jj,2) bbs2(jj,3) bbs2(jj,4)],'edgecolor',temppool{jj}); %'b'colorpool(jj)
end
%%
I = imread('coke0164.jpg');%
load('bbs3.mat');
figure,imshow(I,'border','tight','initialmagnification','fit');
gt=[312,200,48,80];%coke0164
 for ii=1:6
    bb = bbs4(ii,:);
    bb1 = [bb(1) bb(2) bb(3) bb(4)]; 
    rectangle('Position',[bb1(1) bb1(2) bb1(3) bb1(4)],'edgecolor','g'); %
 end
