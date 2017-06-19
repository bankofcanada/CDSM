%% nonLinearConstraint2.m
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.


function [c,sumDiff] = nonLinearConstraint2( x, inEqSign, varargin )
% function [c,sumDiff] = nonLinearCon( x, varargin )
%
% In addition to constraint Sum To One, allows for non-parametric
% definitions of inequality and equality constraints.
%
% Used in objfmincon
%
%%%%%%
% Inputs : 
%
% x : control variable.
%
% varargin 1st & 2nd : nonparametric model(s) and upper bound(s).  If more 
% than one, should be in arrays.
%
% varargin 3rd & 4th : nonparametric model(s) and upper bound(s).  If more
% than one, should be in arrays.
%
%%%%%%
% David Bolder, Bank of Canada, August 2006
%%%%%%

% Equality constraint : sum to one
sumDiff = 1-sum(x);
if abs(sumDiff)<0.01 % a better way to handle this would be to set tolerance on constraints in fmincon call.
    sumDiff = 0;
end

% Inequality constraint(s), if any.
c = 0;
if nargin >= 4  
    ineqConModels = varargin{1};
    ineqConVal    = varargin{2};

    if length(inEqSign) ~= length(ineqConModels)
      error('Dimension of sign and object vector must be identical!')
    end
    for i = 1:length(ineqConModels)
      if inEqSign(i) == 1
	c(i) = predict( ineqConModels(i), x ) - ineqConVal(i);
      else
	c(i) = -predict( ineqConModels(i), x ) + ineqConVal(i);
      end
    end
end
% Additional non-parametric equality contraint(s), if any.
if nargin >= 6
    eqConModels = varargin{3};
    eqConVal    = varargin{4};
  
    for j = 1:length(eqConModels)
      ceq(i) = predict( eqConModels(i), x ) - eqConVal(i);
    end
    sumDiff = [sumDiff,ceq(:)];
end 
