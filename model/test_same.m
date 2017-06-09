%% test_same.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function computes the number of values in the given vector that
% are repeated.

%% Function Syntax
function p = test_same(x)
%%
% _x_ : vector
%
% _p_ : number of values that are repeated


%% 1. Compute the number of repeated values in vector
x = sort(x);
n = length(x);
p=0;
for i=2:length(x)
    if x(i)==x(i-1)
        p=p+1;
    end
end
