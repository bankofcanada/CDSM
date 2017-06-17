%% saveSimulationResults.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine saves the simulation parameters and summary
% metrics for each financing strategy into a _.mat_ file. The summary
% statistics related to cost and risk are used for the optimization.


%% 1. Save results if running a restricted model ignoring financial requirements (not used)
if strcmp(s.model,'restricted') 
  disp('Using Restricted Stochastic Model');
  if strcmp(s.equi,'actual')   
    save ../results/RestActual_MMMYY m s
  elseif strcmp(s.equi,'steady-state')
    save ../results/RestSteady_MMMYY m s;
  end

  
%% 2. Save results if running a full model with financial requirements
elseif strcmp(s.model,'full')   
  if strcmp(s.equi,'actual')    %if start simulation with actual portfolio (not used)
    disp('Saving results from full stochastic model with actual portfolio.')
    save ../results/FullActual_MMMYY s m;
  elseif strcmp(s.equi,'steady-state')
    disp('Saving results from full stochastic model with ergodic portfolio.')
%     save ~/CDSM-public/results/ns/areaPortfolios/areaPortfolio_MMMYY s m;    %if running area portfolios (comment out if running traning set) 
    save(resultsFile,'s','m');     %if running a training set (comment out if running individual strategies)
  end
end	