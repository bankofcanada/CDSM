%% train.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the OLS class) regresses, using OLS, the cost/risk measure of all strategies in the
% training set on several regressors describing their instrument allocation in
% order to approximate cost/risk as functions of any strategy.


%% Function Syntax
function [sigModel yhat model] = train(model, x, y, varargin)
%%
%
% _model_ : method is applied to, and updates, OLS class
%
% _x_ : allocations for all strategies (informs regressors)
%
% _y_ : cost/risk measure for all strategies (dependent variable)
%
% _sigModel_ : OLS class for model with only significant variables,
% parameters are taken from here
%
% _yhat_ : cost/risk predictions from model


%% 1. Set Up
%
% See: _<set.html set>_
model    = set(model, varargin{:});          % sets additional parameters to the model (none here)
sigModel = model;
yhat     = 0;

[rowx, colx] = size(x); %rows is # of strategies, columns is # of instruments


%% 2. Set power and interaction terms
if colx < 4 %if model has fewer than 4 instruments (not here)
    model = complete(model, [ 1, 2, 3 ]);      
elseif colx < 9    %if model has fewer than 9 instruments (not here)
    model = complete(model, [ 1, 2 ]);        
else
    if isempty(model.pow)   %for this model (9 instruments), each instrument allocation is taken to powers 1 and 2 for single-instrument regressors
        model.pow = [1,2];  
    end
    if isempty(model.interact)  %for this model, each instrument allocation is taken to power 1 for interaction regressors
        model.interact = [1];
    end
end


%% 3. Generate matrix of regressors
%
% See: _<genRegressor.html genRegressor>_
[Xreg, model]= genRegressor(model, x);


%% 4. Run OLS to get parameters of estimated cost/risk function
%
% See: _<../../misc_matlab/stableOLS.html stableOLS>_
[model.param] = stableOLS( Xreg, y);


%% 5. Run OLS to get parameters of estimated cost/risk function, after removing unsignificant (default level 20%) parameters
%
% See: _<backward_OLS.html backward_OLS>_
if (model.sigLevel > 0)
    [sigModel yhat] = backward_OLS(model, x, y, model.sigLevel);
else
    sigModel = model;
    if nargout > 1      % compute model cost/risk prediction for each strategy (if output defined)
        yhat = Xreg*model.param;
    end
end
end 