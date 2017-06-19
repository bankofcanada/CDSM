%% get_Xlag.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the parent _stochasticModel_ class) defines the starting lagged values for VAR(p) simulation, based on the setting ('last','mean','ltm') and historical data

%% Method Syntax
function Xlag = get_Xlag(sm, startLag)
%%
% _sm_ : method is applied to _stochasticModel_ class
%
% _startLag_ : setting for the starting values to use ('last', 'mean', 'ltm')
%
% _Xlag_ : matrix of starting lagged values for each variable, up to lag-6


%% 1. Set up
para = get(sm,'parameters');
if nargin == 1
  startLag = get(sm, 'startLag');   %use default starting value setting if not specified
end


%% 2. Define starting lagged values (depending on setting) up to lag-6, for up to a VAR(6) simulation
switch lower(startLag)
  case {'last', 0}  %'last' setting: last 6 months of historical data  
    Xlag(1,:)=para.X(:,end);
    Xlag(2,:)=para.X(:,end-1);
    Xlag(3,:)=para.X(:,end-2);
    Xlag(4,:)=para.X(:,end-3);
    Xlag(5,:)=para.X(:,end-4);
    Xlag(6,:)=para.X(:,end-5);
  case {'mean', 1}  %'mean' setting: arithmetic mean from historical data
    Xlag(1,:)=mean(para.X,2);
    Xlag(2,:)=mean(para.X,2);
    Xlag(3,:)=mean(para.X,2);
    Xlag(4,:)=mean(para.X,2);
    Xlag(5,:)=mean(para.X,2);
    Xlag(6,:)=mean(para.X,2);
  case {'ltm', 2}   %'ltm' setting: long-term mean, pre-set or stationary mean from VAR(p)
    Xlag(1,:)=para.simLTM;
    Xlag(2,:)=para.simLTM;
    Xlag(3,:)=para.simLTM;
    Xlag(4,:)=para.simLTM;
    Xlag(5,:)=para.simLTM;
    Xlag(6,:)=para.simLTM;
  otherwise
    error('No valid "startType" input or "sm.startLag". Must be 0, 1, or 2!');
end