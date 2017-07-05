function svm_model = train_onlineSVM(patch,tmplPos,tmplNeg,seq)
 configGlobalParam;
 [dataPos, seq.opt] = globalParam.FeatureExtractor(patch, tmplPos, seq.opt);
 [dataNeg, seq.opt] = globalParam.FeatureExtractor(patch, tmplNeg, seq.opt);
 svm_model   = globalParam.ObservationModelTrain(dataPos, dataNeg, seq.opt);
 
 
 
 