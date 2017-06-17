%% stochasticModel.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function constructs the parent _stochasticModel_ class that the core _nelsonSiegel_ class inherits from. It is the implementation of the random-scenario generation in the debt-strategy model.


%% Function Syntax
function sm = stochasticModel(Z,ttm,M,G,histT,histN,simT,simN,startLag)


%% Variables stored in _stochasticModel_
    %
    % * _'zero_data'_ (1st input) : matrix of historical zero-coupon yields
    % * _'ttm'_ (2nd input) : tenors associated with that matrix of yields
    % * _'macro_data'_ (3rd input) : matrix of historical macro data
    % * _'gdp_data'_ (4th input) : real GDP data
    % * _'histT'_ (5th input) : number of years of historical data
    % * _'histN'_ (6th input) : granularity of historical data (monthly is 12)
    % * _'simT'_ (7th input) : number of simulation years
    % * _'simN'_ (8th input) : granularity of simulations (quarterly is 4)
    % * _'startLag'_ (9th input) : starting values (for macro and interest rate variables) for simulation ('ltm' is pre-set or ergodic long-term mean)
    %
%
% Variables are called via _get_ function on _'sm'_


%% 1. Construct _stochasticModel_ class 
if nargin == 0; %If no inputs given, creates empty class
  sm.zero_data = [];
  sm.macro_data = [];
  sm.gdp_data = [];
  sm.ttm = [];
  sm.histT = [];
  sm.histN = [];
  sm.simT = [];
  sm.simN = [];
  sm.startLag = [];
  sm = class(sm,'stochasticModel');
elseif isa(Z,'stochasticModel');
  sm=Z;
elseif nargin == 9; %If inputs given. Defines variables for 'stochasticModel' parent class.
  if size(M,2) ~= size(Z,2)
    error('Macroeconomic and zero-coupon time dimensions must agree!');
  end
  sm.zero_data = Z;
  sm.macro_data = M;
  sm.gdp_data = G;
  sm.ttm = ttm;
  sm.histT = histT;
  sm.histN = histN;
  sm.simT = simT;
  sm.simN = simN;
  sm.startLag = startLag;
  sm = class(sm,'stochasticModel'); %construct parent 'stochasticModel' class
else
  error('Object instantiation for stochasticModel class is incorrect!');
end