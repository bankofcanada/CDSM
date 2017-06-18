%% generateScenarios_new.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This script is run for the GENERATING SCENARIOS step of the model. It generates combined macroeconomic and interest rate scenarios, to evaluate the cost and risk of different financing strategies in the DEBT CHARGE ENGINE step.


%% Policy Inputs
% These variables are defined via internal policy decision and are set to --- here as a placeholder:
%
% * _M_LTM_ (see Part 4) : pre-defined long-term (steady-state) means for each macroeconomic variable; to use historical average (except for total inflation), set NaN
% * _nsLTM_ first three rows (see Part 5) : pre-defined long-term (steady-state) means for each Nelson-Siegel interest rate variable; to use historical average, set NaN
%

%% 1. Set the number of scenarios
N = 10000;
warning off


%% 2. Load historical macroeconomic and yield curve data
%
% See: _<loadDataUpdate.html loadDataUpdate>_
loadDataUpdate


%% 3. Save the matrix of relevant historical macroeconomic variables for VAR parameterization
% Variables used are output gap (YGAP), core inflation (CORE), overnight rate (OVNR), and potential output growth (POTGROWTH)
M = [YGAP CORE OVNR POTGROWTH]';


%% 4. Initialize a pre-set matrix of long-term means for macroeconomic variables
% For each variable, the first LTM is for parameterization and the second LTM is for simulation.
M_LTM=[  ---, --- ; ... % 4 - output gap, NaN if taken from historical average
         ---, --- ; ... % 5 - core inflation, NaN if taken from historical average
         ---, ---; ...    % 6 - overnight rate, NaN if taken from historical average
         ---, ---; ...    % 7 - potential output growth, NaN if taken from historical average
         ---, --- ];    % 8 - total inflation (cannot set historical average for this)

     
%% 5. Initialize a pre-set combined matrix of long-term means for both yield curve variables (via Nelson-Siegel) and macroeconomic variables
% For each variable, the first LTM is for parameterization and the second LTM is for simulation.
nsLTM =[    ---, ---; ...   % 1 - level, NaN if taken from historical average     
            ---, ---; ...   % 2 - slope, NaN if taken from historical average     
            ---, ---; ...   % 3 - curvature, NaN if taken from historical average   
           M_LTM    ];      % 4:8 - macroeconomic LTM's

       
%% 6. Construct 'nelsonSiegel' class where key variables for estimation and simulation will be stored
% _nelsonSiegel_ is a child class that inherits from parent class _stochasticModel_. Several variables in the _nelsonSiegel_ class are input here, and stored either directly or through parent: 
    %
    % # _'lags'_ : number of lags in the VAR(p), (p = 1, 2, or 6)
    % # _'zero_data'_ : matrix of historical zero-coupon yields
    % # _'ttm'_ : tenors associated with that matrix of yields
    % # _'macro_data'_ : matrix of historical macro data
    % # _'histT'_ : number of years of historical data
    % # _'histN'_ : granularity of historical data (monthly is 12)
    % # _'simT'_ : number of simulation years
    % # _'simN'_ : granularity of simulations (quarterly is 4)
    % # _'startLag'_ : starting values (for macro and interest rate variables) for simulation ('ltm' is pre-set or average long-term mean)
    % # _'numSims'_ : number of simulations
    %
%
% Inputs for other variables are in _nelsonSiegel_ constructor function:
    %
    % * _'parameters'_ : empty structure, will be populated with VAR parameters from 'estimate_new' method
    % * _'dim'_ : number of NS dimensions, fixed as 3
    % * _'simTenor'_ : yield curve tenors for computing term premium via NS model, fixed vector
    %
%
% Estimation and simulation processes are run through a series of methods on either the _'ns'_ or parent _'sm'_ class. Methods are functions that apply specifically to variables in this _nelsonSiegel_ or broader _stochasticModel_ class.
%     
% Variables are called via _get_ function either on _'ns'_ or _'sm'_.
%
% _See <@nelsonSiegel/nelsonSiegel.html nelsonSiegel>_

    ns = nelsonSiegel(2,Z,ttm,M,numObs/12,12,10,4,'ltm',N);


%% 7. Estimate parameters for vector autoregression (VAR) model based on historical data
% Method on _nelsonSiegel_ class, with possible option-input(s) sets:
    %
    % * _'LTM', long-term mean for variables (overrides historical average)_
    % * _'simLTM', alternate value besides long-term mean for variables to center around (here, it's the same as LTM)_
    % * _'EXO', index of any exogenous variables_
    % * _'CONTEMP', index of existing variable, new variable that is contemporaneous with it_
    %
% See: _<@nelsonSiegel/estimate_new.html estimate_new>_

ns = estimate_new(ns,'ltm',nsLTM(:,1),'simLTM', nsLTM(:,2),...                    
        'CONTEMP',[get(ns,'dim')+2],INFL);
    

%% 8. Compute and produce charts for historical risk premia
%
% See: _<matlab/historicalRiskPremia.html historicalRiskPremia>_
TT=historicalRiskPremia(ns);


%% 9. Simulate macroeconomic and yield curve variables with the VAR model
%
% See: _<@stochasticModel/simulateBig.html simulateBig>_
data=simulateBig(ns,'ltm');


%% 10. Print summary of simulation results
%
% See: _<matlab/viewSimulation.html viewSimulation>_
viewSimulation(ns,data);


%% 11. Save simulation results (to three files)
% File 1: All Simulation Results
%
% File 2: Simulated Coupons (included in File 1)
%
% File 3: Parameters from VAR Simulation
%
% See: _<@stochasticModel/saveResults.html saveResults>_
saveResults(ns,data,'../dataFiles/','ns_MMMYY');