function [ind] = proRej(bbs,win_sz,target_sz)
%bbs  = bbs(1:200,:);
gt = floor([win_sz(1)./2-target_sz(1)./2, win_sz(2)./2-target_sz(2)./2, ...
    win_sz(1)./2+target_sz(1)./2, win_sz(2)./2+target_sz(2)./2]);
ind=zeros(200,1);
jj=0;
for ii = 1:size(bbs,1)
    bb = bbs(ii,:);
    bb = [bb(1) bb(2) bb(1)+bb(3) bb(2)+bb(4)];
    minX = max(bb(1),gt(1));
    minY = (max(bb(2), gt(2)));
    maxX = (min(bb(3), gt(3)));
    maxY = (min(bb(4), gt(4)));
  
    ovlp = max(maxX- minX,0).*max(maxY - minY, 0);
     iou = ovlp./(prod(bb(3:4)-bb(1:2)) + prod(gt(3:4)-gt(1:2))-ovlp);
     %ind(ii)=iou;
     if iou >=0.6 && iou<=0.9
         jj=jj+1;
         ind(jj)=ii;       
        end
end