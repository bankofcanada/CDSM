%% issuanceProcess.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine (on _runSingleRealization.m_) computes the issuance amounts by instrument in the given
% quarter (for the given scenario for the given strategy), and updates
% future maturities accordingly.


%% 1. Compute this quarter's issuance amounts (by instrument)
% Issuance in a sector is based on that sector's maturities, adjusted by overall financial requirements. That issuance of financial requirement amount is allocated between
% sectors in proportion to the steady-state portfolio.

% For treasury bills, issuance equals maturity. 
n.issuance(1:3,i)=t.maturity(1:3,i)+(s.weight(1:3)'.*f.finreq(i));  

% Since some bonds have re-openings (issuance in different quarters mature
% in the same quarter), issuance is instead computed as a fraction of total maturities in nearby quarters.
for j=1:s.nBnds     %for bonds
  n.issuance(j+s.nBill,i)=sum(t.maturity(j+s.nBill,...
	(u.numReopen(j)*ceil(i/u.numReopen(j))- ... 
	u.numReopen(j)+1):(u.numReopen(j)*ceil(i/u.numReopen(j)))))...
	/u.numReopen(j)+(s.weight(j+s.nBill)'.*f.finreq(i));
end


%% 2. Update future maturing amounts based on this quarter's issuance (by instrument)
t.maturity(1,i+1)=t.maturity(1,i+1)+n.issuance(1,i);    %3-month bills (mature in 1 quarter)
t.maturity(2,i+2)=t.maturity(2,i+2)+n.issuance(2,i);    %6-month bills (mature in 2 quarters)
t.maturity(3,i+4)=t.maturity(3,i+4)+n.issuance(3,i);    %12-month bills (mature in 4 quarters)
n.maturity(1,i+1)=t.maturity(1,i+1); 
n.maturity(2,i+2)=t.maturity(2,i+2);
n.maturity(3,i+4)=t.maturity(3,i+4);

% Same update to a separate matrix for inflation-adjusted maturity amounts
n.maturityReal(1,i+1)=t.maturity(1,i+1);
n.maturityReal(2,i+2)=t.maturity(2,i+2);
n.maturityReal(3,i+4)=t.maturity(3,i+4);
t.maturityReal(1,i+1)=t.maturity(1,i+1);
t.maturityReal(2,i+2)=t.maturity(2,i+2);
t.maturityReal(3,i+4)=t.maturity(3,i+4);

for j=1:s.nBnds     %for bonds, issuance will mature in # of quarters defined in utility matrix of TTM (for the given sector and quarter)
  t.maturity(j+3,i+u.ttm(j+3,i))=t.maturity(j+3,i+u.ttm(j+3,i))+...
                                  n.issuance(j+3,i);
  n.maturity(j+3,i+u.ttm(j+3,i))=n.maturity(j+3,i+u.ttm(j+3,i))+n.issuance(j+3,i);
  
  % Same update to a separate matrix for inflation-adjusted maturity amounts
  t.maturityReal(j+3,i+u.ttm(j+3,i))=t.maturityReal(j+3,i+u.ttm(j+3,i))+...
                                  n.issuance(j+3,i);
  n.maturityReal(j+3,i+u.ttm(j+3,i))=n.maturityReal(j+3,i+u.ttm(j+3,i))+n.issuance(j+3,i);
end


%% 3. Compute cash buffer
% Issuance adjustment needed to match actual quarter's
% issuance to actual quarter's funding needs (maturities + financial
% requirements). Arises due to re-opening structure of bonds. It is assumed
% here to be put in 3-month bills.
t.cash(i)=t.cash(max(i-1,1))+sum(t.maturity(s.nBill+1:s.nInst,i))-sum(n.issuance(s.nBill+1:s.nInst,i))+ ...
	sum(s.weight(s.nBill+1:s.nInst).*f.finreq(i));


%% 4. Store more detailed information on maturities and outstanding
t.totalmaturity(1,1:120,i)=sum(t.maturity(:,i:119+i));  %total maturity from this quarter's issuance

% Compute this quarter's outstanding amount (by sector), updated for issuance and maturity
if(strcmp(s.equi,'steady-state'))
  if i==1
    t.detailedoutstanding(:,1)=s.value.*s.weight'-t.maturity(:,1)+n.issuance(:,1);
    t.detailedoutstanding(1,i)=t.detailedoutstanding(1,i)+t.cash(i); 
  else  
    t.detailedoutstanding(:,i)=t.detailedoutstanding(:,i-1)+n.issuance(:,i)-t.maturity(:,i);
    t.detailedoutstanding(1,i)=t.detailedoutstanding(1,i)+t.cash(i)-t.cash(i-1); 
  end
elseif(strcmp(s.equi,'actual'))
  if i==1
    t.detailedoutstanding(:,1)=sum(o.matbonds')'-o.matbonds(:,1)...
	-n.maturity(:,1)+n.issuance(:,1);
    t.detailedoutstanding(1,i)=t.detailedoutstanding(1,i)+t.cash(i); 
  else  
    t.detailedoutstanding(:,i)=t.detailedoutstanding(:,i-1)-o.matbonds(:,i)...
	-n.maturity(:,i)+n.issuance(:,i);
    t.detailedoutstanding(1,i)=t.detailedoutstanding(1,i)+t.cash(i)-t.cash(i-1); 
  end
end