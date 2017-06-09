%% viewSimulation.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _stochasticModel_ class) prints a high-level summary of the simulation results.

%% Method Syntax
function viewSimulation(sm,data);
%%
% _sm_ : method is applied to _stochasticModel_ class
%
% _data_ : structure with the monthly simulated variables

 
%% 1. Define variables for output
for i=1:length(get(sm,'simTenor')); %zero-coupon rates
  mZ(i,:)=mean(squeeze(data.Z(:,i,:)));
end

for i=1:size(data.X,2); %macroeconomic variables
  mX(i,:)=mean(squeeze(data.X(:,i,:)));  
end

if isa(sm,'fourierSeries'); %macroeconomic variables for alternate models
  mX = mX(get(sm,'dim')+1:get(sm,'dim')+6,:);
elseif isa(sm,'obsAffine');
    mX = mX(get(sm,'dim')+1:get(sm,'dim')+3,:);
elseif isa(sm,'exponentialSpline');
  mX = mX(get(sm,'dim')+1:get(sm,'dim')+4,:);
else;
  mX = mX(4:9,:);
end


%% 2. Print results
% First two moments (mean, standard deviation) and maximum/minimum for yields and macro variables
disp(sprintf('    Some Summary Statistics for Output Data'));  
disp(sprintf('    ----------------------------------------------'));  
disp(sprintf('    TTM       MEAN      STD       MIN       MAX'));  
disp(sprintf('    ----------------------------------------------'));  
disp([get(sm,'simTenor')' 100*mean(mZ')' 100*std(mZ')' 100*min(mZ')' ...
      100*max(mZ')']);
disp(sprintf('    ----------------------------------------------'));  
disp(sprintf(['    Number of Simulations: ' ...
	      num2str(get(sm,'numSims'))]));  
disp(sprintf(['    Simulation years: ' num2str(get(sm,'simT'))]));  
disp(sprintf(['    Simulation frequency: ' num2str(get(sm,'simN'))]));  
disp(sprintf('    ----------------------------------------------'));  
A=[100*mean(mX')' 100*std(mX')' 100*min(mX')' 100*max(mX')'];
disp(sprintf('                 MEAN   STD    MIN    MAX'));  
disp(sprintf('    ----------------------------------------------'));  
disp(sprintf('    Real GDP:    %0.2f  %0.2f  %0.2f  %0.2f',A(6,:)));  
disp(sprintf('    Inflation:   %0.2f  %0.2f  %0.2f  %0.2f',A(5,:)));  

if ~isa(sm,'angPiazzesi')
  disp(sprintf('    Target Rate: %0.2f  %0.2f  %0.2f  %0.2f',A(3,:)));  
end

if ~isa(sm,'obsAffine')
  disp(sprintf('    Output Gap:  %0.2f  %0.2f  %0.2f  %0.2f',A(1,:)));  
end;