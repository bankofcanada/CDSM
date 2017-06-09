%% forward.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function computes the one-year forward rates for each quarter up to
% 30 years.

%% Function Syntax
function [f] = forward(z,ttm)
%%
% _z_ : vector of zero rates for each quarter up to 30 years 
%
% _ttm_ : vector of associated tenors (0.25,0.5...,27.75,30)
%
% _f_ : vector of computed forward rates


%% 1. Set Up
f = zeros(1,length(ttm));
f1 = zeros(1,length(ttm));
inc = 1;


%% 2. Compute forward rates
for i = 1:(length(ttm)-1)
  f(i) = (((1+z(i+1)).^(ttm(i) + inc))/((1+z(i)).^ttm(i)))^(1/inc) - 1;
end
f(end)=f(end-1);