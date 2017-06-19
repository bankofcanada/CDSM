%% getFinancialRequirements_restr.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of the DEBT CHARGE ENGINE.

% Compute expected revenues, expenditures, debt charges, and fixed component
switch s.frFeedback
    case 'no'
        yearnow=ceil(i/4);
        f.finreq_raw(i)=s.frSurplusPerYear(yearnow)/4;
    case 'yes'
        if i==1 % If at start of simulation
          yearnow=ceil(i/4);
          f.yearExpenses(yearnow) = 0;
          f.yearRevenues(yearnow) = 0;
          f.dstock_adj(yearnow) = (s.value-s.frSurplusPerYear(yearnow)./2)./s.value;
          % Bottom two lines of s.frInitial Expenses are a debt cost projection
          s.frInitialExpenses = s.frInitialRevenues - s.frSurplusPerYear(yearnow) ...
              - s.weight(1:s.nInst-1)*s.v_dc(1:s.nInst-1)*s.value - sum(CPI(1:4).*realcost(s.nInst,1:4)) ...
              - (s.weight(s.nInst)*f.dstock_adj(yearnow)*s.value*((1.02)^15-1))/30;
          f.yearTarget(1) = -s.frSurplusPerYear(yearnow);
          % This is the lever -- fixed amount of expenditure
          f.eDC(i:i+3) = s.weight(1:s.nInst-1)*s.v_dc(1:s.nInst-1)*f.dstock_adj(yearnow)*s.value/4 + ...
              sum(CPI(1:4).*realcost(s.nInst,1:4))/4 + ...
              ((s.weight(s.nInst)*f.dstock_adj(yearnow)*s.value*((1.02)^15-1))/30)/4;
          f.Adjust(i:i+3) = 0; % No adjustment to expenses in restricted model
          % Revenues and Expenses held constant in restricted model
          f.expectedRevenues(i:i+3) = s.frInitialRevenues./4;
          f.expectedExpenses(i:i+3) = s.frInitialExpenses./4; 
        elseif mod(i-1,4) == 0  % If at beginning of year!
          yearnow=ceil(i/4);
          f.yearExpenses(yearnow) = 0;
          f.yearRevenues(yearnow) = 0;
          f.yearTarget(yearnow) = -s.frSurplusPerYear(yearnow);
          % adjustment to debt cost projection due to increasing debt level, may need
          % better projection
          f.dstock_adj(yearnow) = (mean(f.outstanding(i-4:i-1))-s.frSurplusPerYear(yearnow)./2)./mean(f.outstanding(i-4:i-1));
          f.eDC(i:i+3) = total(i-1)*f.dstock_adj(yearnow);%(sum(total(i-4:i-1))*f.dstock_adj(yearnow))/4;
          f.Adjust(i:i+3) = 0; % No adjustment to expenses in restricted model
          % Revenues & Expenses held constant in restricted model
          f.expectedRevenues(i:i+3) = (f.yearRevenues(yearnow-1))./4;
          f.expectedExpenses(i:i+3) = (f.yearExpenses(yearnow-1))./4; 
        end
        % Compute the realized expenditures, revenues and debt charges
        if i<=4 % If in the first year of simulation!
          f.Expenses(i) = (1/4)*s.frInitialExpenses;
          f.Revenues(i) = (1/4)*s.frInitialRevenues;
          if i==1
            f.finreq_raw(i) = -(f.Revenues(i)-f.Expenses(i) ...
                    - (s.weight(1:s.nInst-1)*s.v_dc(1:s.nInst-1)*f.dstock_adj(yearnow)*s.value ...
                    + sum(CPI(1:4).*realcost(s.nInst,1:4)) ...
                    + (s.weight(s.nInst)*f.dstock_adj(yearnow)*s.value*((1.02)^15-1))/30)/4 ...
                    + s.frNoiseCoef*randn);
          else
            f.finreq_raw(i) = -(f.Revenues(i)-f.Expenses(i) ...
                    - total(i-1) ...
                    + s.frNoiseCoef*randn);    
          end
        elseif i>=5   % Treatment of subsequent years
          % Adjustment to Expenses to meet Budget target in expectation
          f.Expenses(i) =(1/4)*(f.yearRevenues(yearnow-1)-s.frSurplusPerYear(yearnow))-f.eDC(i);
          f.Revenues(i) = (1/4)*f.yearRevenues(yearnow-1);
          f.finreq_raw(i) = f.Expenses(i)-f.Revenues(i) + total(i-1) ...
              + s.frNoiseCoef*randn;
        end
        f.yearExpenses(yearnow) = f.yearExpenses(yearnow)+f.Expenses(i);
        f.yearRevenues(yearnow) = f.yearRevenues(yearnow)+f.Revenues(i);
end        
        
% Funding requirement
f.finreq=f.finreq_raw;

% Determine the total amount of debt (useful as balance check)
if i==1
  f.outstanding(i)=f.outstanding(i)+f.finreq(i);
elseif i~=1
  f.outstanding(i)=f.outstanding(i-1)+f.finreq(i);
end


