%% ns_basis.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function computes the loadings of a given Nelson-Siegel factor (level, slope, curvature) on the yield curve

%% Function Syntax
function [f]=ns_basis(tenor,i,q)
%%
% _tenor_ : vector of relevant bond tenors
%
% _i_ : index of Nelson-Siegel factor (1 - level, 2 - slope, 3 - curvature)
%
% _q_ : lambda constant in Nelson-Siegel formula
%
% _f_ : loading for the given factor


%% 1. For each factor, compute its loading on each yield curve tenor
if(i==1)    %level
  f= ones(size(tenor));
elseif(i==2)    %slope
  f=(1-exp(-q*tenor))./(q*tenor);
elseif(i==3)    %curvature
  f=(1-exp(-q*tenor))./(q*tenor)-exp(-q*tenor);
else
  f=zeros(size(tenor));
end