%% get.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

function val = get(model, propname, varargin)

% GET get mars property

switch propname
    case 'param'
        val = model.param;
    case 'in_basis'
        val = model.in_basis;
    case 'x_in'
        val = model.in_basis;
    case 'splitsites'
        val = model.splitsites;
    case 'tstar'
        val = model.splitsites;
    case 'tupper'
        val = model.tupper;       
    case 't_plus'
        val = model.tupper;
    case 'tlower'
        val = model.tlower;       
    case 't_minus'
        val = model.tlower;
    case 'tcubic'
        val = zeros( [size(model.tupper), 2] );
        val(:,:,1) = model.tlower;
        val(:,:,2) = model.tupper;
    case 'max_domain'
        if ~isempty(model.max_domain)
            % max_basis is defined in model
            val = model.max_domain;
        else
            % max_basis undefined, default is sqrt of sample size
            warning(['Undefined max_domain, default is sqrt sample size'])
            val = model.max_domain;
        end
    case 'nsplits'
        val = model.nsplits;
    case 'minknotdist'
        if model.minknotdist < 1        % probability
            val = ceil( abs( log2(model.minknotdist) ) + 1 );
        else
            val = model.minknotdist;
        end
    otherwise
        warning(['Parameter ' propname ' is not element of class mars'])
        val = [];
end
