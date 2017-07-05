I = imread('basketball1.jpg');

%gt=[111	98	25	101];%jogging
gt=[198,214,34,81];%basketball
opts.alpha=0.85;
opts.beta=0.8;
opts.maxAspectRatio= 1.6*max(gt(3)./gt(4),gt(4)/gt(3));
minBoxArea = .75*gt(3)*gt(4);
maxBoxArea= 1.3*gt(3)*gt(4);
aspect = gt(3)/gt(4);
arStep= (1+opts.alpha)./(2*opts.alpha);
scStep = sqrt(1/opts.alpha);
maxApectRatio=1.0*max(gt(3)/gt(4),gt(4)./gt(3));
maxAspectRatio = opts.maxAspectRatio;
minSize=sqrt(minBoxArea);
maxSize=sqrt(maxBoxArea);
arRad1 = floor(log(maxAspectRatio)/log(arStep*arStep));
arRad = 1;
scNum = floor(ceil(log(maxSize/minSize)/log(scStep))); %max(w,h)
rcStepRatio= (1-opts.alpha)/(1+opts.alpha);
box=[];
h = size(I,1);
w= size(I,2);
for  s=1:scNum
   % int a, r, c, bh, bw, kr, kc, bId=-1; float ar, sc;
  % if aspect >1 
    for a=0:2*arRad+1 
      ar=power(arStep,(a-arRad));  %if aspect>1, means w>h
      sc=minSize*power(scStep,(s));
      %bh=floor(sc/ar*sqrt(aspect));
      bh=floor(sc/sqrt(aspect));
      kr=max(2,floor(bh*rcStepRatio));
      %bw=floor(sc*ar*sqrt(aspect)); 
      bw=floor(sc*sqrt(aspect));
      kc=max(2,floor(bw*rcStepRatio));  
      for c=0:kc:w-bw+kc
          for r=0:kr:h-bh+kr
           b.r=r; b.c=c; b.h=bh; b.w=bw; 
            box=[box;b];
         end
      end
    end

end
 for ii = 1:length(box)
     b = box(ii,:);
     rStep = b.h*rcStepRatio;
     cStep = b.w*rcStepRatio;
  if 1
    rStep/=2;
    cStep/=2; 
    if( rStep<=2 && cStep<=2 ) break;  
    rStep=max(1,rStep); 
    cStep=max(1,cStep);
    c.r = b.r-rStep;
    c.h = 
   