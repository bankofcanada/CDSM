%% optMeth.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function produces the parameters for general functions of cost, risk (for the given
% risk metric), and rollover for any financing strategy. This is done by curve-fitting the cost, risk, and rollover
% measures for the training set strategies on their instrument allocations, via OLS.


%% Function Syntax
function [fhat ghat rollhat] = optMeth(mt,x,f,g,rc,resultName,cost,dF_str,roll,roll_overlay)
%%
% _mt_ : non-parametric model used for estimating, OLS is standard
%
% _x_ : instrument allocation for all strategies in training set
%
% _f_ : cost measure for all strategies in training set
%
% _g_ : risk measure for all strategies in training set
%
% _rc_ : risk constraint (not used with OLS)
%
% _resultName_: name of result file being generated (not used with OLS)
%
% _cost_ : cost setting (not used with OLS)
%
% _dF_str_ : NULL
%
% _roll_ : rollover measure for all strategies in training set
%
% _roll_overlay_ : set to 0 here, no rollover as second risk constraint


%% 1. Curve-fit general functions of cost and risk with training set results, using MARS (not used)
switch mt   
        case 'mars' %if MARS method is used; since MARS takes a long time, will first check for saved runs using the same training set
        % Cost
        fileName = strcat('mars_',cost,dF_str,resultName);
        try
            eval(['load ../optimize/curveFits/',fileName]);
        catch
            fhat = train(mars(), x, f); % usually Debt Charges
            eval(['save ../optimize/curveFits/',fileName,...
     ' fhat'])
        end
        %Risk
        fileName = strcat('mars_',rc,resultName);
        try
            eval(['load ../optimize/curveFits/',fileName]);
        catch
            ghat = train(mars(), x, g); % roll constraint
            eval(['save ../optimize/curveFits/',fileName,...
     ' ghat'])
        end
        % Rollover overlay, if necessary
        if roll_overlay == 1    
            fileName = strcat('mars_roll',resultName);
            try
                eval(['load ../optimize/curveFits/',fileName]);
            catch
                rollhat = train(mars(), x, roll); % risk constraint
                eval(['save ../optimize/curveFits/',fileName,...
            ' rollhat'])
            end
        else
            rollhat=[];
        end
 
        
%% 2. Curve-fit general functions of cost and risk with training set results, using OLS
%
% See: _<np_regression\@OLS\train.html train>_, _<np_regression\@OLS\OLS.html OLS>_
    case 'OLS'  %if OLS method is used (standard)
        fhat = train(OLS(), x, f); % approximate a general function of cost (on any allocation)
        ghat = train(OLS(), x, g); % approximate a general function of risk (on any allocation)
    if roll_overlay == 1    
        rollhat = train(OLS(), x, roll); % approximate a general function of rollover (on any allocation)
    else
        rollhat = []; 
    end
end