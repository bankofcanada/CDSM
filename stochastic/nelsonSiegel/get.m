%% get.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _nelsonSiegel_ class) calls the specified variable within the _nelsonSiegel_ class

%% Method Syntax
function v = get(ns, p)
%%
% _ns_ : method is applied to _nelsonSiegel_ class
%
% _p_ : name of variable being called
%
% _v_ : variable called


%% 1. Call the specified variable in _nelsonSiegel_ class
%
% See _<get_Xlag.html get_Xlag>_
  switch p
   case 'lags'
    v = ns.lags;
   case 'parameters'
    v = ns.parameters;
   case 'numSims'
    v = ns.numSims;
   case 'simTenor'
    v = ns.simTenor;
   case 'Xlag'
    v = get_Xlag(ns);
   case 'dim'
    v=ns.dim;
   otherwise
    try
      v = get(ns.stochasticModel, p);
    catch
      error([p, ': Not a valid property of nelsonSiegel class!']);
    end
end

