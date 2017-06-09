%% prob_greater.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function computes the proportion of values in a matrix that
% are greater than a given number.


%% Function Syntax
function pr = prob_greater(x,num,dim)
%%
% _x_ : matrix of values
%
% _num_ : number that the matrix values are being compared to
%
% _dim_ : number of dimensions in matrix


%% 1. Compute proportion of values in matrix greater than given number
x = squeeze(x);
x = x -num;

if dim <= 2
    [t, k] = size(x);
    if k>t
        x = x';
    end
    
    for i = 1:min(t,k)
        c = sort(x(:,i));
        m = min(c, 1e-10);
        m = max(m,0);
        m = m *(1/1e-10);
        pr(i) = sum(m) ./ length(c);
    end
    
elseif dim == 3
    [t,k,p] = size(x);
    
    for i=1:k
        for j=1:p
           c = sort(squeeze(x(:,i,j)));
           m = min(c, 1e-10);
           m = max(m,0);
           m = m *(1/1e-10);
           pr(i,j) = sum(m) ./ length(c);
        end
    end
       
end