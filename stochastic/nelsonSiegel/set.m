%% set.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _nelsonSiegel_ class) sets a value for the given variable in the _nelsonSiegel_ class. 

%% Method Syntax
function sm = set(sm, p, v)
%%
% _sm_ : method is applied to, and updates, _nelsonSiegel_ class
%
% _p_ : name of variable
%
% _v_ : value to set


%% 1. Set value for specified variable in _nelsonSiegel_ class via _stochasticModel_ class
%
% See _<@stochasticModel/set.html set>_

switch p
  case 'numSims'
    sm.numSims = v;
  otherwise
    try
      sm.stochasticModel = set( sm.stochasticModel, p, v);
    catch
      error([p, ': Cannot set this property!']);
    end
end

