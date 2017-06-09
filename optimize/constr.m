%% constr.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function creates a cell array describing the constraint parameters in the efficient frontier optimization, for cases when minimum issuance constraints are turned on and off. 


%% Function Syntax
function [Constraints x0] = constr(ic,nInst,issConst);
%
% _ic_ : issuance constraints on ('IC') or off ('noIC')
%
% _nInst_ : number of instruments
%
% _issConst_ : minimum issuance constraints in % terms for each instrument


%% 1. Set minimum issuance constraints

%If minimum issuance constraints turned on
if strcmp(ic,'IC') == 1 
    Constraints = { [-eye(nInst)], [issConst], [ones(1,nInst)], [1],  0, 1};    %cell array of constraint parameters    
    x0 = issConst/sum(issConst);    %start value of optimization is an allocation proportional to constraints

%If minimum issuance constraints turned off
elseif ic == 'noIC' 
    Constraints = { [-eye(nInst)], [zeros(1,nInst)], [ones(1,nInst)], [1], 0, 1};   %cell array of constraint parameters (trivial)
    x0 = ones(1,nInst)/nInst;   %start value of optimization is equal allocation between instruments
end