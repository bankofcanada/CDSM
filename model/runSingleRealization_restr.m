%% runSingleRealization_restr.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of the DEBT CHARGE ENGINE.

% TRAINING VERSION: MARCH 2007
% This sub creates the debt portfolio (and associated costs) 
% given the reopenings and financial requirements for each 
% simulated period.

% CPI is a price index with value 1.0 at time zero.
% Compute all Price Index (base is 1.0, at time i=0)
% GDP growth rate is already at a qoq rate
CPI(1) = ((1+X0(1,s.dim+5,k))^(1/4));
GDP(1) = s.initialGDP;
meanCPI = (1+mean(X0(:,s.dim+5,k)))^(1/4);
meanGDP = (1+mean(X0(:,s.dim+6,k)));
for tt = 2:s.maxMat+s.nperiod
  if tt<=40
    CPI(tt) = CPI(tt-1)*( (1+X0(tt,s.dim+5,k))^(1/4) ); 
    GDP(tt) = GDP(tt-1)*( (1+X0(tt,s.dim+6,k)));
  else
    CPI(tt) = CPI(tt-1)*meanCPI;
    GDP(tt) = GDP(tt-1)*meanGDP;
  end
end
clear meanCPI meanGDP
% Used for the ATM, duration, and fixed-debt ratio calculations
flatCPI(1:s.nNomInst,:)=ones(s.nNomInst,s.maxMat);
flatCPI(s.nNomInst+1:s.nInst,:)=kron((1+LTM(s.dim+5)).^linspace(0.25,s.maxMat/4,s.maxMat),ones(s.nRRB,1));
% coupon (s.nscenario x 7 x s.nperiod) is taken from the file Coupon.mat
scen(1:s.nNomInst,:)=squeeze(coupon(k,:,1:s.nperiod));
% coupon (s.nscenario x 4 x s.nperiod) is taken from file Real.mat
scen(s.nNomInst+1:s.nInst,:)=squeeze(realcoupon(k,[1 2 3 4],1:s.nperiod));
% totalcost is the "accrual" cost of all the new debt for every quarter.
totalcost=zeros(s.nInst,s.nperiod);
% This is a buffer for reopenings
t.cash=zeros(1,s.nperiod);
% This is critical for the application of the financing strategy
t.maturity=o.initialmaturity; 
t.maturityReal = [o.initialmaturity(1:s.nNomInst,:); [o.initialmaturityReal(s.nNomInst+1:s.nInst,:) zeros(4,s.nperiod)] ];
% A summary of the new maturities
n.maturity = zeros(s.nInst,s.maxMat+s.nperiod);
n.maturityReal = zeros(s.nInst,s.maxMat+s.nperiod);
% A summary of the new debt charges
n.newaccrual = zeros(s.nInst,s.maxMat+s.nperiod);
% Inflation-linked debt charges in time t=0 dollars
realcost=zeros(s.nInst,s.maxMat+s.nperiod);
%realcost(8:11,1:120)=o.initialaccrualReal(8:13,1:120);
realcost(s.nNomInst+1:s.nInst,1:s.maxMat) = o.initialaccrualReal(s.nNomInst+1:s.nInst,1:s.maxMat);

% Inflation-linked principal in time t=0 dollars
%t.maturityReal=zeros(11,160);
%t.maturityReal(:,1:120)=o.initialmaturityReal;

% Coupons of RRB bonds, listed according to their maturity date
% This f.outstanding is calculated from financial requirements and is
% used to see if everything fits well.
f.outstanding=s.value.*ones(1,s.nperiod);
f.dstock_adj = ones(1,s.nperiod/4);

for i=1:s.nperiod
  % Determines the funding requirement (how much to borrow)
  getFinancialRequirements_restr;
  % Here we get the amount we will issue in the next periods.
  issuanceProcess;
  % This actually calculates the amount of debt charges.
  computeDebtCharges;
  % PortfolioSummaryMeasures calculates the fixed/floating ratio and ATM.
  portfolioSummaryMeasures1;
end
%penFun_bps = ((k-1)/k)*penFun_bps + (1/k).*(scen1-scen);
avgIss = ((k-1)/k)*avgIss + (1/k)*n.issuance(:,1:40);
totalStock(k,:)=f.outstanding;
totalFR(k,:,1)=f.finreq;
totalFR(k,:,2)=f.finreq_raw;
switch s.frFeedback
    case 'yes'
        totalFR(k,:,3)=f.Expenses;
        totalFR(k,:,4)=f.Revenues;
        totalFR(k,:,5)=f.expectedExpenses;
        totalFR(k,:,6)=f.expectedRevenues;
        totalFR(k,:,7)=f.eDC;
        totalFR(k,:,8)=f.Adjust;
end
nominalStock(k,:) = sum(n.nominalMaturity,1)+t.cash;
realStock(k,:) = (sum(n.nominalMaturity(1:s.nNomInst,:),1)+t.cash)./CPI(1:s.nperiod) + ...
    sum(t.maturity(s.nNomInst+1:s.nInst,1:s.nperiod))./CPI(1:s.nperiod);
% Year is the cost of the total debt on a year basis.
for j=1:(s.nperiod/4)
  Year(k,j) = sum(total(4*j-3:4*j));
  RRBCpn(k,j) = sum(totalRealCpn(4*j-3:4*j));
  RRBPrn(k,j) = sum(totalRealPrn(4*j-3:4*j));
end

Outs(:,:,k) = t.detailedoutstanding;

if s.realFlag==1;
  Year(k,:) = Year(k,:)./CPI(linspace(1,s.nperiod,s.nperiod)*4);
  for w=1:size(totalFR,3)
    totalFR(k,:,w)=totalFR(k,:,w)./CPI(linspace(1,40,40));
  end
  totalStock(k,:) = totalStock(k,:)./CPI(linspace(1,40,40));
end

