%% backwardOLS.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the OLS class) creates an adjusted OLS model with the insignificant
% parameters removed. That is the final model used for the regression to curve-fit the general cost/risk functions.


%% Function Syntax
function [model yhat] = backward_OLS(model, x, y, sigLevel)
%%
% _model_ : method is applied to, and updates, the OLS class
%
% _x_ : allocations for all strategies 
%
% _y_ : cost or risk measure for all strategies 
%
% _sigLevel_ : significance level for t-test deletion of irrelevant terms
%
% _yhat_ : estimated cost/risk from OLS model


%% 1. Set up variables
[ rowx, colx ] = size(x);   %rows is # of strategies, columns is # of instruments

pow   = model.pow;  % powers of individual-instrument regressors (1 and 2 here)
inter = model.interact; % powers of instruments in interaction regressors (1 here)

const = 0;
if model.addconst, const = 1; end


%% 2. Remove insignificant regressors one-by-one via F-test
unsignif = true;

% Each time loop is run, an insignificant regressor is removed (from the
% initial/reduced model), until all remaining regressors are significant
while unsignif & ( size(model.regMatrix,1) > 0) 

    Xreg = genRegressor(model, x);  %generate initial/reduced regressors
    [model.param, yhat, resU2] = stableOLS( Xreg, y );  %compute OLS parameters for regressors
    
    colU = size(Xreg,2);
    stat = zeros(1, colU);

    % Compute F-statistic of each regressor parameter
    if rowx > colU+1
        for i=(1+const):colU
            XregC  = [Xreg(:,1:(i-1))  Xreg(:,(i+1):end)];
            [ paramC, yhat ] = stableOLS( XregC, y );
            resC2 = ( y - yhat );
            resC2 = resC2'*resC2;
            stat(i) = (resC2 - resU2)/( resU2/(rowx-colU) );
        end
    else
        stat = 1e-12*(abs(model.param));            % if there are more regressors than observations, automatically remove a regressor      
    end
    
    
    % Select the least significant parameter, and remove it if it fails
    % F-test; do not remove constant
    [minF, minIndex] = min( abs( stat(1+const:end) ));
    unsignif = ( sigLevel < 1-fcdf( minF, 1, rowx-colU ));
    
    if unsignif % if fails F-test
        model.regMatrix = [ model.regMatrix(1:minIndex-1 , :) ;...
                            model.regMatrix(minIndex+1:end , :) ];
    end
end

if isempty(model.regMatrix)
    model = complete(model, [0]);   %check
end


%% 3. Compute OLS parameters based on final regressors 
%
% See: _<genRegressor.html genRegressor>_, _<../../misc_matlab/stableOLS.html stableOLS>_
Xreg = genRegressor(model, x);  %generate final regressors of OLS model
[model.param, yhat] = stableOLS( Xreg, y ); %compute final parameters of OLS model