%% getVarParameters_new.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function computes the parameters of a VAR(p) model based on historical data, with the specified settings  

%% Function Syntax
function s=getVarParameters_new(Y,k,lag,LTM,exo,newMean)
%%
% _Y_ : Combined historical time series of Nelson-Siegel yield curve factors and macro variables
%
% _k_ : number of variables in the VAR(p) model
%
% _lag_ : lag of the VAR model, i.e. p
%
% _LTM_ : pre-set vector of each variable's long-term mean, optional input
%
% _exo_ : index of exogenous variable(s), optional input
%
% _newMean_ : alternate long-term means, optional input
%
% _s_ : matrix of computed VAR(p) parameters, [c A_1 ... A_p] 


%% 1. Set up
N=length(Y);    %number of months of historical data   
lagStep=[1:lag];    %vector from 1 to number of lags

%Ensure correct dimensionality
nlag=lag;
if length(lag)>1
  lagStep=lag;
  nlag=length(lag);
  lag=max(lagStep);
end
if size(Y,1)<size(Y,2)
  Y=Y';
end

%If no long-term mean vector set for LTM, use mean of historical data 
if nargin < 4    
  LTM = mean(Y); 
elseif size(LTM,1)>size(LTM,2)
  LTM=LTM';
end

%If no exogenous variables set for exo, that variable is NULL
if nargin < 5   
  exo = [];
end

%If no alternate mean vector set for newMean, that variable is NULL
if nargin < 6
    newMean = [];   
end


%% 2. Estimate coefficients of VAR(p) model (excluding the constants), by regressing the combined time series of historical variables on their lagged combined time series (up to lag p) 
% Variables for regression are redefined in terms of difference from long-term mean, with no constant vector, so that VAR is stationary around LTM 

X = [ones(N-lag,1)];
X_= [];
for tt=lagStep
  X = [X  Y(lag-tt+1:end-tt,:)];    %matrix of lagged combined time series for lags 1,...,p (with constant vector)
  X_= [X_ Y(lag-tt+1:end-tt,:)-LTM(ones(N-lag,1),:)];   %matrix in terms of difference from long-term mean, no constant vector
end

Y = Y(lag+1:end,:); %matrix of combined time series (first p terms removed, with constant vector) 
Y_= Y-LTM(ones(N-lag,1),:); %matrix in terms of difference from long-term mean, no constant vector

s.B_=inv(X_'*X_)*X_'*Y_;    %compute VAR coefficients 


%% 3. Adjust VAR(p) coefficients for exogenous variables, if applicable
for idx = exo
  s.B_(:,idx)=0;    %other lagged variables have no effect on exogenous variable
  s.B_(idx,idx)=inv(X_(:,idx)'*X_(:,idx))*X_(:,idx)'*Y_(:,idx);     %exogenous variable has AR(p) process
end


%% 4. Set an alternate value (instead of long-term mean) for variables to center around, if applicable
simLTM=LTM;
for nm = 1:length(newMean)
    if ~isnan(newMean(nm))
        simLTM(nm) = newMean(nm);
    end
end


%% 5. Set the constant vector of VAR(p) model such that process is stationary around long-term mean (or alternate value)
s.B=[simLTM-repmat(simLTM,1,nlag)*s.B_; s.B_]'; 


%% 6. Compute VAR error and significance measures
N=length(Y);    

resid = (Y-X*s.B'); %matrix of residuals 
s.Omega=(Y-X*s.B')'*(Y-X*s.B')/(N-k*nlag-1);     %correlation matrix of error terms
s.Q=(X'*X)/(N-k*nlag-1);
s.h=sqrt(diag(kron(s.Omega,inv(s.Q)))/(N-k*nlag-1));
vecB=reshape(s.B',length(s.h),1);
s.LTM=LTM;
s.simLTM=simLTM;