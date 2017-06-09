%% initS.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine loads the main settings for the debt charge
% engine. The majority of inputs that are updated between model runs, including several user-specific policy inputs, are defined here.


%% Policy Inputs
% These variables are defined via internal policy decision and are set to --- here as a placeholder:
%
    % * _s.issueFeedback_ (see Part 2) : whether to include penalty
    % functions, i.e. additional cost for issuance amounts outside of
    % allowable range ('yes' or 'no')
    % * _s.value_ (see Part 3): steady-state debt stock (above 0) 
    % * _s.initialGDP_ (see Part 3): initial GDP (above 0) 
    % * _s.frExpensesCoef_ (see Part 3) : coefficients on macro variables in expenses growth equation (see Robbins, Torgunrud, and Matier (2007) for details) 
    % * _s.frRevenuesCoef_ (see Part 3) : coefficients on macro variables in revenues growth equation (see Robbins, Torgunrud, and Matier (2007) for details)
    % * _s.frInitRevenues_ (see Part 3) : initial revenues in steady-state (above 0)


%% 1. Primary Settings
s=struct('npoids',250);	      % Number of financing strategies
s.nperiod = 40;	              % Number of periods (quarters) to evaluate
s.nscenario = 4000;           % Number of scenarios, out of generated, to use

s.nBill = 3;        % Number of treasury bill instruments (3m, 6m, 12m)
s.nNomBnds = 6;     % Number of nominal bond instruments (2Y, 3Y, 5Y, 7Y, 10Y, 30Y)
s.nNomInst = s.nBill + s.nNomBnds;   
s.nRRB = 4;         % Number of real return bond instruments (2Y RRB, 5Y RRB, 10Y RRB, 30Y RRB)
s.nBnds = s.nNomBnds + s.nRRB; s.nInst = s.nBill + s.nBnds;

s.model='full';	              % 'full' : use macro variables and account for fiscal rules
                              % 'restricted' : ignore macro variables and fiscal rules, i.e. actual and expected budget always the same (not used)
s.equi='steady-state';	      % 'actual' : start at pre-defined current actual portfolio (not used)
                              % 'steady-state' : start at steady-state portfolio

                              
%% 2. Secondary Settings
s.frFeedback='yes';           % setting for financial requirements feedback, can be employed with 'full' only                     
s.npma=8;                     % Number of periods in moving average for financial requirements feedback
%s.tolerance=---;           % Maximum change in the debt stock each quarter (not used)			      
s.frFeedbackType='quarterly'; % Frequency of prediction: annual or quarterly


%% 3. Fiscal and Instrument-Related Settings
%
% See: _<initSpenF_wts.html initSpenF_wts>_

s.value = ---;                % Initial debt stock (in $B), steady-state stock if surplus set to 0
s.initialGDP= ---;            % Initial GDP (in $B)
s.alpha=0.95;                 % Cut-off for percentile calculations (e.g. CaR)
s.stressTesting='no';         % 'yes' for stress-testing, 'no' otherwise; adds a third 'extreme' state to Markov chain
s.issueFeedback='---';        % 'yes' for feedback between issue size and cost (penalty functions), 'no' otherwise 

if(strcmp(s.issueFeedback,'yes'))
initSpenF_wts;  % Define parameters for penalty functions (adjusted cost for over/under-issuance)
end

s.Reopenings = [ 1 2 2 4 4 8 1 2 4 8];  % number of re-openings for each sector
s.terms = 4*[1/4; 1/2; 1; 2.25; 3; 5.25; 7.25; 11; 29; 2; 5; 10; 30];   % TTM of each sector (in quarters)
s.maxMat = max(s.terms);    % maximum instrument TTM (in quarters)
%s.realrate = ---;  %not used

s.fiscalTarget = 0; % fiscal target for computing financial requirements
s.fixedBudget=0;    % fixed component of the budget
%s.debtChangeTolerance = [--- ---]; % minimum and maximum ratio (percent/100) of debt stock change tolerated (not used)
%s.billPercentage= [--- --- ---]; % relative weights of the treasury bills in the actual portfolio (not used)

s.realFlag=0;   %old debt taken on nominal or real basis
s.varLag = 1;   

s.frExpensesCoef = [  ---; ---; ---; ---; --- ];    %coefficients on [real GDP growth; lagged inflation; inflation; lagged change in short rate; change in short rate]
s.frRevenuesCoef = [  ---; ---; ---; ---; --- ];    %coefficients on [real GDP growth; lagged inflation; inflation; lagged change in short rate; change in short rate]
s.frSurplusPerYear = zeros(1,s.nperiod/4);  % Desired surplus, or equivalently debt paydown, per year (in $B)

s.frInitialRevenues = ---;      %initial revenues
s.frPreviousYrCoef = 0;
s.frNoiseCoef = 0;          %size of random fiscal shocks
s.frObjective='balanced';   %'surplus' or 'balanced'