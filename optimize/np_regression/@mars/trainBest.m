%% trainBest.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

function [model yhat keptSplits] = trainBest(model, x, y, varargin)

% function [model yhat keptSplits] = trainBest(marsmodel, x, y, varargin)
%
% Train mars class regressors with differrent values of max-number-of-splits
% "max-domain".  Test each nsplits values with out-of-sample validation of
% model.  
%
%%%%%%
%
% Inputs are 
% model     : the mars() class regressing function
% x         : regressors
% y         : dependant variable
%
% varargin  : 'max', val
%           Are used to define maximum bounds on max_domain search.
%           It evaluates the largest model, and then compares the 
%           smaller-models trough cross-validation prunning.
%           Default : 2*ceil( log2(size(x,1)) * ( (size(x,2)+1)^(2/3) )
%%%%%%
%
% Outputs are
%
% model     : the best max_domain model
%
% yhat      : in-sample yhat estimation for the best nsplit model
%
% splitsReports: S-by-3.  1st column is nsplits value.  2nd column is
%           nsplits RSME out-of-sample.  3rd column is nsplit
%           training+prediction time.
%%%%%%
% Tiago Rubin
%%%%%%

%%%%%%
% Init variables
%
maxSplits = 5 + 2*ceil( log2(size(x,1)) * ( (size(x,2)+1)^(1/2) ) );

%%%%%%
% Handle varargin inputs
%

optionsin = varargin;
% Loop over all input argument and fill field if appropriate
while length(optionsin) >= 2,
  
    optionName = optionsin{1};      % First of two is option name
    val = optionsin{2};     % Second of two is option value
    optionsin = optionsin(3:end);     % Remove first two from option
    
    switch optionName
        case 'max'
            maxSplits = val;
            varargin = optionsin;
    end
end

%%%%%%
% Find keptSplits values.
%
model.max_domain = maxSplits;
    
[model yhat strucanova keptSplits] = train(model, x, y, varargin{:});
    
%%%%%%
% Find the highest max_domain needed.
%
maxKept = max(keptSplits);      % The maximal order of splitting kept after pruning was performed.

model.max_domain = maxKept+2;   % max_domain should be higher than maxKept

%%%%%%
% Return Best values
%

yhat  = predict(model, x);


end %%%END of function model = trainBest(model, x, y, varargin)
