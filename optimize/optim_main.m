%% optim_main.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This script is run for the PRODUCE EFFICIENT FRONTIER step of the model.
% It uses the simulated training set of financing strategy evaluations (from DEBT
% CHARGE ENGINE) to curve-fit general functions of cost and risk for any
% strategy, and uses those functions to define an efficient frontier of
% cost-risk trade-off (between efficient strategies).
%
% The optimization is done only over the 9 relevant instruments (as defined in _inst_), rather than the total from the training set. 


%% Policy Inputs
% These variables are defined via internal policy decision and are set to --- here as a placeholder:
%
% * _issConst_ (see Part 1) : minimum issuance constraints by instrument, in % terms (each term between 0 and 1, sum is less than 1)
% * _rc_ (see Part 1) : choice of risk measure to use in optimization (string, see _riskCon.m_ for common measures) 
% * _k_, _endcon_, _step_ (see Part 4): starting value, ending value, and interval of risk points evaluated for optimization 
%


%% 1. Specify instruments, constraints, risk measure, and other settings

inst = [ 1 2 3 4 5 6 8 9 13];   %index of relevant sectors
nInst = size(inst,2);
issConst = - [ --- --- --- --- --- --- --- --- ---];   %minimum issuance constraint for each instrument

path('../results/ns/',path)

resultName= '_MMMYY_vname_block';    %name of result files
mt = 'OLS';  % model used to curve-fit general cost/risk functions for strategies
rc = '---'; % risk metric used for the efficient frontier
ic = 'IC'; % issuance constraints on or off ('IC' or 'noIC')

cost = 'percent';   % define settings for name of saved file 
dF = []; 
dF_str = num2str(dF*100);
techstr = strcat(mt,'_',cost,dF_str,'_',rc,'_',ic);

roll_overlay = 0;	%rollover as a second constraint in optimization (not done here)
roll_overlay_value = [];
fileAdd = strcat(resultName,techstr,num2str(roll_overlay_value));


%% 2. Load file with training set results
% Contains structure _s_ with model parameters and _m_ with summary metrics
eval(['load ../results/ns/trainingSets/policyResults_policyPort',resultName,'_all']); 


%% 3. Define cost and risk metrics for each financing strategy (from training set results)
%
% See: _<costMeasure.html costMeasure>_

dstock = mean(m.totalStockYrmean,2);    %average debt stock for each year (across strategies)
riskC.dstock = mean(dstock(6:10));  %average debt stock in Year 6-10 (across strategies)
x = m.strategy(inst,:)';    %matrix of all debt strategies (with only issued instruments)
f = costMeasure(cost,dF,m.percentCharges.avg,m.moyenne);    %vector of cost measures for each strategy
riskC.roll = mean(m.issue.qBondRed.mean + m.issue.qBillRed.mean)';  %define rollover (average quarterly maturity) as a risk metric 
riskC.refix_pct_gdp = mean(m.psm.pRfPg,1)'; %define refixing debt as a risk metric (not used) 
riskC.cv = m.cv;    %define conditional cost volatility as a risk metric    

g = riskCon(rc,riskC);  %vector of risk measures for each strategy


%% 4. Define points of efficient frontier
%
% The efficient frontier is produced by finding the minimum-cost strategy
% for each risk level. Thus, setting the lower bound (_k_), upper bound (_endcon_), and granularity (_step_) of the
% risk levels gives the points to evaluate to determine the frontier.

k = ---;    %lower bound of risk level
endcon = ---; %upper bound of risk level
step = ---;   %step size between risk level points to evaluate
par = [ k endcon step];
last = ((endcon-k)/step) + 1;	%number of risk level points evaluated  


%% 5. Curve-fit general functions of cost and risk
%
% See: _<setApproximationPaths.html setApproximationPaths>_

path(path, '../optimize/');
path(path, '../optimize/np_regression/');

setApproximationPaths   %set path for curve-fitting method of training set 
[fhat ghat rollhat] = optMeth(mt,x,f,g,rc,resultName,cost,dF_str,riskC.roll,roll_overlay);  %compute parameters of cost, risk, and rollover functions


%% 6. Produce efficient frontier
% For each value of the risk measure in the specified interval, find the
% cost-minimizing strategy which satisfies both that risk constrant (i.e. has a
% risk equal to or less than that value) as well as the minimum issuance
% constraints.
%
% The inputs to the optimization, for each risk level, via the MATLAB _fmincon_ function, are:
    %
    % * 1 (_optFunc_) : function handle for OLS-estimated cost function being minimized
    % * 2 (_x0_) : start value of optimization
    % * 3-4 (_Constraints{1:2}_) : _A_ and _b_ in _A*x <= b_ describing minimum issuance constraints
    % * 5-6 (_Constraints{3:4}_) : _Aeq_ and _beq_ in _Aeq*x = beq_ constraining allocations to sum to 1
    % * 7-8 (_Constraints{5:6}_) : _lb_ and _ub_, lower (0) and upper (1) bounds for each allocation
    % * 9 (_nonLinCon_) : _nonlcon_ non-linear constraint for risk level
    % * 10 (_options_) : options for this optimization, standard 
    %
%
% The key final outputs of the optimization for each risk level are saved in the vectors:
% _xstar_ (cost-minimizing strategy for each risk level), and _fstar_ (that
% minimum cost)
%
% It is important to restate that this optimization is finding the lowest-cost strategy across
% the entire continuous space of possible strategies (which satisfy the
% constraints), all of whose cost and risk are computed via the general
% function curve-fitted above. Besides informing that function, the specific strategies evaluated in the
% training set have no role whatsoever here.
%
% See: _<optMeth.html optMeth>_, _<constr.html constr>_,
% _<np_regression/OLS/predict.html predict>_, _<objective/nonLinearConstraint.html nonLinearConstraint>_


% Define function handle for function being optimized, with the fitted OLS model (i.e. general cost/risk functions) being passed in as an argument
optFunc = @(x) predict(fhat,x); 

rcq = [riskC.roll/dstock];  %not used 

% Create cell array of minimum issuance constraints
[Constraints x0] = constr(ic,nInst,issConst);

% Set options for optimization (standard)
options = optimset('MaxIter', 2000, 'MaxFunEvals', 5000, 'Display', 'off', ...
    'LargeScale', 'off', 'TolFun', 1e-8, 'TolCon', 1e-8);   

% Optimize cost for each risk value point
for i =1:round(last)    
   if roll_overlay == 1         %if rollover is used as an additional constraint (not used)
         nonLinCon = @(x) nonLinearConstraint2(x,[1 1],[ghat rollhat],[k roll_overlay_value]);
         [xstar(:,:,i), fstar(i), e_flag(i), output(i), lambda(i)]= ...
             fmincon(optFunc, x0,Constraints{:},nonLinCon,options); 
   elseif roll_overlay == 0     %rollover here is not used as an additional constraint  
       nonLinCon = @(x) nonLinearConstraint(x,ghat,k);
        [xstar(:,:,i), fstar(i), e_flag(i), output(i), lambda(i)]= ...     
    fmincon(optFunc, x0,Constraints{:},nonLinCon,options);  %call _fmincon_ MATLAB function with defined inputs   
   end
    
% Save result in file and move to next risk constraint value for next optimization
     eval(['save ~/CDSM-public/results/ns/optimizationResults/optResults',fileAdd,...
     ' xstar fstar e_flag output lambda f x g par'])
    k=k+step;
end