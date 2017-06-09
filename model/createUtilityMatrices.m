%% createUtilityMatrices.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function creates a utility matrix describing the time to maturity (in quarters) of each instrument issued in each quarter in the horizon
%
% It considers the standard TTM of each instrument, the re-opening schedule of each bond (i.e. issuance in consecutive quarters are often set to mature in the same quarter; the later issuances are "re-openings" of the first one), and in what quarter the bond matures 


%% Function Syntax
function [u]=createUtilityMatrices(s)
%%
% _s_ : structure containing simulation parameters
%
% _u_ : structure containing utility matrices describing instruments' TTMs


%% 1. Set Up

%Define an index for each quarter
june=1;     %Q1  
sept=2;     %Q2
dec=3;      %Q3
mar=4;      %Q4            

u.numReopen(1:s.nBnds)=s.Reopenings;    %number of re-openings for nominal and inflation-linked bonds
u.numPeriods(1:s.nBnds)= s.terms(s.nBill+1:s.nInst); %standard TTM for each bond
u.matQuarter(1:s.nBnds)=[june sept june june june dec dec dec dec dec]; %quarter of first fiscal year maturity, for each bond

u.ttm=zeros(s.nInst,120);   % Initialize the utility matrix for TTM


%% 2. Populate the Utility Matrix for Time to Maturity

% Populate time to maturity of treasury bills
u.ttm(1:s.nBill,1:s.nperiod)=kron([s.terms(1:s.nBill)],ones(1,s.nperiod)); %same TTM for each quarter, since no re-openings

% Populate time to maturity for nominal and inflation-linked bonds
for(j=1:s.nBnds)
  for i=1:s.nperiod/u.numReopen(j)  %TTM will depend on where bond is in re-opening cycle  
    u.ttm(j+3,s.Reopenings(j)*(i-1)+1:s.Reopenings(j)*i)=...
	(u.numPeriods(j)-1+u.matQuarter(j)):-1:...
	(u.numPeriods(j)-s.Reopenings(j)+u.matQuarter(j));
  end
end
u.ttm=u.ttm(:,1:s.nperiod);


%% 3. Make manual adjustments to utility matrix (if standard inputs don't give desired values)
cc = [ 114 113 120 119 118 117 116 115];
u.ttm(13,:) = repmat(cc,1,s.nperiod/length(cc));