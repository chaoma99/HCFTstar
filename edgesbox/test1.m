close all;
clear
I = imread('lemming0376.jpg');%
  gt = [61,227,57,92];%lemming376
  pos =[326 114];

  figure,imshow(I,'border','tight','initialmagnification','fit');
  hold on,rectangle('Position',[gt(1) gt(2) gt(3) gt(4)],'edgecolor','g','LineWidth',2,'LineStyle','--'); 
  hold on,rectangle('Position',[gt(1)-(1.4-1)*gt(3)./2 gt(2)-(1.4-1)*gt(4)./2 1.4*gt(3) 1.4*gt(4)],'edgecolor','r','LineWidth',2,'LineStyle','--')
  hold on,rectangle('Position',[pos(2)-(3)*gt(3)./2 pos(1)-(3)*gt(4)./2 3*gt(3) 3*gt(4)],'edgecolor','y','LineWidth',2,'LineStyle','--')
  
  [patch,diff] =  my_get_subwindow(I,floor(gt([2,1])+gt([4,3])./2),1.1*gt([4,3]));
  
  figure,imshow(patch,'border','tight','initialmagnification','fit');
  hold on,rectangle('Position',[(1.4-1)*gt(3)./2 (1.4-1)*gt(4)./2 gt(3) gt(4)],'edgecolor','r','LineWidth',2,'LineStyle','-')
%   opts.alpha = .65;     % step size of sliding window search0.65
%   opts.beta  = .75;   
  [patch1,diff] =  my_get_subwindow(I,pos,gt([4,3])+6);
  figure,imshow(patch1,'border','tight','initialmagnification','fit');
  model=load('models/forest/modelBsds'); model=model.model;
  model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;
  opts.minScore = .005;  % min score of boxes to detect
  opts.maxBoxes = 200;  % max number of boxes to detect 1e4
  opts.minBoxArea = 0.3*gt(3)*gt(4);
  opts.maxAspectRatio = 1.5*max(gt(3)/gt(4),gt(4)./gt(3));
  opts.kappa =1.4;
  bbs=edgeBoxes(patch,model,opts); 
      %   figure,imshow(patch1);
  [ind] = proRej(bbs,1.4*gt([3,4]),gt([3,4]));%proposal rejection
  for ii=1:numel(nonzeros(ind))
      bb = bbs(ind(ii),:);
      subpatch = patch(bb(2):bb(2)+bb(4),bb(1):bb(1)+bb(3),:);
      figure,imshow(subpatch,'border','tight','initialmagnification','fit');
  end
  
  
  
  