%% initializePortfolio_new.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function produces variables describing the maturity profile of the portfolio at the start of the simulation (i.e. old debt) for the given financing strategy.
%
% This is run either under the 'steady-state' (assume the strategy had been in place in the indefinite past) or 'actual' (use the current portfolio) setting.


%% Function Syntax
function [s,o,n,t,f,ttm]=initializePortfolio_new(s,u,LTM,n)
%%
%
% _s_ : structure containing simulation parameters, updated
%
% _u_ : structure containing utility matrices, updated
%
% _LTM_ : long-term mean values for each macroeconomic
%
% _n_ : structure containing information on new debt, updated
%
% _o_ : structure containing information on old debt, created and updated
%
% _t_ : structure containing information on total debt, created and updated
%
% _f_ : structure containing information on financial requirements, created and updated
%
% _ttm_ : variable for time-to-maturity


%% 1. If 'actual' setting, load maturity profile of actual current debt portfolio (not used)

if strcmp(s.equi,'actual')    
  currentPortfolio_MMMYY    % This setting is not used


%% 2. If 'steady-state' setting, create maturity profile assuming this strategy had been in place for the indefinite past
%
% In steady-state, distribution of initial outstanding debt across sectors is same as target allocation

elseif strcmp(s.equi,'steady-state')

    
%% 2A. (for 'steady-state') Distribute maturities of old debt over simulation horizon 
  o=struct('initialmaturity',zeros(s.nInst,s.nperiod+s.maxMat));    %Initialize matrix

    %Distribute treasury bill maturities evenly, based on sector, across first year
  o.initialmaturity(1,1)=s.value*s.weight(1);   %3-month bills
  o.initialmaturity(2,1:2)=s.value*s.weight(2)/2;   %6-month bills
  o.initialmaturity(3,1:4)=s.value*s.weight(3)/4;   %12-month bills

    %Distribute bond maturities evenly across the maturity quarters, based on re-opening pattern as defined via utility matrix
  for j=1:s.nBnds;
    o.initialmaturity(j+3,u.matQuarter(j):s.Reopenings(j):u.numPeriods(j)...
		      +u.matQuarter(j)-s.Reopenings(j))= ...  
	s.value*s.weight(j+3)/(u.numPeriods(j)/s.Reopenings(j));  
  end

    %Compute initial outstanding in each sector based on maturity amounts
  for i=1:s.nperiod+s.maxMat
    o.initialoutstanding(:,i)= sum(o.initialmaturity(:,(i+1):end),2);
  end
  
  
%% 2B. (for 'steady-state') Apply penalty function to adjust interest rates on old debt, for issuance amounts above or below allowable range 
  
  pWts = s.value.*s.weight;
  weitomat=[1 2 4 8 12 20 28 40 120 8 20 40 120];
  aveQIssue = pWts./weitomat;   %Quarterly issuance of old debt (based on steady-state target)
  s.v1 = s.v;   %Coupon rate on old debt (estimated as average from scenarios)
  
  switch s.issueFeedback    
      case {'yes'}  %Apply penalty function only if 's.issueFeedback' is 'yes'         
     for(j=1:s.nInst)
         
        if aveQIssue(j) < s.issueRanges(j,1)    % Issuance below the minimum issuance range (increase coupon)
          s.v1(j)=s.v1(j)+s.penFactor(j)*(s.m1(j)*((s.issueRanges(j,1)-...
                aveQIssue(j)).^2))/1e4;  
        elseif aveQIssue(j) >= s.issueRanges(j,1) & aveQIssue(j) <= s.issueRanges(j,2)  % Within the allowable range (no penalty)
          s.v1(j)=s.v1(j);
          
        elseif aveQIssue(j) > s.issueRanges(j,2)    % Issuance above the minimum issuance range (increase coupon)    
          s.v1(j)=s.v1(j)+s.penFactor(j)*(s.beta(1,j)+...
              + s.beta(2,j)*aveQIssue(j)...
              + s.beta(3,j)*(aveQIssue(j).^2))/1e4;
        end
      end
  end
  
  
%% 2C. (for 'steady-state') Compute quarterly costs on old debt 
  icost=s.v1./4;    %estimated quarterly coupon rate on old debt
  icost=icost';

  for i=1:s.nperiod+s.maxMat
    o.initialaccrual(:,i)=icost'.*o.initialoutstanding(:,i);    %compute quarterly interest costs on old debt based on coupon rates and O/S amount
  end

  if s.realFlag==1;     
    o.initialmaturityReal=o.initialmaturity(:,1:s.maxMat);  %treat old debt on nominal basis (not used)
    o.initialaccrualReal=o.initialaccrual(:,1:s.maxMat);
  else

    for j=s.nNomInst+1:s.nInst  %compute inflation-adjusted maturing and coupon amounts for old real return bonds, assuming historical inflation was constant at long-term mean
      for i=1:weitomat(j)
        o.initialmaturityReal(j,i)=...
            o.initialmaturity(j,i)*((1+LTM(s.dim+5))^((weitomat(j)-i)/4));

        o.initialaccrualReal(j,i)=sum(icost(j)*aveQIssue(j)*(1+LTM(s.dim+5))...
				.^((1:weitomat(j)-i)/4)  );
      end
    end
  end
  o.totalinitialoutstanding=sum(o.initialoutstanding);  %total initial outstanding of all sectors
end


%% 3. Initialize variables to be used in strategy evaluation
n.issuance=zeros(s.nInst,s.maxMat+s.nperiod);   %amount of issuance each simulated quarter
ttm=linspace(1,s.maxMat,s.maxMat);  %vector from 1 to 120, to use for computations
t.detailedoutstanding=zeros(s.nInst,s.nperiod); %amount outstanding for each sector at each simulated quarter
t.detailedoutstanding2=zeros(s.nInst,s.nperiod);
f.finreq=zeros(1,s.nperiod);    % financial requirements each simulated quarter