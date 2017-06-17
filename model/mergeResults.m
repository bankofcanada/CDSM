%% mergeResults.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This script is run to complete the DEBT CHARGE ENGINE step of the model,
% by merging the training set results produced in separate blocks into a
% single file for optimization analysis in the PRODUCE EFFICIENT FRONTIER
% step.


%% 1. Merge results from each training set block into a single training set file
%%
% Each block contains the structures _s_ (parameters of that block's
% training set) and _m_ (results of that block's training set). The purpose
% is to combine the information in each field of _m_ across blocks into a single
% field in the final training set's _m_ structures. (_s_ is taken directly
% since it is the same for all blocks.)

resultName = '../results/ns/trainingSets/tsBlocks/policyResults_policyPort_MMMYY_vname_block';

ff=1;
while 1 
  if ff==9       % equal to one plus the number of blocks (50), since loop is across each block
   break;
  end
  try
    load( [resultName num2str(ff)] )    %load the block
    m.issue.qdetailedOut = squeeze(mean(m.issue.qdetailedOut,3));
    m=rmfield(m, {'CPI' 'GDP'});
  end
  if ff==1
    M=m;
    ff=ff+1;
    continue
  end
  try
    %m=rmfield(m,{'CPI' 'GDP'});
  end
  %S(ff)=s;
  ff=ff+1;
  
  % Loop across each field in _m_ for that block, inserting that field's
  % values into the field for the final training set _m_.
  mNames = fieldnames(m);
  for mm = 1:length(mNames)
    mField = getfield(m, mNames{mm});
    if isa(mField, 'struct')    %if the field in _m_ is also a structure
      mNames2 = fieldnames(mField);
      for mm2 = 1:length(mNames2)
        mField2 = getfield(mField, mNames2{mm2});
        if isa(mField2, 'struct')   %if field within the structure in _m_ is also a structure
          mNames3 = fieldnames(mField2);
          for mm3 = 1:length(mNames3)
            mField3 = getfield(mField2, mNames3{mm3});
            M.(mNames{mm}).(mNames2{mm2}).(mNames3{mm3})...
              (:,:,end+1:end+size(mField3,3)) = mField3;
          end
        else    %if field is not a structure
          M.(mNames{mm}).(mNames2{mm2})...
            (:,:,end+1:end+size(mField2,3)) = mField2;
        end
      end
    else    %if field is not a structure
        M.(mNames{mm})(:,:,end+1:end+size(mField,3)) = mField;  
    end
  end
end

m=M;
clear M


%% 2. Merge results in desired dimensions
%%
% Loop across each field in _m_ for each block, inserting that field's
% values into the field for the final training set _m_. This overrides process above so that variables are saved in desired dimensions.
%
% See: _<squeezeMerge.html squeezeMerge>_
squeezeMerge;


%% 3. Reshape training set result variables into desired dimensions

% Average cost and debt stock metrics
for j=1:10
	moyenne(:,j,:) = m.DCD(:,j,:) ./ m.stock.os(:,j,:);
end

m.percentCharges.byYear = 100*squeeze(mean(moyenne,1))';
m.percentCharges.avg = mean(m.percentCharges.byYear,2);

m.DCDmean = squeeze(mean(m.DCD,1));
m.SDmean = squeeze(mean(m.stock.os,1));
m.totalStockYrmean = squeeze(mean(m.stock.os,1));
m = rmfield(m,{'DCD' 'stock'});

% Risk metrics
m.cv.cCV = reshape(m.cv.cCV, size(m.cv.cCV,1)*size(m.cv.cCV,2),1);
m.cv.cAdjBV = reshape(m.cv.cAdjBV, size(m.cv.cAdjBV,1)*size(m.cv.cAdjBV,2),1);
m.cv.cCV_1stHalf = reshape(m.cv.cCV_1stHalf, size(m.cv.cCV_1stHalf,1)*size(m.cv.cCV_1stHalf,2),1);
m.cv.cCV_2ndHalf = reshape(m.cv.cCV_2ndHalf, size(m.cv.cCV_2ndHalf,1)*size(m.cv.cCV_2ndHalf,2),1);
m.cv.cAdjBV_1stHalf = reshape(m.cv.cAdjBV_1stHalf, size(m.cv.cAdjBV_1stHalf,1)*size(m.cv.cAdjBV_1stHalf,2),1);
m.cv.cAdjBV_2ndHalf = reshape(m.cv.cAdjBV_2ndHalf, size(m.cv.cAdjBV_2ndHalf,1)*size(m.cv.cAdjBV_2ndHalf,2),1);
%m.cv.noSurp.cAdjBV = reshape(m.cv.noSurp.cAdjBV, size(m.cv.noSurp.cAdjBV,1)*size(m.cv.noSurp.cAdjBV,2),1);
%m.cv.noSurp.cAdjBV_1stHalf = reshape(m.cv.noSurp.cAdjBV_1stHalf, size(m.cv.noSurp.cAdjBV_1stHalf,1)*size(m.cv.noSurp.cAdjBV_1stHalf,2),1);
%m.cv.noSurp.cAdjBV_2ndHalf = reshape(m.cv.noSurp.cAdjBV_2ndHalf, size(m.cv.noSurp.cAdjBV_2ndHalf,1)*size(m.cv.noSurp.cAdjBV_2ndHalf,2),1);

% Fiscal metrics
m.fr.FinReq = squeeze(mean(m.fr.FinReq,1));
m.fr.Expenses = squeeze(mean(m.fr.Expenses,1));
m.fr.Revenues = squeeze(mean(m.fr.Revenues,1));


%% 4. Save file with final training set results
save([resultName '_all.mat'],'m','s');