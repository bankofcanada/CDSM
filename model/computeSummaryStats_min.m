%% computeSummaryStats_min.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine populates the _m_ structure with a wide range of summary
% metrics for each strategy. They come in the following types.
%
% * _moyenne_ : average debt cost
% * _med_ : median debt cost
% * _standev_ : standard deviation of debt cost
% * _car_ : Cost-at-Risk measures
% * _DCD_ : distribution of debt costs
% * _fr_ : related to financial requirements
% * _cv_ : conditiona volatility metrics
% * _issue_ : related to issuance and maturity
% * _psm_ : portfolio summary metrices
%
% For all of these saved matrices/arrays, the number of strategies forms
% one of the dimensions.


%% 1. Debt Stock Metrics 
for j=1:s.nperiod/4
    m.stock.os(:,j,p) = mean(totalStock(:,4*(j-1)+1:4*j),2);    %average debt stock by year
end


%% 2. Cost-Related Metrics
m.moyenne(1,:,p) = mean(Year);  %average debt cost by year 
m.med(1,:,p) = median(Year);    %median debt cost by year
m.standev(1,:,p) = std(Year);   %standard deviation of debt cost by year

m.car.aCaR(1,:,p) = prctile(Year,100*s.alpha);  %absolute cost-at-risk by year at specified risk level (0.95)
m.car.rCaR(1,:,p) = m.car.aCaR(1,:,p)-m.moyenne(1,:,p); %relative cost-at-risk by year 
m.car.cCaR_y2y(1,:,p) = prctile(Year(:,2:end)-Year(:,1:end-1),100*s.alpha);     %absolute cost-at-risk of year-to-year change, by year 
m.car.crCaR_y2y(1,:,p) = m.car.cCaR_y2y(1,:,p)-mean(Year(:,2:end)-Year(:,1:end-1)); %relative cost-at-risk of year-to-year change, by year 
[mm,nn]=size(Year);             
for(j=1:nn)
  temp=sort(Year(:,j),1);
  m.car.cCaR(1,j,p)=mean(temp(s.alpha*s.nscenario:s.nscenario));    %conditional cost-at-risk 
end
m.car.rcCaR(1,:,p) = m.car.cCaR(1,:,p) - m.moyenne(1,:,p);  %relative conditional cost-at-risk
m.DCD(:,:,p)=Year;  %distribution of simulated debt costs by year


%% 3. Fiscal Metrics
%
% See: _<prob_greater.html prob_greater>_
for(j=1:s.nperiod/4)
  for jj=1:size(totalFR,3)
    totalFR1(:,j,jj)=sum(totalFR(:,(j-1)*4+1:j*4,jj)');
  end
end
m.fr.FinReq(:,:,p)=totalFR1(:,:,1); %distribution of simulated financial requirements by year
switch s.frFeedback
    case 'yes'
        m.fr.Expenses(1,:,p)=mean(totalFR1(:,:,3),1);   %distribution of realized expense by year
        m.fr.Revenues(1,:,p)=mean(totalFR1(:,:,4),1);   %distribution of realized revenue by year

        m.bar.base.mean(1,:,p) = mean(m.fr.FinReq(:,:,p));  %average financial requirement by year  
        m.bar.base.std(1,:,p)  = std(m.fr.FinReq(:,:,p));   %standard deviation of financial requirement by year
        m.bar.base.med(1,:,p)  = median(m.fr.FinReq(:,:,p));    %median financial requirement by year
        m.bar.base.aCaR(1,:,p) = prctile(m.fr.FinReq(:,:,p),100*s.alpha);   %absolute budget-at-risk by year at specified risk level (0.95)
        m.bar.base.rCaR(1,:,p) = m.bar.base.aCaR(1,:,p) - mean(m.fr.FinReq(:,:,p)); %relative budget-at-risk by year
        m.bar.base.cCaRy2y(1,:,p) = prctile(squeeze(m.fr.FinReq(:,2:end,p))-squeeze(m.fr.FinReq(:,1:end-1,p)),100*s.alpha); %absolute budget-at-risk of year-to-year change, by year 
        m.bar.base.crCaRy2y(1,:,p) = squeeze(m.bar.base.cCaRy2y(1,:,p))-...
        mean(squeeze(m.fr.FinReq(:,2:end,p))-squeeze(m.fr.FinReq(:,1:end-1,p)));    %relative budget-at-risk of year-to-year change, by year 
        m.bar.probDeficit(1,:,p) = prob_greater(m.fr.FinReq(:,:,p),0,2);    %probability of deficit, by year
end


%% 4. Conditional Volatility Metrics
%
% See: _<computeS_condVol.html computeS_condVol>_
computeS_condVol
clear totalFR totalFR1;


%% 5. Rollover Metrics
m.issue.qBillRed.mean(1,:,p)=mean(billRedemption);  %average bill maturity by quarter
m.issue.qBillRed.std(1,:,p)=std(billRedemption);    %standard deviation of bill maturity by quarter
m.issue.qBondRed.mean(1,:,p)=mean(bondRedemption);  %average bond maturity by quarter
m.issue.qBondRed.std(1,:,p)=std(bondRedemption);    %standard deviation of bond maturity by quarter

m.issue.qdetailedOut(:,:,p) = mean(Outs,3); %each sector's average outstanding by quarter
m.issue.qBillStock.mean(1,:,p) = mean(sum(Outs(1:s.nBill,:,:)),3);  %treasury bill stock by quarter
m.issue.qBondStock.mean(1,:,p) = mean(sum(Outs(s.nBill+1:s.nInst,:,:)),3);  %bond stock by quarter  
m.issue.meanIss(:,:,p) = avgIss;    %each sector's average issuance by quarter
clear issuance bondRedemption billRedemption billIssue bondIssue Outs avgIss;
clear totalStock;


%% 6. Other Portfolio Summary Metrics
% Mean fixed-debt, fixed-debt as % of GDP, ATM, and mDuration measures.
m.psm.pFF(1,:,p)=mean(fxfl,1);  %average fixed-debt ratio by quarter
m.psm.pRfPg(1,:,p) = mean(rfxPgdp,1);   %average fixed-debt (as % of GDP) by quarter
m.psm.pATM(1,:,p)=mean(ATM,1);  %average ATM by quarter
m.psm.pDuration(1,:,p)=mean(mDuration,1);   %average duration by quarter
if p==s.npoids && k==s.nscenario
    m.CPI = CPI_k(:,1:s.nperiod);   %CPI for each simulation by quarter
    m.GDP = GDP_k(:,1:s.nperiod);   %GDP for each simulation by quarter
end    
clear fxfl ATM mDuration rfxPgdp;


%% 7. Save this financing strategy in main array
m.strategy(:,:,p)=s.weight;