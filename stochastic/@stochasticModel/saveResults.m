%% saveResults.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method saves the results from the stochastic process into three files, to be imported in the Debt Charge Engine.

%% Method Syntax
function []=saveResults(mObject,data,userSavePath,prefix)
%%
% _mObject_ : method is applied to _nelsonSiegel_ class
%
% _data_ : simulated results to save
%
% _saveSavePath_ : name of path where results are saved
%
% _prefix_ : user-defined prefix for name of result files
 

%% 1. Save variables from _nelsonSiegel_ object as final results 
%
% See _<get_Xlag.html get_Xlag>_
coupon = data.C;    %simulated nominal par coupon rates
realcoupon = data.R;    %simulated real par coupon rates
eMacro = data.eMacro;   %simulated macroeconomic forecasts

X0 = data.X;    %matrix of historical yield curve and macroeconomic variables
para = get(mObject,'parameters');   %structure of VAR parameters
LTM = para.LTM; %vector of long-term means for each variable
Xlag = get_Xlag(mObject,get(mObject,'startLag'));   %vector of lagged values for each variable


%% 2. Save results to three files in defined _dataFiles_ folder
if ~exist('userSavePath')
  userSavePath = ['./dataFiles/' date];
  disp('No "userSavePath". Results saved in "../dataFiles/date.mat" ')
end

% File 1: All Simulation Results
save([userSavePath prefix 'Results'], 'mObject', 'data' );

% File 2: Simulated Coupons (included in File 1)
save([userSavePath 'Coupon_' prefix], 'coupon', 'realcoupon' );

% File 3: Parameters from VAR Simulation
save([userSavePath 'FinR_' prefix], 'X0', 'LTM', 'para', 'Xlag','eMacro');