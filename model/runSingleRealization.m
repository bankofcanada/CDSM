%% runSingleRealization.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine, called for each financing strategy under each scenario,
% evaluates the given strategy under the given scenario. This is done by
% computing financial requirements, issuance amounts, debt costs, and
% portfolio summary measures, in order, for each quarter.


%% 1. Set up values for CPI, GDP, and coupons
CPI(1) = ((1+X0(1,s.dim+5,k))^(1/4));   %CPI is set to be 1 at start, so CPI in first quarter is just (1 + inflation) converted quarterly
GDP(1) = s.initialGDP;  %Initial GDP defined in settings
meanCPI = (1+mean(X0(:,s.dim+5,k)))^(1/4);  %average inflation from scenario 
meanGDP = (1+mean(X0(:,s.dim+6,k)));    %average GDP growth from scenario


for tt = 2:s.nperiod + s.maxMat
    %For each quarter in horizon, compute CPI and GDP based on the value
    %last quarter and the relevant macro variable this quarter (inflation
    %and GDP growth)
  if tt<=s.nperiod
    CPI(tt) = CPI(tt-1)*( (1+X0(tt,s.dim+5,k))^(1/4) ); 
    GDP(tt) = GDP(tt-1)*( (1+X0(tt,s.dim+6,k)));
    %For quarters beyond horizon, inflation and GDP growth assumed to be
    %average from scenario
  else
    CPI(tt) = CPI(tt-1)*meanCPI;
    GDP(tt) = GDP(tt-1)*meanGDP;
  end
end
clear meanCPI meanGDP

flatCPI(1:s.nNomInst,:)=ones(s.nNomInst,120);   
flatCPI(s.nNomInst+1:s.nInst,:)=kron((1+LTM(s.dim+5)).^linspace(0.25,30,120),ones(4,1));    %Compute CPI assuming inflation constant at long-term mean

scen(1:s.nNomInst,:)=squeeze(coupon(k,:,1:s.nperiod));  %nominal bond coupons each quarter
scen(s.nNomInst+1:s.nInst,:)=squeeze(realcoupon(k,[1 2 3 4],1:s.nperiod));  %real return bond coupons each quarter


%% 2. Initialize matrices to store results
totalcost=zeros(s.nInst,s.nperiod);     % totalcost is the "accrual" cost of all the new debt for every quarter. (check) 

t.cash=zeros(1,s.nperiod);  
t.maturity=o.initialmaturity; 
t.maturityReal = [o.initialmaturity(1:s.nNomInst,:); [o.initialmaturityReal(s.nNomInst+1:s.nInst,:) zeros(4,s.nperiod)] ];
n.maturity = zeros(s.nInst,s.nperiod + s.maxMat);
n.maturityReal = zeros(s.nInst,s.nperiod + s.maxMat);
n.newaccrual = zeros(s.nInst,s.nperiod + s.maxMat);
realcost=zeros(s.nInst,s.nperiod + s.maxMat);
realcost(s.nNomInst+1:s.nInst,1:120) = o.initialaccrualReal(s.nNomInst+1:s.nInst,1:120);    %include costs of old RRBs in matrix of new debt costs for ease of computation (since those values will change from quarter-to-quarter due to inflation uplift)

f.outstanding=s.value.*ones(1,s.nperiod);
f.dstock_adj = ones(1,s.nperiod/4);


%% 3. Evaluate each simulated quarter
% The following are computed for each quarter, in order:
% 
% * (1) financial requirements
% * (2) issuance amounts
% * (3) debt costs
% * (4) portfolio summary measures
%
% The evaluation for each quarter is based on the scenario information and the results from previous quarters.
%
% See: _<getFinancialRequirements.html getFinancialRequirements>_,
% _<issuanceProcess.html issuanceProcess>_, _<computeDebtCharges.html
% computeDebtCharges>_, _<portfolioSummaryMeasures1.html
% portfolioSummaryMeasures1>_

for i=1:s.nperiod   %loop across all quarters
  % Compute financial requirements for this quarter
  getFinancialRequirements;
  % Compute issuance amounts for this quarter, and update future maturing amounts accordingly
  issuanceProcess;
  % Compute debt costs for this quarter
  computeDebtCharges;
  % Compute portfolio summary metrics
  portfolioSummaryMeasures1;
end


%% 4. Aggregate and store key variables

avgIss = ((k-1)/k)*avgIss + (1/k)*n.issuance(:,1:s.nperiod);

%Store variables describing financial requirements in each quarter
totalStock(k,:)=f.outstanding;
totalFR(k,:,1)=f.finreq;
totalFR(k,:,2)=f.finreq_raw;
totalFR(k,:,3)=f.Expenses;
totalFR(k,:,4)=f.Revenues;
totalFR(k,:,5)=f.expectedExpenses;
totalFR(k,:,6)=f.expectedRevenues;
totalFR(k,:,7)=f.eDC;
totalFR(k,:,8)=f.Adjust;

nominalStock(k,:) = sum(n.nominalMaturity,1)+t.cash;    %matrix of total debt stock for each quarter (for each scenario)
realStock(k,:) = (sum(n.nominalMaturity(1:s.nNomInst,:),1)+t.cash)./CPI(1:s.nperiod) + ...
    sum(t.maturity(s.nNomInst+1:s.nInst,1:s.nperiod))./CPI(1:s.nperiod);    %debt stock in real terms

for j=1:(s.nperiod/4)
  Year(k,j) = sum(total(4*j-3:4*j));        %matrix of debt cost for each year (for each scenario)    
  RRBCpn(k,j) = sum(totalRealCpn(4*j-3:4*j));   %total yearly RRB coupons
  RRBPrn(k,j) = sum(totalRealPrn(4*j-3:4*j));   %total yearly outflows for RRB principal uplift
end

Outs(:,:,k) = t.detailedoutstanding;    %3D array of outstanding amount by sector each quarter (for each scenario)

if s.realFlag==1;   %adjust values to real terms if setting on (not used)
  Year(k,:) = Year(k,:)./CPI(linspace(1,s.nperiod/4,s.nperiod/4)*4);
  for w=1:size(totalFR,3)
    totalFR(k,:,w)=totalFR(k,:,w)./CPI(linspace(1,s.nperiod,s.nperiod));
  end
  totalStock(k,:) = totalStock(k,:)./CPI(linspace(1,s.nperiod,s.nperiod));
end