%% costMeasure.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function computes the cost measure to be used in the
% optimization, from the summary metrics of the training set.

%% Function Syntax
function f = costMeasure(mthd,discFactor,pC,mean)
%%
% _mthd_ : method of computing cost measure, _'percent'_ or _'discounted'_
%
% _dF_ : if 'discounted' setting is chosen, specify discount factor (as a %); otherwise blank 
%
% _pC_ : average annual debt cost, as a percentage of stock, for each strategy
%
% _mean_ : average debt cost by year, for each strategy
%
% _f_ : vector of the cost measure for each strategy, used for optimization


%% 1. Compute cost metric for optimization
switch mthd
    case 'percent'  %if cost measure is: average annual debt cost as % of stock
        f = pC;
    case 'discounted'   %if cost measure is: discounted average annual cost (not used)
        cc = size(mean,1); 
        if (discFactor < 0.5) && (discFactor ~= 0)
            error('discount factor should be enter as a number, not a decimal (e.g. 3.22, not 0.0322)');
        end
        discFactor = discFactor/100;
        dF_all = ones(1,cc)' ./ ((1+discFactor).^linspace(1,cc,cc)');
        f = (mean'*dF_all);
end