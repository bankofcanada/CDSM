%% predict.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function computes the predicted cost for any given
% strategy based on the parameterized OLS model. The function handle of
% this, with the OLS parameters passed in, is what is being optimized at each risk level to
% create the efficient frontier.


%% Function Syntax
function yhat = predict(olsmodel, x, varargin)
%%
%
% _olsmodel_ : function is applied to OLS class (passed-in argument for function handle)
%
% _x_ : financing strategy (control variable in optimization)
%
% _yhat_ : cost of strategy (objective value in optimization)


%% 1. Compute cost of strategy based on estimated OLS model
olsmodel = set(olsmodel, varargin{:});
Xreg = genRegressor(olsmodel, x);   %convert strategy's instrument allocations to inputs for OLS prediction (power terms 1, 2 and interaction terms 1 for each instrument)
yhat = Xreg * olsmodel.param;   %compute cost for strategy   
end 