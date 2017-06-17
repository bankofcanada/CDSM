%% get.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _OLS_ class) calls the specified property within the _OLS_ class


%% Function Syntax
function val = get(model, propname, varargin)
%%
%
% _model_ : method is applied to _OLS_ class
%
% _property_ : name of property being called
%
% _varargin_ : other inputs


%% 1. Call the specified property in _OLS_ class
switch propname
    case 'param'
        val = model.param;
    case 'pow'
        val = model.pow;
    case 'interact'       
        if isempty(model.interact)
            model.interact = model.pow;   
        end
        val = model.interact;
    case 'addconst'
        val = model.addconst;     
    case 'regMatrix'
        val = model.regMatrix;
    case 'sigLevel'
        val = model.sigLevel;
    otherwise
        warning(['Parameter ' propname ' is not element of class OLS'])
        val = [];
end