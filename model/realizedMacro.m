%% realizedMacro.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine computes each quarter's realized macroeconomic variables for computing financial requirements (via equation for revenues/expenses growth), for the given simulation.


%% 1. Load lagged estimates for computing first-year macro variables

switch lower(get(mObject, 'startLag'))
 case {'last', 0}
   M = get(mObject, 'macro_data');
   Xyearlag(:,1:12) = M(:,end-11:end);
 case {'mean', 1}
  Xyearlag = Xlag(ones(12,1),s.dim+1:end)';
 case {'ltm', 2};
  Xlag = Xlag';
  Xyearlag = Xlag(ones(12,1),s.dim+1:end)';
  Xlag = Xlag';
 otherwise
  error('wrong first lag argument');
end


%% 2. Compute realized macroeconomic variables for this quarter

%1st macro variable in equation: real GDP growth (quarterly basis), from simulations
rMacro(:,1) = data.X(:,s.dim+6,k);  

%2nd macro variable equation: average inflation for last year (quarterly basis), from macro forecasts
rMacro(:,2) = eMacro(:,2,k);

%3rd macro variable in equation: inflation (quarterly basis)
rMacro(:,3) = -1 + (1+X0(:,s.dim+5,k)).^(1/4);

%4th macro variable: change in overnight rate in the last 12 months (quarterly basis)
rMacro(:,4) = (1/4) * (  data.X(:,s.dim+3,k) ...
  - [ Xyearlag(3,[3 6 9 12])' ; data.X(1:end-4,s.dim+3,k) ]  );

%5th macro: lagged change in short rate (quarterly basis)
rMacro(:,5) = eMacro(:,5,k);

clear Xyearlag tt;