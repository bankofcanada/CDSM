%% genRegressor.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the OLS class) generates a matrix of regressors for the
% OLS curve-fitting of the cost/risk function, given the defined power and
% interaction terms.
%
% With 9 instruments, powers 1 and 2, and interaction 1, there are 55 regressors in total:
    %
    % * 1, for constant term
    % * 9, for single instruments with power 1 (x1, x2, ... , x9)
    % * 9, for single instruments with power 2 ((x1)^2, (x2)^2, ... , (x9)^2)
    % * (9 choose 2) = 36, for each interaction pair with power 1 ((x1)*(x2), ...
    % , (x1)*(x9) , (x2)*(x3) , ... , (x8)*(x9)) 

    
%% Function Syntax    
function [Xreg, model] = genRegressor(model, x)
%
% _model_ : method is applied to, and updates, the OLS class
%
% _x_ : matrix of instrument allocations for all strategies
% 
% _Xreg_ : regressors for OLS curve-fitting


%% 1. Create a power matrix, containing the power of each instrument allocation in all regressor variables.
%
% See: _<getRegMatrix.html getRegMatrix>_
[rowx, colx]    = size(x);

if isequal( size(model.regMatrix) , [0,0] )
    model.regMatrix = getRegMatrix(model, colx);
end


%% 2. Compute regressor variables from power matrix and each strategy's instrument allocation
Xreg = zeros( rowx, size(model.regMatrix, 1) );

for r = 1 : size(model.regMatrix, 1)                   % for each regressor
    xcol = zeros(size(x));    
    for c = 1 : colx
        xcol(:,c) = x(:, c) .^ model.regMatrix(r, c);   % apply power matrix terms to each instrument's allocation
    end
   
    if colx > 1
        xcol  = prod( xcol' )';         	
    end
    Xreg(:,r) = xcol;   %multiply for each instrument to get regressor value                   

end


%% 3. Add constant term for regressor matrix
if model.addconst
    Xreg = [ ones(rowx, 1), Xreg ];
end
end 