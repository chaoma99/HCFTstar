function [out,diff] = my_get_subwindow(im, pos, sz)
%GET_SUBWINDOW Obtain sub-window from image, with replication-padding.
%   Returns sub-window of image IM centered at POS ([y, x] coordinates),
%   with size SZ ([height, width]). If any pixels are outside of the image,
%   they will replicate the values at the borders.
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/

	if isscalar(sz),  %square sub-window
		sz = [sz, sz];
    end
	h=size(im,1);
    w = size(im,2);
   
    xs = floor(pos(2)) + (1:sz(2)) - floor(sz(2)/2);
    ys = floor(pos(1)) + (1:sz(1)) - floor(sz(1)/2);
    
%     xs = clamp(xs,1,size(im,2));
%     ys = clamp(ys,1,size(im,1));
%     
%     out = im(ys,xs,:);
    x1_diff =  numel(nonzeros(xs<1));
    y1_diff =  numel(nonzeros(ys<1));
    diff = [x1_diff y1_diff];
    %x2_diff =  numel(nonzeros(xs>size(im,2)));
    %y2_diff =  numel(nonzeros(ys>size(im,1)));
     xs(xs < 1) = [];   
     ys(ys < 1) = [];
    
     xs(xs > size(im,2)) = [];%size(im,2);
     ys(ys > size(im,1)) = [];%size(im,1);
% % 
% %     %extract image
%    
    out=im(ys,xs,:);
%     
end 

function y = clamp(x,lb,ub)
y=max(x,lb);
y=max(y,ub);
end