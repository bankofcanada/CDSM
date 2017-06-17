%% nsOF.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function computes the squared error between the actual historical yield curve and the estimated yield curve based on the factors and factor loadings. This function is optimized to find the historical factor values. The optimal factor values are the ones that minimize this error.

%% Function Syntax
function f = nsOF(x,H,Z);
%%
% _x_ : matrix of factor values
%
% _H_ : matrix of factor loadings
%
% _Z_ : matrix of actual yield curve data
%
% _f_ : squared error between actual and estimated yield curve (to minimize)

%% 1. Compute squared error between the actual historical yield curve and the estimated yield curve
f = 10000*(Z - H*x)' * (Z - H*x);