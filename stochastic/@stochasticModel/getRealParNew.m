%% getRealParNew.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _stochasticModel_ class) computes simulated par rates for the relevant semiannual-coupon bonds, based on the simulated zero-coupon yields, expected inflation, and term premia


%% Method Syntax
function c=getRealParNew(sm,data)
%%
% _sm_ : method is applied to _stochasticModel_ class
%
% _data_ : structure containing simulated zero-coupon yields, expected inflation, and term premia
%
% _c_ : matrix for simulated real par rates


%% 1. Compute real zero-coupon rate at each point as: nominal zero-coupon rate less expected inflation and term premium
R=data.Z-data.eInf-data.T;
    

%% 2. Set Up
c=zeros(get(sm,'simT')*get(sm,'simN'),4,get(sm,'numSims'));
v=[2 5 10 30];


%% 3. Compute real par rates for real-return bonds
for(i=1:get(sm,'numSims'))  %for each simulation
  for(j=1:length(v))    %for each bond tenor
    steps=linspace(1/2,v(j),2*v(j));    %coupon payment and maturity (i.e. cash-flow) dates
    p=(1+interp1(get(sm,'simTenor'),R(:,:,i)',steps)')...
      .^(-kron(steps,ones(get(sm,'simT')*get(sm,'simN'),1)));   %zero rates for each cash-flow date
    c(:,j,i)=((1-p(:,end))./sum(p')')*2;    %compute par coupon rate from zero rates, and convert to annual
  end
end
