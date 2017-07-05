function  [ind,maxProb] = prorej(patch,bbs,svm_model)
%% this function design for select top K proposals
 configGlobalParam;
 opt = myconfig;
 seq.opt = opt;
 bbs = double(bbs);
 [feat, seq.opt] = globalParam.FeatureExtractor(single(patch), bbs, seq.opt);
  prob    = globalParam.ObservationModelTest(feat, svm_model);    
 [maxProb, maxIdx] = max(prob); 
 [temp,ind] = sort(prob,'descend');
 num = floor(size(bbs,1)./2); %select first K proposals
 bbs1= bbs(ind(1:num),:);



