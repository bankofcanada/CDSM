%% nelsonSiegel.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function constructs the class _nelsonSiegel_ where key variables for estimation and simulation will be stored. It is the implementation of the model proposed by Diebold and Li (2003). _nelsonSiegel_ is a child class that inherits from the parent class, _stochasticModel_. 

%% Function Syntax
function ns = nelsonSiegel(lags,Z,ttm,M,histT,histN,simT,simN,startLag,numSims)


%% Variables stored in _nelsonSiegel_
% Variables defined through parent 'stochasticModel' class:
    %
    % * _'zero_data'_ (2nd input) : matrix of historical zero-coupon yields
    % * _'ttm'_ (3rd input) : tenors associated with that matrix of yields
    % * _'macro_data'_ (4th input) : matrix of historical macro data
    % * _'histT'_ (5th input) : number of years of historical data
    % * _'histN'_ (6th input) : granularity of historical data (monthly is 12)
    % * _'simT'_ (7th input) : number of simulation years
    % * _'simN'_ (8th input) : granularity of simulations (quarterly is 4)
    % * _'startLag'_ (9th input) : starting values (for macro and interest rate variables) for simulation ('ltm' is pre-set or ergodic long-term mean)
    %
%
% Variables defined through 'nelsonSiegel' class directly:
    %
    % * _'lags'_ (1st input) : number of lags in the VAR(p), (p = 1, 2, or 6)
    % * _'numSims'_ (10th input) : number of simulations
    % * _'parameters'_ (defined in constructor) : empty structure will be populated with VAR parameters from 'estimate_new' method
    % * _'dim'_ (defined in constructor) : number of NS dimensions, fixed as 3
    % * _'simTenor'_ (defined in constructor) : yield curve tenors for computing term premium via NS model, fixed vector
    %
%
% Variables are called via _get_ function either on _'ns'_ or _'sm'_
%
% See: _<get.html get>_

%% Principal methods for _nelsonSiegel_
    % _estimate_new()_ : estimates the parameters for vector autoregression (VAR) based on historical data
    %
    % _simulate()_ : simulates the monthly macro variables and yield curve variables based on the parameterized VAR model
%
% See: _<estimate_new.html estimate_new>_, _<simulate.html simulate>_ 
    
%% 1. Construct _nelsonSiegel_ class 
%
% See: _<../@stochasticModel/stochasticModel.html stochasticModel>_
if nargin == 0; %If no inputs given, creates empty class
  ns.parameters = [];
  ns.lags = [];
  ns.numSims = [];
  ns.dim = [];
  ns.simTenor = [];
  sm = stochasticModel();
  ns = class(ns,'nelsonSiegel',sm);    
elseif isa(lags,'nelsonSiegel');
  sm=lags;
elseif nargin == 10;    %If inputs given. Defines variables specific to _nelsonSiegel_ child class.
  ns.parameters = [];   
  ns.lags = lags;   
  ns.numSims = numSims;
  ns.dim = 3;   
  ns.simTenor = [0.25 0.5 0.75 1 2 3 4 5 6 7 8 9 10 12 15 20 30 32];
  
  sm = stochasticModel(Z,ttm,M,[],histT,histN,simT,simN,startLag);  %constructor call for parent _stochasticModel_ class
  ns = class(ns,'nelsonSiegel',sm); %construct _nelsonSiegel_ class as child of _stochasticModel_  
else
  error('Object instantiation for nelsonSiegel class is incorrect!');
end