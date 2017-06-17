%% getNominalPar.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _stochasticModel_ class) computes simulated par rates for the relevant semiannual-coupon bonds, based on the simulated zero-coupon yields.

%% Method Syntax
function c=getNominalPar(sm,data)
%%
% _sm_ : method is applied to _stochasticModel_ class
%
% _data_ : structure containing simulated zero-coupon yields
%
% _c_ : matrix for simulated par rates


%% 1. Set up
c=zeros(get(sm,'simT')*get(sm,'simN'),9,get(sm,'numSims')); %[# of quarters simulated] x [# of tenors] x [# of simulations]
v=[2 3 5 7 10 30];  %bond tenors for Canada, par rates needed

% For t-bills (tenors: 1-quarter, 2-quarters, 4-quarters), the zero-coupon rates are the relevant rates
c(:,1:3,:)=data.Z(:,[1:2,4],:); 


%% 2. Compute par rates for bonds
for(i=1:get(sm,'numSims'))  %for each simulation
  for(j=1:length(v))    %for each bond tenor
    steps=linspace(1/2,v(j),2*v(j));    %coupon payment and maturity (i.e. cash-flow) dates
    p=(1+interp1(get(sm,'simTenor'),data.Z(:,:,i)',steps)')...
      .^(-kron(steps,ones(get(sm,'simT')*get(sm,'simN'),1)));   %zero rates for each cash-flow date
    c(:,j+3,i)=((1-p(:,end))./sum(p')')*2;  %compute par coupon rate from zero rates, and convert to annual
  end
end