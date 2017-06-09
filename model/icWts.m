%% icWts.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function creates a random set of strategies that are consistent
% with the specified minimum issuance constraints, as part of the full set
% of representative strategies to be evaluated for the training set.


%% Function Syntax
function y = icWts(ic,N)
%%
% _ic_ : vector of minimum issuance constraints for each instrument
%
% _N_ : number of minimum-constraint-consistent strategies generated (1/6 of all here)
%
% _y_ : matrix of generated strategies


%% 1. Create random minimum-constraint-consistent strategies
if size(ic,1)>size(ic,2)
    ic = ic';
end
nn = length(ic);

randU=abs(randn(N,nn)); %randomly generated numbers  
allPorts=randU./kron(sum(randU'),ones(nn,1))';  %remaining amount (after minimum constraints satisfied) randomly allocated between all instruments
allPorts = allPorts*(1-sum(ic));    

y = ones(N,1)*ic;
y = y + allPorts;   %allocation from minimum amount + allocation from remaining amount