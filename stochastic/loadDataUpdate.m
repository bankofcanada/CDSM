%% loadDataUpdate.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine loads the historical data used to estimate the vector autoregression (VAR).


%% Policy Inputs
% These variables are defined via internal policy decision and are set to --- here as a placeholder:
%
% * _start_ and _last_ (see Part 1) : starting/ending month (1-12) and year (1-2017) for historical time series used to parameterize VAR model
%


%% Data Inputs
% The following files contain data that come from internal sources. All values in the files are set to --- as a placeholder:
%
% * _'ovnrateMMMYY.txt'_ : monthly historical time series of overnight rates
% * _'inflyearMMMYY.txt'_ : monthly historical time series of inflation
% * _'inflcoreyearMMYY.txt'_ : monthly historical time series of core inflation
% * _'ygap.txt'_ : monthly historical time series of output gap
% * _'potgdppctchquarterMMMYY.txt'_ : monthly historical time series of potential GDP growth
% * _'zeroCurvesMMMYY.txt'_ : monthly historical time series of yield curve rates
% * _'RGDPpctchquarterMMMYY.txt'_ : monthly historical time series of real GDP growth
%


%% 1. Set Up

% Set historical data range
start = [-- ----]   %[MM YYYY]       
last = [-- ----]    %[MM YYYY]

% Set path
path('../stochastic',path);
path('../stochastic/matlab',path);


%% 2. Load historical monthly macroeconomic data

%OVNR : Bank of Canada's Overnight Rate (average for month)
disp('OVNR')
X=load( '../stochastic/varData/ovnrateMMMYY.txt'); %load data file
[i,j]=min( abs(X(:,1)-start(1))+abs(X(:,2)-start(2)) ); %index of start date
[i,k]=min( abs(X(:,1)-last(1))+abs(X(:,2)-last(2)) );   %index of last date
OVNR=X(j:k,3:end);  %vector of monthly data for historical range

%INFL : Total Inflation (for past year)
disp('INFL')
X=load( '../stochastic/varData/inflyearMMMYY.txt' );
[i,j]=min( abs(X(:,1)-start(1))+abs(X(:,2)-start(2)) ); 
[i,k]=min( abs(X(:,1)-last(1))+abs(X(:,2)-last(2)) );   
INFL=X(j:k,3:end);   

%CORE : Core Inflation (for past year)
disp('CORE')
X=load( '../stochastic/varData/inflcoreyearMMMYY.txt' );
[i,j]=min( abs(X(:,1)-start(1))+abs(X(:,2)-start(2)) );  
[i,k]=min( abs(X(:,1)-last(1))+abs(X(:,2)-last(2)) );   
CORE=X(j:k,3:end);  

%YGAP : Output Gap (interpolated from quarterly data) 
disp('YGAP')
X=load( '../stochastic/varData/ygapMMMYY.txt' );
[i,j]=min( abs(X(:,1)-start(1))+abs(X(:,2)-start(2)) ); 
[i,k]=min( abs(X(:,1)-last(1))+abs(X(:,2)-last(2)) );   
YGAP=X(j:k,3:end);  

%GAPGROWTH : Growth in Output Gap (for past three months, interpolated from quarterly data) 
disp('GAPGROWTH')
GAPGROWTH=(1+X(j:k,3:end))./(1+X(j-3:k-3,3:end)) - 1;

%POTGROWTH : Growth in Potential Output (for past three months, interpolated from quarterly data) 
disp('POTGROWTH')
X=load( '../stochastic/varData/potgdppctchquarterMMMYY.txt' );
[i,j]=min( abs(X(:,1)-start(1))+abs(X(:,2)-start(2)) ); 
[i,k]=min( abs(X(:,1)-last(1))+abs(X(:,2)-last(2)) );   
POTGROWTH=X(j:k,3:end);


%% 3. Save matrix of historical macro data for VAR parameterization
% Variables used in VAR are potential output growth (POTGROWTH), total inflation (INFL), overnight rate (OVNR), and output gap (YGAP)
M = [POTGROWTH INFL OVNR YGAP]';
numObs = length(M);     %number of months in historical range
clear GAPRATIO X;


%% 4. Load historical monthly yield curve data

%ZCURVES : Zero-Coupon Yield Curve (for end of month)
X9207=load( '../stochastic/varData/zeroCurvesMMMYY.txt');
[i,j]=min( abs(X9207(:,1)-start(1))+abs(X9207(:,2)-start(2)) ); %index of start date
[i,k]=min( abs(X9207(:,1)-last(1))+abs(X9207(:,2)-last(2)) );   %index of last date
ZCURVES=X9207(j:k,3:end); %vector of monthly data for historical range


%% 5. Save matrix of historical yield curve data (in terms of Nelson-Siegel parameters) for VAR parameterization 
% Keep only the 18 zero-coupon yields of interest
path(path,'~/matlab');
ttm=[0.25 0.5 0.75 1 2 3 4 5 6 7 8 9 10 12 15 20 25 30];    %zero coupon yields of interest
ttm1=[0.5 1 2 3 4 5 6 7 8 9 10 12 15]; 
Z=interp1([.25:.25:30],ZCURVES',ttm);


%% 6. Compute forward curves from historical yield curve data
for i=1:size(Z,2);
  F(:,i)=forward(ZCURVES,[.25:.25:30])';
end
return;


%% 7. Load historical monthly data for Growth of Real GDP 
X=load( '../stochastic/varData/RGDPpctchquarterMMMYY.txt' );
[i,j]=min( abs(X(:,1)-start(1))+abs(X(:,2)-start(2)) ); 
[i,k]=min( abs(X(:,1)-last(1))+abs(X(:,2)-last(2)) ); 
YREAL=X(j:k,3:end);

YREAL_hat(2) = (((1+YGAP(2))./(1+YGAP(1)))-1) + POTGROWTH(2); 
for i=3:length(POTGROWTH);
  YREAL_hat(i) = (((1+YGAP(i))./(1+YGAP(i-1)))-1) + POTGROWTH(i); 
end

plot(100*POTGROWTH(2:end))
hold on
plot(100*YREAL(2:end),'r')
plot(100*YGAP(2:end),'g')
plot(100*YREAL_hat(2:end),'k')
hold off