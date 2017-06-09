%% OLS.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function constructs the class _OLS_ where variables describing the OLS model, used to curve-fit a general function of cost and risk for any financing strategy, will be stored. _OLS_ is a child class that inherits from the parent class, _nonparameteric_model_.


%% Function Syntax
function model = OLS(varargin)


%% Variables stored in _OLS_
%
% * _addconst_ : including a constant in OLS regression (true)
% * _param_ : parameters of OLS model (obtained from regression) used to curve-fit cost/risk functions
% * _pow_ : powers of each instrument allocation taken for single-instrument regressors (1, 2)
% * _interact_ : powers of each instrument allocation taken for interaction regressors (1)
% * _regMatrix_ : initial matrix of regressors in OLS model
% * _sigLevel_ : threshold for removing insignificant regressors from initial matrix (0.2)


%% 1. Construct _OLS_ class
%
% See: _<../@nonparametric_model/nonparametric_model.html nonparametric_model>_
model.addconst = true;
model.param    = [];
model.pow      = [];
model.interact = [];
model.regMatrix= [];
model.sigLevel = 0.2;

nparam_model = nonparametric_model();                   % construct parent _nonparametric_model_ class
model        = class(model, 'OLS', nparam_model);       % construct _OLS_ class as child of _nonparametric_model_


switch nargin
    case 0  %if no inputs given, create empty class    
    case 1 
        in1 = varargin{1};
        if isa(in1, 'OLS')  % if single argument is OLS, return it
            model = in1;
        elseif isa(in1, 'double')   % if only one other argument, assumed to define powers
            model.pow      = in1;
        else
            warning(['Single input must be OlS or double. OLS is empty.']);
        end
        
    case 3  % If 3 inputs given, fill the fields required for estimation
        model.param = varargin{1};
        model.pow   = varargin{2};
        model.interact = varargin{3};
               
    otherwise
        warning(['Wrong number of input for OLS. Initialised empty.']);  

end