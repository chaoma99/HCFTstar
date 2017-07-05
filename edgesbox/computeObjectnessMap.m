function objmap = computeObjectnessMap(img,bbs)
h=size(img,1);
w=size(img,2);
map = zeros(h,w);
kk=200;
if size(bbs,1)<200
    kk=size(bbs,1);
end
for ii=1:kk
    x1 = bbs(ii,1);
    y1 = bbs(ii,2);
    x2 = x1+bbs(ii,3)-1;
    y2 = y1+bbs(ii,4)-1;
    if(x1<1) x1=1;end
    if(y1<1) y1=1;end
    if(x2>w) x2=w;end
    if(y2>h) y2=h;end
    map(y1:y2,x1:x2)=map(y1:y2,x1:x2)+bbs(ii,5);
end
objmap = NORM_ZEROONE(map);
end

function [out, minV, maxV] = NORM_ZEROONE(data)
minV = min(min(data(:)));
maxV = max(max(data(:)));
out = (data - minV) / (maxV - minV + 1e-10);
end
    



