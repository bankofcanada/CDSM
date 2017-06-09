%% saveIntermediateResults.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine stores the key results from given simulation (of the given strategy) into the main output variable.


%% 1. Save and store key variables from simulation
issuance(k,:)=mean(n.issuancetotal');
issuancedetailed(:,:,k)=n.issuancetotal(:,1:s.nperiod);
billIssue(k,:)=sum(n.issuancetotal(1:s.nBill,1:s.nperiod));
bondIssue(k,:)=sum(n.issuancetotal(s.nBill+1:s.nInst,1:s.nperiod));
billRedemption(k,:)=sum(t.maturityReal(1:s.nBill,1:s.nperiod));
bondRedemption(k,:)=sum(t.maturityReal(s.nBill+1:s.nInst,1:s.nperiod));
CPI_k(k,:)=CPI;
GDP_k(k,:)=GDP;