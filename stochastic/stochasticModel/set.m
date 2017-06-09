%% set.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _stochasticModel_ class) sets a value for the given variable in the _stochasticModel_ class. 

%% Method Syntax
function sm = set(sm, p, v);
%%
% _sm_ : method is applied to, and updates, _stochasticModel_ class
%
% _p_ : name of variable
%
% _v_ : value to set


%% 1. Set value for specified variable in _stochasticModel_ class
%
switch p
 case 'zero_data'
  sm.zero_data = v;
 case 'macro_data'
  sm.macro_data = v;
 case 'ttm'
  sm.ttm = v;
 case 'histT'
  sm.histT = v;
 case 'histN'
  sm.histN = v;
 case 'simT'
  sm.simT = v;
 case 'simN'
  sm.simN = v;
 case 'startLag'
  sm.startLag = v;
 otherwise
  error([p, 'Not a valid property of stochasticModel class!']);
end
