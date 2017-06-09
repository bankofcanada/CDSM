%% computePenaltyFunctions_wts.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine increases the coupon rate to above the market rate, for any instrument whose issuance amount
% this quarter is above or below the allowable range. (i.e. it penalizes
% over- or under-issuance)


%% 1. Apply penalty function for all sectors whose issuance is outside allowable range
s.nInst=13;
for j=1:s.nInst
  % Below the minimum issuance range (increase coupon)
  if n.issuancetotal(j,i)<s.issueRanges(j,1)
    scen1(j,i)=scen(j,i)+(s.m1(j)*((s.issueRanges(j,1)...
			 -n.issuancetotal(j,i)).^2))/1e4;
         
  % Inside the allowable range (no penalty)
  elseif n.issuancetotal(j,i)>=s.issueRanges(j,1) ...
	 & n.issuancetotal(j,i)<=s.issueRanges(j,2)
    scen1(j,i)=scen(j,i);
    
  % Above the maximum issuance range (increase coupon)
  elseif n.issuancetotal(j,i)>s.issueRanges(j,2)   
    scen1(j,i)=scen(j,i)+(s.beta(1,j)+...
	s.beta(2,j)*n.issuancetotal(j,i) + ...
	s.beta(3,j)*(n.issuancetotal(j,i).^2))/1e4;

  end
end