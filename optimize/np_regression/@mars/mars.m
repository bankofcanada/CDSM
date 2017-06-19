%% mars.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

function model = mars(varargin)

% model.param	**estimation parameters of basis [ '**' means 'required for estimation']
% model.in_basis    **is -1, 0, or 1 depending if a given variable is in
%   (negative), out, or in (positive) the given basis
% model.splitsites	**location of cutoff for each basis, referred to as 'tstar' in Friedman
% model.tupper  **location of cubic upper knots for each basis
% model.tlower  **location of cubic lower knots for each basis
% model.nsplits	number of sub_domains in mars model
% model.max_interaction max number of variables in each basis. default is inf.
% model.max_domain  max number of domains in mars model. default is 1 (constant basis)
% model.minknotdist in range 0..1, tolerance prob value of neg or positive run observations...
%   between each knot. closer to 0 is smoother.  default is 0.1.
%%%%%%
%Tiago Rubin & David Bolder, Bank of Canada, June 2006
%%%%%%

model.param      = [];
model.nsplits    = [];
model.splitsites = {};
model.tupper     = {};
model.tlower     = {};
model.in_basis   = {};
model.max_domain = [];
model.max_interaction = inf;
model.minknotdist     = 7;

nparam_model = nonparametric_model();   % Parent class
model = class(model, 'mars', nparam_model);

switch nargin
    case 0
        % No input, create empty parent      
    case 1
        % if single argument is a mars, return it
        if (isa(varargin{1}, 'mars'))
            model = varargin{1};
        else
            warning(['Input argument is not a mars object.'])
            warning(['mars object initialised empty.'])
        end
    case 5
        % given 5 inputs, fill the 5 fields required for estimation
        model.param    = varargin{1};
        model.in_basis = varargin{2};
        model.splitsites = varargin{3};
        model.tupper   = varargin{4};
        model.tlower   = varargin{5};
    otherwise
        warning(['Wrong number of arguments.  mars object initialised empty'])
end


