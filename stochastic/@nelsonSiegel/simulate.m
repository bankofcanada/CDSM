%% simulate.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _nelsonSiegel_ class) simulates the realized monthly macro variables and yield curve variables, as well as the macro forecasts, based on the parameterized VAR model. Run in smaller blocks of the full set of simulations.

%% Method Syntax
function [data]=simulate(ns,startLag,shockLocation);
%%
% _ns_ : method is applied to 'nelsonSiegel' class
%
% _startLag_ : setting for starting values in VAR simulation ('last','mean', or 'ltm'), optional input
%
% _shockLocation_ : index of variable whose starting value is being shocked, optional input
%
% _data_ : structure with arrays of simulation results for block
    %
    % * _data.X_ : matrix of simulated Nelson-Siegel and macro variables: [# of simulated quarters] x [# of NS/macro variables] x [# of simulations]
    % * _data.Z_ : matrix of simulated yield curve variables: [# of simulated quarters] x [# of tenors] x [# of simulations]
    % * _data.C_ : matrix of simulated nominal par coupons: [# of simulated quarters] x [# of tenors] x [# of simulations]
    % * _data.R_ : matrix of simulated real par coupons: [# of simulated quarters] x [# of tenors] x [# of simulations]
    % * _data.R_ : matrix of simulated macroeconomic forecasts: [# of simulated quarters] x [# of forecast variables] x [# of simulations]
    %
    

%% 1. Initialize matrices for macroeconomic and yield curve variable simulation results
para=get(ns,'parameters');
data.X=NaN(get(ns,'simT')*get(ns,'histN')+get(ns,'lags'), size(para.X,1), ...
	   get(ns,'numSims'));  %3D-array dimensions: [# of months simulated] x [# of macro variables] x [# of simulations]
data.Z=NaN(get(ns,'simT')*get(ns,'histN')+get(ns,'lags'), length(get(ns, ...
	  'simTenor')), get(ns,'numSims'));     %3D-array dimensions: [# of months simulated] x [# of yield curve variables] x [# of simulations]
K=size(para.X,1);


%% 2. Cholesky decomposition of VAR model correlation matrix (for shocks)
if isfield(para, 'Chol')    
  para.std=para.Chol;
else
  para.std=chol(para.Omega)';
end


%% 3. Obtain lagged starting values, and apply any shocks via the Cholesky decomposition
%
% See: _<../@stochasticModel/get_Xlag.html get_Xlag>_
if nargin >= 3  %if shock is defined  
  shocks=[para.std(:,shockLocation)];       
  startXlag = get_Xlag(ns,startLag);    %unshocked starting values     
  if shockLocation == 2;     
    startXlag(1,:)=startXlag(1,:)-norminv(0.999)*shocks'; %i.e. effect of large negative shock to slope (index = 2) on all variables     
  else
    startXlag(1,:)=startXlag(1,:)+norminv(0.999)*shocks';
  end;
elseif nargin == 2  %if no shock, and starting setting defined    
  startXlag = get_Xlag(ns,startLag);     
else    %if no shock, and starting setting not defined
  startXlag = get_Xlag(ns);     
end


%% 4. Finish Set Up
Q40 = [1:( 12/get(ns,'simN') ):( 12*get(ns,'simT') )]...
      + get(ns,'lags'); %Index vector for variables on quarterly basis
shock=zeros(122,8); %Initialize matrix of shocks


%% 5. Simulate macroeconomic and yield curve variables for VAR(1) model 
%
% See: _<../matlab/getEinflation.html getEinflation>_

if get(ns,'lags')==1;   %p = 1
  
    for(i=1:get(ns,'numSims'));
    %Initialize matrices for simulated variables: 1st column is lagged values, will be deleted later  
    data.X(1,:,i)=startXlag(1,:);    
    data.Z(1,:,i)=data.X(1,:,i)*para.HSim'; 
    for(h=2:get(ns,'simT')*get(ns,'histN')+1)   %for each simulated month
      temp=0;   
      while(temp==0)    
        data.X(h,:,i)=(para.B(:,1)+para.B(:,2:end)*data.X(h-1,:,i)'...
          +para.std*randn(K,1))';   %Simulate Nelson-Siegel and macroeconomic variables for that month (based on previous month) with VAR(1)
        data.Z(h,:,i)=(para.HSim*data.X(h,:,i)')';  %Convert Nelson-Siegel simulations to zero-coupon yield simulations, based on factor loadings 
        if(sum(logical(data.Z(h,:,i)<=0))==0)   %Check that simulated yields are all positive. If not, redo that month's simulation.
          temp=1;
        end
      end
    end
  end
  
  %Compute expected inflation, up to 384 months ahead as of the first month of each quarter 
  data.eInf = getEinflation(384,data.X(Q40,:,:),get(ns,'dim')+5,... 
                             para.B(:,1),para.B(:,2:K+1));
                         
                         
%% 6. Simulate macroeconomic and yield curve variables for VAR(2) model 
%
% See: _<../matlab/getEinflation.html getEinflation>_
elseif get(ns,'lags')==2;   %p = 2
  for(i=1:get(ns,'numSims'));
    %Initialize matrices for simulated variables: 1st and 2nd columns are lagged values, will be deleted later  
    data.X(1,:,i)=startXlag(2,:);  
    data.X(2,:,i)=startXlag(1,:);
    data.Z(1,:,i)=(para.HSim*data.X(1,:,i)')';
    data.Z(2,:,i)=(para.HSim*data.X(2,:,i)')';
    for(h=3:get(ns,'simT')*get(ns,'histN')+2)   %for each simulated month
      temp=0;
      while(temp==0)
        data.X(h,:,i)=(para.B(:,1)+para.B(:,2:K+1)*data.X(h-1,:,i)'...
           + para.B(:,K+2:2*K+1)*data.X(h-2,:,i)'+chol(para.Omega)'*randn(K,1))';	%Simulate variables for that month (based on previous 2 months) with VAR(2).
        data.Z(h,:,i)=(para.HSim*data.X(h,:,i)')';
        if(sum(logical(data.Z(h,:,i)<=0))==0)   %Check that yields are positive.
          temp=1;
        end
      end
    end
  end
  
  %Compute expected inflation, up to 384 months ahead as of the first month of each quarter  
   data.eInf = getEinflation(384,data.X(Q40,:,:),data.X(Q40-1,:,:),get(ns,'dim')+5,... 
                  para.B(:,1),para.B(:,2:K+1),para.B(:,K+2:2*K+1));

else
  error('Model can only accommodate up VAR(1) or VAR(2) dynamics!');
end;

%Not used
Y_pot=NaN(get(ns,'simT')*get(ns,'histN')+get(ns,'lags'),get(ns,'numSims'));
Y_real=NaN(get(ns,'simT')*get(ns,'histN')+get(ns,'lags'),get(ns,'numSims'));
Y_num=NaN(get(ns,'simT')*get(ns,'histN')+get(ns,'lags'),get(ns,'numSims'));


%% 7. Compute matrix of macroeconomic forecasts from simulated variables and save results
%
% See: _<../@stochasticModel/annualMacroForecast.html annualMacroForecast>_
data.eMacro=annualMacroForecast(ns,data);


%% 8. Save matrix of simulated yield curve and macroeconomic variables
%Save only the quarterly yield curve and macro simulations (i.e. for first month of each quarter)
data.Z=data.Z(Q40,:,:); 
data.X=data.X(Q40,:,:);


%% 9. Compute simulated nominal and real par rates, based on simulated yield curve variables and expected inflation
%
% See: _<../matlab/getRiskPremia.html getRiskPremia>_, _<../@stochasticModel/getNominalPar.html getNominalPar>_, _<../@stochasticModel/getRealParNew.html getRealParNew>_
data.T=getRiskPremia(ns,data);  %simulated term premia
data.C=getNominalPar(ns,data);  %simulated nominal par coupons
data.simTenor=get(ns,'simTenor');   %relevant tenors
data.eInf = data.eInf(:,4*get(ns,'simTenor'),:);    %expected inflation for relevant tenors (at each simulated quarter)
data.R=getRealParNew(ns,data);  %simulated nominal real coupons


%% 10. Add real GDP growth to the matrix of simulated macroeconomic variables (as 9th variable)
for k=1:get(ns,'numSims');
  data.X(1,get(ns,'dim')+6,k) = ...
      (((1+data.X(1,get(ns,'dim')+1,k))./...
	(1+startXlag(2,get(ns,'dim')+1)))-1) ...
      +data.X(1,get(ns,'dim')+4,k); 
  for i=2:length(Q40);
    data.X(i,get(ns,'dim')+6,k) = ...
        (((1+data.X(i,get(ns,'dim')+1,k))./...
	  (1+data.X(i-1,get(ns,'dim')+1,k)))-1) ...
	+(data.X(i,get(ns,'dim')+4,k)); 
  end
end