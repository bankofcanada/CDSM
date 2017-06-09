%% nonLinearConstraint.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function applies non-linear constraints on the optimization by checking that a strategy's risk is equal to or less than the risk level specified for that point on the efficient frontier. 


%% Function Syntax
function [c,sumDiff] = nonLinearConstraint( x, varargin )
%%
% _x_ : financing strategy (control variable in optimization)
%
% 1st _varargin_ : OLS model for approximating risk for each strategy
%
% 2nd _varargin_ : efficient frontier risk level


%% 1. Obtain non-linear constraint

% Equality constraint so that allocations sum to one
sumDiff = 1-sum(x);
if abs(sumDiff)<0.01 
    sumDiff = 0;
end

% Inequality constraint checking that risk of given strategy is equal
% to or less than specificied risk (x-axis) level on efficient frontier
c = 0;
if nargin >= 3 
    ineqConModels = varargin{1};
    ineqConVal    = varargin{2};

    for i = 1:length(ineqConModels)
      c(i) = predict( ineqConModels(i), x ) - ineqConVal(i);
    end
end

% Other equality constraints, not used
if nargin >= 5
    eqConModels = varargin{3};
    eqConVal    = varargin{4};
  
    for j = 1:length(eqConModels)
      ceq(i) = predict( eqConModels(i), x ) - eqConVal(i);
    end
    sumDiff = [sumDiff,ceq(:)];
end 