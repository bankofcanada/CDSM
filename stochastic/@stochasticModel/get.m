%% get.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _stochasticModel_ class) calls the specified variable within the _stochasticModel_ class

%% Method Syntax
function v = get(sm, p, X);
%%
% _ns_ : method is applied to _stochasticModel_ class
%
% _p_ : name of variable being called
%
% _X_ : specific lag, optional input
%
% _v_ : variable called


%% 1. Call the specified variable in _stochasticModel_ class
%
% See _<get_Xlag.html get_Xlag>_
switch p
  case 'zero_data'
    v = sm.zero_data;
  case 'macro_data'
    v = sm.macro_data;
  case 'gdp_data'
    v = sm.gdp_data;
 case 'ttm'
    v = sm.ttm;
  case 'histT'
    v = sm.histT;
  case 'histN'
    v = sm.histN;
  case 'simT'
    v = sm.simT;
  case 'simN'
    v = sm.simN;
  case 'startLag'
    v = sm.startLag;
  case 'Xlag'
    v = get_Xlag(sm, X);%--function--%
  otherwise
    error([p, ': Not a valid property of stochasticModel class!']);
end







