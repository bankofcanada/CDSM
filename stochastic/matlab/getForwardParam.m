%% getForwardParam.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function computes parameters for forecasting variables that follow a VAR(p) process, based on their lagged values

%% Function Syntax
function [B0, B1, B2] = getForwardParam(forwardPeriod, b0, b1, b2)
%%
% _forwardPeriod_ : number of periods to forecast
%
% _b0_ : constant coefficients for VAR
%
% _b1_ : coefficient for lag-1 variables in VAR
%
% _b2_ : coefficient for lag-2 variables in VAR, optional input
%
% _B0_ : constant coefficients for forecast equation
%
% _B1_ : coefficient for period-t variables in forecast equation
%
% _B2_ : coefficient for period-(t-1) variables in forecast equation


%% 1. Set up, accommodate for 1-lag VAR
if nargin == 3
  b2 = 0*b1;
end


%% 2. Compute forward parameters for recursive expectation model: y(t+fwP) = B0 + B1*y(t) + B2*y(t-1) 
B0(:,1,1) = b0;         %B0 for t+1 forecast
B0(:,1,2) = b1*b0+b0;   %B0 for t+2 forecast
B1(:,:,1) = b1;         %B1 for t+1 forecast
B1(:,:,2) = b1*b1+b2;   %B1 for t+2 forecast
B2(:,:,1) = b2;         %B2 for t+1 forecast
B2(:,:,2) = b1*b2;      %B2 for t+2 forecast

for fwP=3:forwardPeriod     %Parameters for general forecast
    B0(:,:,fwP) = b0 + b1*B0(:,:,fwP-1)+ b2*B0(:,:,fwP-2);
    B1(:,:,fwP) = b1*B1(:,:,fwP-1)+ b2*B1(:,:,fwP-2);
    B2(:,:,fwP) = b1*B2(:,:,fwP-1)+ b2*B2(:,:,fwP-2);
end
