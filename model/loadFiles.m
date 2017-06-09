%% loadFiles.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine loads a subset of the combined macroeconomic and interest rate scenarios (generated from the GENERATE SCENARIOS step) for evaluating the financing strategies.


%% 1. Load all generated scenarios

if exist('shockType');  % Load scenarios for specified shock type (not defined here)
  load(['~/CDSM-public/dataFiles/ns' num2str(shockType) 'Results']);
  load(['~/CDSM-public/dataFiles/Coupon_ns' num2str(shockType)]);
  load(['~/CDSM-public/dataFiles/FinR_ns' num2str(shockType)]);
else  
  switch modelType;
   % Load scenarios based on Nelson-Siegel yield curve model
   case 'ns';   

    load ~/CDSM-public/dataFiles/ns_MMMYYResults;
    load ~/CDSM-public/dataFiles/Coupon_ns_MMMYY;
    load ~/CDSM-public/dataFiles/FinR_ns_MMMYY;
   
   % Load scenarios based on other yield curve models (not defined here) 
   case 'es';
      
   case 'fs';

   case 'oa';
 
   case 'vr';
 
  end;
end


%% 2. Adjust simulated coupon data

coupon = permute(coupon,[3 2 1]);   %Redimension matrix of simulated nominal coupons to: [# of simulations] x [# of tenors] x [# of simulated quarters]
realcoupon = permute(realcoupon,[3 2 1]);   %Redimension matrix of simulated real coupons
realcoupon = abs(realcoupon);   %Non-negativity constraint on real coupons
Xlag = Xlag';

coupon=real(coupon);    %Remove complex part of coupon values
realcoupon=real(realcoupon);


%% 3. Load a subset of the scenarios for evaluating the financing strategies

%If 'simulate' variable defined to be 1, load random subset of generated scenarios (by randomizing indices)
if randomize == 1; 
  numSimsAvail = size(coupon,1);
  if numSimsAvail < s.nscenario;    %Ensure sufficient generated scenarios to load 
    error('Not enough stochastic realizations available!  Generate more.');
  end;

  if exist('strategyFile') == 1     %Set random state for training set case
      rand('state',934435 + ceil(ports(1,1)*1000000));
      disp('State of rand changed');
  else
      rand('state',2496123);    %Set random state for individual strategy case
      disp('State of rand changed');
  end
  randSims=ceil(0 + (numSimsAvail-0)*rand(1,s.nscenario));  %Obtain random subset of scenarios (by index)
  randSims = sort(randSims);
  
  % Adjust so that no repeated scenarios 
  p = test_same(randSims);      
  while p>0     
  for j=1:s.nscenario-1
      if randSims(1,j) == randSims(1,j+1)
          if randSims(1,j) < numSimsAvail-(s.nscenario/2)
              randSims(1,j+1) = randSims(1,j+1) + ceil((s.nscenario/2)*rand(1,1));
          else
              randSims(1,j+1) = randSims(1,j+1) - ceil((s.nscenario/2)*rand(1,1));
          end
      end
  end
  randSims = sort(randSims);
  p= test_same(randSims);
  end

  % Load scenarios of those (randomized) indices
  coupon=coupon(randSims,:,:); 
  realcoupon=realcoupon(randSims,:,:); 
  X0 = X0(:,:,randSims);
  data.X = data.X(:,:,randSims);
  data.Z = data.Z(:,:,randSims);
  data.eMacro = data.eMacro(:,:,randSims);
  data.T = data.T(:,:,randSims);
  data.C = data.C(:,:,randSims); 
  data.R = data.R(:,:,randSims); 
  data.eInf = data.eInf(:,:,randSims);
  eMacro = eMacro(:,:,randSims);
else
    
%If 'simulate' variable defined to be 0, load subset of generated scenarios in order
  disp('Taking scenarios in original order');
end;


%% 4. Compute averages of simulated coupons to approximate old coupons

% Compute average simulated coupons for each sector
s.v=[mean(mean(coupon(:,1,:)))      
     mean(mean(coupon(:,2,:)))
     mean(mean(coupon(:,3,:)))
     mean(mean(coupon(:,4,:)))
     mean(mean(coupon(:,5,:)))
     mean(mean(coupon(:,6,:)))
     mean(mean(coupon(:,7,:)))
     mean(mean(coupon(:,8,:)))
     mean(mean(coupon(:,9,:)))
     mean(mean(realcoupon(:,1,:)))
     mean(mean(realcoupon(:,2,:)))
     mean(mean(realcoupon(:,3,:)))
     mean(mean(realcoupon(:,4,:)))];

% For computing financial requirements, use average simulated rates for first year for t-bills instead, to achieve more
% accurate budget balance number
s.v_dc=[mean(mean(coupon(:,1,1:4)))
     mean(mean(coupon(:,2,1:4)))
     mean(mean(coupon(:,3,1:4)))
     mean(mean(coupon(:,4,1:8)))
     mean(mean(coupon(:,5,1:12)))
     mean(mean(coupon(:,6,1:20)))
     mean(mean(coupon(:,7,:)))
     mean(mean(coupon(:,8,:)))
     mean(mean(coupon(:,9,:)))     
     mean(mean(realcoupon(:,1,:)))
     mean(mean(realcoupon(:,2,:)))
     mean(mean(realcoupon(:,3,:)))
     mean(mean(realcoupon(:,4,:)))];

 
%% 5. Save other information about scenarios
 
s.dim = get(mObject,'dim');     %number of Nelson-Siegel factors
s.dimM = size(get(mObject,'macro_data'),1); %number of macroeconomic variables

s.NHA.ret = data.Z(1:4,[1 6 1 8],:)     