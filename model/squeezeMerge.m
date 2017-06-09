%% squeezeMerge.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine merges the training set results produced in separate blocks into a
% single file, in the desired dimensions.


%% 1. Merge results from each training set block into a single training set file, in desired dimensions
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
	    m.(mNames{mm}).(mNames2{mm2}).(mNames3{mm3})...
             = squeeze(m.(mNames{mm}).(mNames2{mm2}).(mNames3{mm3}));
          end
        else    %if field is not a structure
          m.(mNames{mm}).(mNames2{mm2})...
           = squeeze(m.(mNames{mm}).(mNames2{mm2}));
        end
      end
    else    %if field is not a structure
         m.(mNames{mm})= squeeze(m.(mNames{mm}));
    end
end