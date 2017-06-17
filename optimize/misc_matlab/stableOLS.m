%% stableOLS.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function computes OLS parameters in a numerically stable fashion, not affected
% by singular regressors.


%% Function Syntax
function [ param, Ye, MSE ] = stableOLS(x,y)
%%
% _x_ : matrix of OLS regressors (instrument allocations to different powers/interaction)
%
% _y_ : dependent variable (cost or risk)
%
% _param_ : parameters of OLS, used for cost/risk function approximation
%
% _Ye_ : estimated cost/risk from OLS
%
% _MSE_ : mean-squared error from OLS


%% 1. Set up
param = 0;
Ye    = 0;
MSE   = 1e15;

% Product of inputs, used for computing parameters
XX = x'*x;  
Xy = x'*y;


%% 2. Use Cholesky decomposition to estimate OLS, or apply pseudoinverse instead if singular
try 
	XX = XX + eye(length(XX))*1e-10 ;       
	Chol_XX = chol(XX) ;
	param = Chol_XX \ (Chol_XX' \ Xy) ;     % Cholesky method to estimate OLS
catch
	param = pinv(XX)*Xy ;                   % use pseudoinverse method if singular matrix
end


%% 3. Compute estimation and mean-squared-error
if nargout > 1
    Ye = x * param ;                     % Estimation of y
    
    if nargout > 2
        err = y - Ye ;                                 % vector of errors
        N_k = max([ (length(Ye)-length(param)), 0.01 ]);
        MSE = (err)'*(err)/N_k ;                       % unbiased Mean-Squared-Error estimation
    end
end
end