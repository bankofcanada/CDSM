%% set.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

function model = set(model, varargin)

propertyArgIn = varargin;

% Loop over all input argument and fill field if appropriate
while length(propertyArgIn) >= 2,
    propName = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch propName
        case 'param'
            model.param = val;
        case 'nsplits'
            model.nsplits = val;
        case 'splitsites'
            model.splitsites = val;
        case 'tupper'
            model.tupper = val;
        case 'tlower'
            model.tlower = val;
        case 'tstar'
            model.splitsites = val;
        case 't_plus'
            model.tupper = val;
        case 't_minus'
            model.tlower = val; 
        case 'tcubic'
            model.tlower = val(:,:,1);
            model.tupper = val(:,:,2);
        case 'in_basis'
            model.in_basis = val;
        case 'x_in'
            model.in_basis = val;
        case 'max_interaction'
            model.tmax_interaction = val;
        case 'depth'
            model.max_interaction = val;
        case 'max_domain'
            model.max_domain = val;
        case 'minknotdist'
            model.minknotdist = val;
        otherwise
            % do nothing and loop back to next pair of variables
            %% warning(['Invalid property'])
    end
end
