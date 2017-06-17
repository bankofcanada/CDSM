%% main.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This script is run for the DEBT CHARGE ENGINE step of the model. It
% evaluates the cost and risk of each financing strategy (from the MAKE
% STRATEGIES step) under a subset of the economic scenarios (from the
% GENERATE SCENARIOS step). It is run once for each strategy in the
% defined block through a Linux shell script. Running this for all blocks
% produces the training set result which is used to curve-fit general functions of
% cost and risk for all strategies - which is the basis for optimization (in the PRODUCE EFFICIENT FRONTIER step).
%
% This script can also be run directly to evaluate the cost and risk of specific strategies.
%
% The inputs and results from these evaluations are stored across several
% matrix variables, which saved in one of the following structures:
%
% * _s_ : parameters of the simulation
% * _u_ : utility matrices describing debt instrument properties
% * _o_ : information on old debt (i.e. debt issued before start of simulation), overwritten with each strategy
% * _n_ : information on new debt (i.e. debt issued during simulation), overwritten with each strategy
% * _t_ : information on total debt, overwritten with each strategy
% * _f_ : information on financial requirements, overwritten with each strategy
% * _m_ : summary metrics (e.g. cost and risk) for the strategies, from simulation
%
% When analyzing the code and results, it is important to note a few key variable inputs, which determine the majority of matrix dimensions and loop sizes: 
%
% * Number of instruments (_s.nInst_) : 13 in this case (3m, 6m, 12m, 2Y,
% 3Y, 5Y, 7Y, 10Y, 30Y, 2Y RRB, 5Y RRB, 10Y RRB, 30Y RRB), note index of
% each instrument
% * Number of strategies (_s.nPoids_) : 250 in this case (block size for training set), much fewer if running individual strategies
% * Number of simulations selected (_s.nscenario_) : 4000 in this case
% * Number of quarters in simulation (_s.nPeriod_) : 40 in this case (10-year simulation)
% * Maximum instrument maturity in quarters (_s.maxMat_) : 120 in this case (30-year bond)


%% Policy Inputs
% These variables are defined via internal policy decision and are set to --- here as a placeholder:
%
% * _ports_ (see Part 3): defined individual strategies to evaluate, if setting defined (each term between 0 and 1, terms for a strategy must add to 1) 


%% 1. Set Up

% Set path
path(path,'../stochastic');
path(path,'../stochastic/matlab');
%path(path,'../practice/');
modelType = 'ns';

tic;
warning off;
randomize = 1; % Setting for how the subset of economic scenarios is selected (0 - in order, 1 - randomly)


%% 2. Load settings
% The main user-specific policy inputs are defined here.
%
% See: _<initS.html initS>_
initS;  


%% 3. Load financing strategies to evaluate.
% If running a training set, load the _strategyFile_ (name defined in Shell
% script). If running individual strategies, define the strategies manually.
%
% Each financing strategy is completely defined by a 13x1 vector describing
% the percentage allocation for each instrument in steady-state.

load(strategyFile);       %comment out if running area portfolio
%ports = [ --- --- --- --- --- --- --- --- --- --- --- --- --- ];    %[3m, 6m, 12m, 2Y, 3Y, 5Y, 7Y, 10Y, 30Y, 2Y RRB, 5Y RRB, 10Y RRB, 30Y RRB], comment out if running training set


%% 4. Load files with combined macroeconomic and interest rate scenarios
%
% See: _<loadFiles.html loadFiles>_
loadFiles;


%% 5. Set up utility matrices describing instrument properties
%
% See: _<createUtilityMatrices.html createUtilityMatrices>_

if exist('data')
  s.vZ = mean(mean(data.Z,1),3);    %average simulated rates for each tenor
  s.zterms = 4*get(mObject,'simTenor'); %vector of tenors (in terms of # of quarters)
end

% Create utility matrix describing what the TTM (in quarters) is for a given instrument in a given quarter
[u]=createUtilityMatrices(s);    
s.ttm = u.ttm;

bTime=clock;


%% 6. Evaluate the financing strategies and save results
% This is done by running a nested loop:
%
% * 1st level, across all financing strategies (indexed by _p_)
% * 2nd level, across all scenarios (indexed by _k_) for each strategy
% * 3rd level, across all quarters (indexed by _i_) in each scenario for each strategy
%
% See: _<initializePortfolio_new.html initializePortfolio_new>_,
% _<runSingleRealization.html runSingleRealization>_, _<saveIntermediateResults.html saveIntermediateResults>_, _<computeSummaryStats_min.html computeSummaryStats_min>_, _<saveSimulationResults.html saveSimulationResults>_

for p=1:s.npoids    %loop across all strategies
  s.weight= ports(p,:);     % vector of steady-state portfolio weights representing that strategy
  avgIss = zeros(13,s.nperiod);
  disp(['Financing Strategy ' num2str(p) ' --> Elapsed time: ' ...
	num2str(etime(clock,bTime)/60)]);    
  [s,o,n,t,f,ttm]=initializePortfolio_new(s,u,LTM); % create variables describing the maturity profile of the starting steady-state portfolio under that strategy  
  for k=1:s.nscenario   %loop across all scenarios (for that strategy)
    if(mod(k,1000)==0)
      disp(['   Simulation: ' num2str(k) ' --> Elapsed time: ' ...
	    num2str(etime(clock,bTime)/60)]); 
    end
    switch s.model
        case 'full'
            %Evaluate financing strategy _p_ under scenario _k_, across all quarters
            runSingleRealization    
        case 'restricted'
            runSingleRealization_restr;     %restricted model (not used)  
    end
    saveIntermediateResults;    %save key results for that scenario (for that strategy)
  end 
  computeSummaryStats_min;  %compute summary metrics for that strategy, for use in optimization
  saveSimulationResults;    %save results from evaluation
  cpuTimePerStrategy(p)=etime(clock,bTime);
end
toc;