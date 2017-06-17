%% set.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the OLS class) sets additional parameters for the OLS model used to curve-fit the general function of cost and risk for strategies.

%% Function Syntax
function model = set(model, varargin)
%%
%
% _model_ : method is applied to, and updates, _'OLS'_ class
%
% _varargin_ : other parameters to include for _OLS_ model (none here)


%% 1. Implement Parameters
propertyArgIn = varargin;

try
if isa( propertyArgIn{1}, 'double')
    try
        if isa( propertyArgIn{2}, 'double')
            model.pow = propertyArgIn{1};
            model.interact = propertyArgIn{2};
            propertyArgIn = propertyArgIn(3:end);
        end 
    catch
        model.pow = propertyArgIn{1};
        propertyArgIn = propertyArgIn(2:end);
    end
end
catch
end

% Loop over all input arguments and fill field if appropriate
while length(propertyArgIn) >= 2,
    
    propName = propertyArgIn{1};
    val      = propertyArgIn{2};

    propertyArgIn = propertyArgIn(3:end);
    switch propName
        case 'param'
            model.param	= val;
        case 'pow'
            model.pow   = val;
        case 'power'
            model.pow   = val;
        case 'inter'
            model.interact    = val;
        case 'interact'
            model.interact = val;
        case 'regMatrix'
            model.regMatrix   = val;
        case 'sigLevel'
            model.sigLevel    = val;
        case 'addconst'
            model.addconst    = val;
        otherwise
    end
end