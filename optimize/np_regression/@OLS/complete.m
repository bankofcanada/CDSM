%% complete.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _OLS_ class) fills in information on the
% relevant powers and interactions in the OLS regressors.

%% Function Syntax
function model = complete(model, powVector)
%
% _model_ : method is applied to, and updates, the _OLS_ class
%
% _powVector_ : vector of relevant powers of instrument allocations to be included as OLS regressors (single-instrument or interaction)


%% 1. Update for relevant powers in regression
if isempty(model.pow)
    model.pow = powVector;  %powers on instruments for single-instrument regressors (1 and 2) 
end

if isempty(model.interact)
    model.interact = powVector; %powers on instruments for interaction regressors (1) 
end

if isempty(model.addconst)
    model.addconst = 1; %constant term
end