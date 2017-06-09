%% riskCon.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function calls the results for the specified risk metric (for each strategy) from the
% training set summary statistics.


%% Function Syntax
function g = riskCon(rc,riskC)
%%
% _rc_ : name of specified risk metric
%
% _riskC_ : structure containing matrices of risk metrics computed for each strategy
%
% _g_ : vector of the risk measure for each strategy, used for optimization


%% 1. Call the results for the specified risk metric
switch rc
  case 'cBV'    %conditional budget volatility
    g = riskC.cv.cAdjBV;
  case 'cCV'    %conditional cost volatility
    g = riskC.cv.cCV;
  case 'rollover'   %quarterly rollover
    g = riskC.roll;
  case 'rfpg'   %refixing share
    g = riskC.refix_pct_gdp;
  case 'rollpg' %annual rollover
    g = riskC.roll'./2500;  
  otherwise
    error('Need either cBV, cCV or rollover for risk constraint (or adjust program!!)');
end