%% getFinancialRequirements.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine (on _runSingleRealization.m_) computes the financial requirement for the given quarter
% (under the given scenario for the given strategy), which is included in that
% quarter's debt issuance needs in _issuanceProcess.m_. 
%
% That computation uses as inputs that quarter's realized revenues/expenses/debt costs
% as well as the fixed annual lever of additional expenditures - which is defined at the start of year such that the annual fiscal target is achieved in
% expectation. That lever is also computed (annually, as part of each Q1
% computation) as part of this subroutine. 
% The equations, in short, are:
    %
    % * Financial Requirement (quarterly) = Realized Revenues (quarterly) - Realized Expenses (quarterly) - Realized Debt Costs (quarterly) - Lever/4
    % * Fiscal Target (annual) = Expected Revenues (annual) - Expected Expenses (annual) - Expected Debt Costs (annual) - Lever
    %
% The growth of revenues and expenses is governed by an equation on several simulated macro variables (which are converted from a quarterly to annual basis). 
%
% Here, the problem is simplified by assuming a balanced budget with no shocks. 


%% 1. Compute fiscal lever from expected revenues, expenses, and debt costs (if at the start of first year) 
%
% See: _<realizedMacro.html realizedMacro>_

if i==1 % If at start of simulation
  realizedMacro;    %load realized macroeconomic variables (file carries over for later quarters' calculations)
  rMacroAll(:,:,k)=rMacro;
  yearnow=ceil(i/4);    %year of simulation: 1, 2, ..., 10
  f.yearExpenses(yearnow) = 0;  %expenses/revenues start off at 0 each year (is added on to each quarter)
  f.yearRevenues(yearnow) = 0;
  
  % Initial expenses set to give target surplus (0 here), based on initial revenues and last year's estimated debt cost (i.e. cost on old debt)
  s.frInitialExpenses = s.frInitialRevenues - s.frSurplusPerYear(yearnow) ...
      - s.weight(1:s.nInst-1)*s.v_dc(1:s.nInst-1)*s.value - sum(CPI(1:4).*realcost(s.nInst,1:4)) ...
      - (s.weight(s.nInst)*s.value*((1.02)^15-1))/30;   
  
  % Coefficients on macro variables in equation for annual expense/revenue level growth (equals: last year's expenses/revenues x coefficients in equation for annual percentage growth)
  expensesGrowth = s.frInitialExpenses*s.frExpensesCoef;    
  revenuesGrowth = s.frInitialRevenues*s.frRevenuesCoef;    
  
  % Set this year's fiscal target to reach target surplus, including any catch-up required (all variables 0 here)
  f.FRdiscrep(1) = 0;   %difference between last year's fiscal target and realization
  f.yearTarget(1) = -s.frSurplusPerYear(yearnow) - f.FRdiscrep(1)*s.frPreviousYrCoef;
  
  % Compute the lever (_f.Adjust_): i.e. fixed additional expenditure to commit to this year in order to reach target fiscal balance (revenues + expenses - debt cost, 0 here) in expectation
  f.dstock_adj(yearnow) = (s.value-s.frSurplusPerYear(yearnow)./2)./s.value;    %adjust first year's debt stock for surplus/deficit
  f.eDC(i:i+3) = s.weight(1:s.nInst-1)*s.v_dc(1:s.nInst-1)*f.dstock_adj(yearnow)*s.value/4 + ...
      sum(CPI(1:4).*realcost(s.nInst,1:4))/4 + ...
      ((s.weight(s.nInst)*f.dstock_adj(yearnow)*s.value*((1.02)^15-1))/30)/4;   %expected debt costs for first year (based on adjusted stock) 
  f.Adjust(i:i+3) = f.yearTarget(1)  ...
       - s.weight(1:s.nInst-1)*s.v_dc(1:s.nInst-1)*f.dstock_adj(yearnow)*s.value - sum(CPI(1:4).*realcost(s.nInst,1:4)) ...
      - (s.weight(s.nInst)*f.dstock_adj(yearnow)*s.value*((1.02)^15-1))/30 ...
      + s.frInitialRevenues - s.frInitialExpenses ...
      + sum(eMacro(i:i+3,:,k)*(revenuesGrowth-expensesGrowth)) ;    %Lever = Fiscal Target (annual) + Expected Revenues - Expected Expenses - Expected Debt Costs 
  
  % At the start of year, sum the expected (quarterly-basis) macro variables for all 4 quarters and apply that to the annual growth
  % equation to get that year's expected revenues/expenses. Then distribute that evenly across quarters.
  f.expectedRevenues(i:i+3) = (s.frInitialRevenues + ...
                      sum(eMacro(i:i+3,:,k)*(revenuesGrowth)))./4;
  f.expectedExpenses(i:i+3) = (s.frInitialExpenses + ...
                      sum(eMacro(i:i+3,:,k)*(expensesGrowth)) ...
                      + f.Adjust(i:i+3))./4;  
                  
                  
%% 2. Compute fiscal lever from expected revenues, expenses, and debt costs (if at the start of a subsequent year)
elseif mod(i-1,4) == 0  % If the first quarter of a year
  yearnow=ceil(i/4);
  f.yearExpenses(yearnow) = 0;  %expenses/revenues start off at 0 each year (is added on to each quarter)
  f.yearRevenues(yearnow) = 0;
  
  %Coefficients on macro variables in equation for annual expense/revenue level growth
  expensesGrowth = f.yearExpenses(yearnow-1)*s.frExpensesCoef;
  revenuesGrowth = f.yearRevenues(yearnow-1)*s.frRevenuesCoef;
  
  % Set this year's fiscal target to reach target surplus, including any catch-up required (all variables 0 here)
  f.FRdiscrep(yearnow) = sum(f.finreq(i-4:i-1))-f.yearTarget(yearnow-1);   
  f.yearTarget(yearnow) = -s.frSurplusPerYear(yearnow) ...
      - s.frPreviousYrCoef*f.FRdiscrep(yearnow);
  
  % Compute the lever (_f.Adjust_): i.e. fixed additional expenditure to commit to this year in order to reach target fiscal balance (revenues + expenses - debt cost, 0 here) in expectation
  f.dstock_adj(yearnow) = (mean(f.outstanding(i-4:i-1))-s.frSurplusPerYear(yearnow)./2)./mean(f.outstanding(i-4:i-1));  %adjust this year's debt stock for surplus/deficit  
  f.eDC(i:i+3) = total(i-1)*f.dstock_adj(yearnow);  %expected debt costs for that year
  f.Adjust(i:i+3) = f.yearTarget(yearnow) ...
      - f.yearExpenses(yearnow-1)+f.yearRevenues(yearnow-1) ...
      -total(i-1)*4*f.dstock_adj(yearnow) ... 
      + sum(eMacro(i:i+3,:,k)*(revenuesGrowth-expensesGrowth)); %Lever = Fiscal Target (annual) + Expected Revenues - Expected Expenses - Expected Debt Costs  

  % At the start of year, sum the expected (quarterly-basis) macro variables for all 4 quarters and apply that to the annual growth
  % equation to get that year's expected revenues/expenses. Then distribute that evenly across quarters.
  f.expectedRevenues(i:i+3) = (f.yearRevenues(yearnow-1) + ...
                      sum(eMacro(i:i+3,:,k)*(revenuesGrowth)))./4;
  f.expectedExpenses(i:i+3) = (f.yearExpenses(yearnow-1) + ...
                      sum(eMacro(i:i+3,:,k)*(expensesGrowth)) ...
                      + f.Adjust(i:i+3))./4;                  
end


%% 3. Compute this quarter's financial requirements based on realized revenues/expenses, last quarter's debt cost, and fiscal lever (if in first year)
if i<=4 %if in the first year of simulation
    
    % Actual revenues/expenses that quarter based on growth equation using last year's revenues/expenses and realized macro variables 
  f.Expenses(i) = f.Adjust(i)/4 + (1/4)*s.frInitialExpenses...
      +rMacro(i,:)*(expensesGrowth) ;
  f.Revenues(i) = (1/4)*s.frInitialRevenues...
      +rMacro(i,:)*(revenuesGrowth) ;
  
    % Financial Requirements = Realized Revenues - Realized Expenses - Realized Debt Costs - Lever
  if i==1   %if first quarter of simulation, debt costs for previous quarter based on estimates on old debt
    f.finreq_raw(i) = -(f.Revenues(i)-f.Expenses(i) ...
			- (s.weight(1:s.nInst-1)*s.v_dc(1:s.nInst-1)*f.dstock_adj(yearnow)*s.value ...
			+ sum(CPI(1:4).*realcost(s.nInst,1:4)) ...
			+ (s.weight(s.nInst)*f.dstock_adj(yearnow)*s.value*((1.02)^15-1))/30)/4 ...
			+ s.frNoiseCoef*randn);
  else  %if after first quarter, actual debt costs last quarter are known
    f.finreq_raw(i) = -(f.Revenues(i)-f.Expenses(i) ...
			- total(i-1) ...
			+ s.frNoiseCoef*randn);    
  end
  
  
%% 4. Compute this quarter's financial requirements based on realized revenues/expenses, last quarter's debt cost, and fiscal lever (if in a later year)  
elseif i>=5  %if after first year
    
    % Financial Requirements = Realized Revenues - Realized Expenses - Realized Debt Costs - Lever
  f.Expenses(i) = f.Adjust(i)/4 + (1/4)*f.yearExpenses(yearnow-1)...
      +rMacro(i,:)*(expensesGrowth)  ;
  f.Revenues(i) = (1/4)*f.yearRevenues(yearnow-1) ...
      + rMacro(i,:)*(revenuesGrowth);
  f.finreq_raw(i) = f.Expenses(i)-f.Revenues(i) + total(i-1) ...
      + s.frNoiseCoef*randn;
end

    % Update value for this year's revenues/expenses
f.yearExpenses(yearnow) = f.yearExpenses(yearnow)+f.Expenses(i);
f.yearRevenues(yearnow) = f.yearRevenues(yearnow)+f.Revenues(i);

%f.finreq_raw(i) = 0;   %option to manually set financial requirements to zero
f.finreq=f.finreq_raw;  %official financial requirements


%% 5. Update outstanding debt stock for financial requirements
if i==1
  f.outstanding(i)=f.outstanding(i)+f.finreq(i);
elseif i~=1
  f.outstanding(i)=f.outstanding(i-1)+f.finreq(i);
end
