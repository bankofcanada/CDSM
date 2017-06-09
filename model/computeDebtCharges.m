%% computeDebtCharges.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine (on _runSingleRealization.m_) computes the coupon amounts for debt issued in the given quarter
% (in the given scenario for the given strategy), and updates debt
% costs in this and future quarters accordingly.
%
% For real return bonds, the effect of uplift from this quarter's inflation on coupons and
% principals (on both old and new debt) is also applied.


%% 1. Compute coupon amounts from this quarter's issuance (by instrument)
%
% See _<computePenaltyFunctions_wts.html computePenaltyFunctions_wts>_
if(strcmp(s.issueFeedback,'no'))    %only if penalty functions turned off (not used)
  n.issuancetotal(:,i)=n.issuance(:,i);
  n.issuancetotal(1,i)=n.issuance(1,i)+t.cash(i);
  cost(:,i) = n.issuancetotal(:,i).*(scen(:,i)./4);

elseif(strcmp(s.issueFeedback,'yes'))   %if penalty functions turned on   
  n.issuancetotal(:,i)=n.issuance(:,i);
  n.issuancetotal(1,i)=n.issuance(1,i)+t.cash(i);   %add cash buffer to shortest-term (3-month bill) issuance amount
  computePenaltyFunctions_wts;  %apply penalty function to adjust interest rates for each sector, for issuance amounts above or below allowable range
  cost(:,i) = n.issuancetotal(:,i).*(scen1(:,i)./4);    %compute each sector's coupon amount (quarterly coupon rate x issuance amount)
end


%% 2. Interpolate the zero-coupon prices for funding RRB principal uplift
if i==1
  for tt=1:max(u.numPeriods)    %for all quarterly tenors (0.25, 0.5, ..., 30)
    idx = find(s.zterms<=tt,1,'last');
    if s.zterms(idx)==tt
      interpZeroP(:,tt) = exp(-tt/4*data.Z(:,idx,k));
    else
      x1 = s.zterms( idx );
      x2 = s.zterms( idx+1 );
      interpZeroP(:,tt) = exp(-tt/4*(...
        (x2-tt)/(x2-x1)*data.Z(:,idx,k) + (tt-x1)/(x2-x1)*data.Z(:,idx+1,k) ));
    end
  end
end

if i==1
  tt=linspace(1,120,120)/4;
  A1=interp1(get(mObject,'ttm'),data.Z(:,:,k)',tt)';
  A=(1+A1).^kron(-tt,ones(s.nperiod,1));
end


%% 3. Update future debt costs with coupon amounts from this quarter's issuance 

for j=1:s.nInst     %for each sector issued this quarter

  finPmt = min(u.ttm(j,i)+i-1,s.maxMat+s.nperiod);  % # of quarters until maturity; if maturity would occur after simulated horizon, it is assumed to instead occur in final quarter

% For nominal instruments, allocate quarterly coupon amounts to each quarter until maturity
  if j<=s.nNomInst
    n.newaccrual(j,i:finPmt) = n.newaccrual(j,i:finPmt) + cost(j,i);
    n.nominalMaturity(j,i) = sum(t.maturity(j,i+1:end));
  
    
  elseif j>=s.nNomInst+1
      
% For inflation-linked instruments, convert coupons to real terms (as of
% the simulation start) and allocate to quarters until maturity
    realcost(j,i:finPmt) = realcost(j,i:finPmt) + cost(j,i)/CPI(i); 

    diffCPI = ((1+X0(i,s.dim+5,k)).^0.25)-1;    %inflation this quarter, i.e. % increase in CPI
    
    %Adjust RRB maturing amounts for this quarter's increase in CPI 
    t.maturityReal(j,i+1:i+u.ttm(j,i)) = t.maturityReal(j,i+1:i+u.ttm(j,i)).*(1+diffCPI);     
    n.maturityReal(j,i+1:i+u.ttm(j,i)) = n.maturityReal(j,i+1:i+u.ttm(j,i)).*(1+diffCPI);
    
    %In order to finance the increased RRB principal from this inflation
    % uplift, the government needs to invest some amount this quarter at
    % the zero-coupon rate in order to fund the uplifted principal exactly at maturity. This investment is a cash outflow.               
    buyMatureInfl(j,i) = (diffCPI.* t.maturityReal(j,i+1:i+u.ttm(j,i)))*A(i,1:u.ttm(j,i))';              
    
    %Cost of RRBs each quarter is total of CPI-adjusted coupons and investment outflows (for funding principal uplift).
    n.newaccrual(j,i) = realcost(j,i)*CPI(i) + buyMatureInfl(j,i); 
    n.rrbCoupon(j,i) = realcost(j,i)*CPI(i);
    n.rrbPrincipal(j,i) = buyMatureInfl(j,i);
  end
end


%% 4. Compute total debt cost for this quarter
total(i)=sum(n.newaccrual(:,i))+sum(o.initialaccrual(1:s.nNomInst,i));  %sum of debt costs from issuances in horizon and old issuance (all RRB cost included as part of new debt)
totalRealCpn(i)=sum(n.rrbCoupon(:,i));
totalRealPrn(i)=sum(n.rrbPrincipal(:,i));