%% computeVAR.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the parent _stochasticModel_ class) computes the parameters for vector autoregression (VAR) based on historical data

%% Method Syntax
function [ para , X ] = computeVAR(sm, finX, varargin)
%%
% _sm_ : method is applied to 'stochasticModel' class
%
% _finX_ : historical time series of three Nelson-Siegel factors
%
% _varargin_ : optional inputs for VAR estimation settings, carried over from 'estimate_new' inputs
%
% _para_ : structure of VAR parameters to update, stored in 'nelsonSiegel' class 
%
% _X_ : master file of monthly historical variables


%% 1. Combine Nelson-Siegel yield curve variables and macro variables into master file of monthly historical variables
X=[finX; get(sm,'macro_data')];


%% 2. Estimate VAR(p) parameters for model without options
%
% _See <getVarParameters_new.html getVarParameters_new>_
K = size(X,1);
para=getVarParameters_new(X',size(X,1),get(sm,'lags'));


%% 3. Compute stationary means from VAR(p) model above to use as baseline long-term means for each variable (if not pre-set), will be same as historical average 
if get(sm,'lags') == 1  %p = 1 case  
  LTM=inv(eye(K)-para.B(:,2:K+1))*para.B(:,1);
elseif get(sm,'lags') ==2   %p = 2 case
  LTM=inv(eye(K)-para.B(:,2:K+1)-para.B(:,K+2:2*K+1))*para.B(:,1);
elseif get(sm,'lags') ==6   %p = 6 case
  LTM=inv(eye(K)-para.B(:,2:K+1)-para.B(:,K+2:2*K+1)-para.B(:,2*K+2:3*K+1)-para.B(:,3*K+2:4*K+1)-para.B(:,4*K+2:5*K+1)-para.B(:,5*K+2:6*K+1))*para.B(:,1);
end
if max(abs(LTM-mean(X,2)))>1E-6,    %verify that LTMs are at the sample average
 warning('??? Unconditional LTM is not sample average. Might be wrong! ');
end
simLTM=LTM;


%% 4. Estimate VAR(p) parameters for model with the specified options
optionsInputs = varargin;
ss=1;
while ss <= length(optionsInputs)   %loops through all option inputs
  switch upper(  optionsInputs{ss}  )

    case 'LTM'  %Use the value in pre-set matrix (instead of historical average) for long-term means 
      LTMinput = optionsInputs{ss+1};
      replaceidx = find(~isnan( LTMinput ) );
      LTM( replaceidx ) = LTMinput( replaceidx );
      simLTM = LTM;
      para = getVarParameters_new(X',K,get(sm,'lags'),LTM(1:size(X,1)),[],simLTM(1:size(X,1)));

    case 'SIMLTM'   %Center VAR model on value besides long-term mean - currently set as the same
      simLTM = optionsInputs{ss+1};
      size(X,1)
      size(simLTM)
      size(LTM)
      para = getVarParameters_new(X',K,get(sm,'lags'),LTM(1:size(X,1)),[],simLTM(1:size(X,1)));
      simLTM(1:size(X,1)) = para.simLTM;

    case 'EXO'  %Adjust VAR parameters for exogenous variables
      exoIdx = optionsInputs{ss+1};
      para = getVarParameters_new(X',K,get(sm,'lags'),LTM(1:size(X,1)),exoIdx,simLTM(1:size(X,1)));

    case 'FLIP' %Flip the position of two variables
      idx = optionsInputs{ss+1};
      LTM(idx) = LTM(idx([2,1]));
      para.LTM(idx) = para.LTM(idx([2,1]));
      X( idx,: ) = X( idx([2,1]),: );
      para.B( idx,: )   = para.B( idx([2,1]),: );
      para.B( :,idx+1 ) = para.B( :,idx([2,1])+1 );
      if get(sm,'lags')==2
        para.B( :,idx+K+1 ) = para.B( :,idx([2,1])+K+1 );
        para.B( idx+K,: )   = para.B( idx([2,1])+K,: );
      end
      para.Omega( :,idx ) = para.Omega( :,idx([2,1]) );
      para.Omega( idx,: ) = para.Omega( idx([2,1]),: );
      if isfield(para,'Chol')
        para.Chol( :,idx ) = para.Chol( :,idx([2,1]) );
        para.Chol( idx,: ) = para.Chol( idx([2,1]),: );
      end
      if isfield(para,'X')
        para.X( idx,: ) = para.X( idx([2,1]),: );
      end
      
    case 'CONTEMP'  %Extend the VAR model for new total inflation variable (INFL), contemporaneous with core inflation
      COREidx = optionsInputs{ss+1};
      INFL=optionsInputs{ss+2}';
      CORE=X(COREidx,:)';
      if size(INFL,1)<size(INFL,2), INFL=INFL'; end
      if size(X,1)==length(LTM), LTM(end+1)=mean(INFL); end
      if INFL==CORE,
        error('INFL == CORE, change M matrix');
      end
      
      %Estimate a separate VAR to compute effect on total inflation (INFL) of: (1) its own lag, and (2) contemporaneous core inflation 
      pinf=getVarParameters_new([CORE(2:end) INFL(1:end-1)],2,get(sm,'lags')...
                               ,LTM([COREidx,end])); 
                           
      %Compute coefficients in main VAR(p) for new INFL variable; INFL does not affect other variables
      B=zeros(1,(K+1)*get(sm,'lags')+1);
      B(1:(K+1))=para.B(COREidx,1:(K+1))*pinf.B(2,2);   %Other variables' lagged effect on INFL is multiple (based on that separate VAR) of their effect on contemporaneous CORE
      B(1)=B(1)+pinf.B(2,1);    %Add constant term
      B(K+2)=pinf.B(2,3);   %Effect of its own lag
      if get(sm,'lags')==2  %p = 2 case
        B(K+3:2*K+2)=para.B(COREidx,K+2:(2*K+1))*pinf.B(2,2);
        B(COREidx+1)=B(COREidx+1)+pinf.B(2,4);
        B(2*K+3)=pinf.B(2,5);
      end
      if get(sm,'lags')==6  %p = 6 case
          
        B(K+3:2*K+2)=para.B(COREidx,K+2:(2*K+1))*pinf.B(2,2);
        B(COREidx+1)=B(COREidx+1)+pinf.B(2,4);
        B(2*K+3)=pinf.B(2,5);
          
        B(2*K+4:3*K+3)=para.B(COREidx,2*K+2:(3*K+1))*pinf.B(2,2);
        B(COREidx+2)=B(COREidx+2)+pinf.B(2,6);
        B(3*K+4)=pinf.B(2,7); 
        
        B(3*K+5:4*K+4)=para.B(COREidx,3*K+2:(4*K+1))*pinf.B(2,2);
        B(COREidx+3)=B(COREidx+3)+pinf.B(2,8);
        B(4*K+5)=pinf.B(2,9); 
       
        B(4*K+6:5*K+5)=para.B(COREidx,4*K+2:(5*K+1))*pinf.B(2,2);
        B(COREidx+4)=B(COREidx+4)+pinf.B(2,10);
        B(5*K+6)=pinf.B(2,11);
        
        B(5*K+7:6*K+6)=para.B(COREidx,5*K+2:(6*K+1))*pinf.B(2,2);
        B(COREidx+5)=B(COREidx+5)+pinf.B(2,12);
        B(6*K+7)=pinf.B(2,13);
      end
      
      %Adjust the cholesky decomposition of the covariance matrix to incorporate the new contemporaneous variable
       diag(para.Omega)
      C=chol(para.Omega)';
      Cinf=chol(pinf.Omega)';
      C(end+1,end+1)=0;
      C(end,1:end-1)=C(COREidx,1:end-1)*pinf.B(2,2);
      C(end,end)=Cinf(end,end);
      C(end,COREidx)=C(end,COREidx)+Cinf(2,1);
      
      %Extend the main VAR(p) parameters with coefficients for new INFL
      b=para.B;
      if get(sm,'lags') == 1    %p = 1 case
        b(end+1,end+1)=0;
        b(end,:)=B;
      end
      if get(sm,'lags') == 2    %p = 2 case
        b=[b(:,1:K+1) zeros(K,1) b(:,K+2:end) zeros(K,1)];
        b(end+1,:)=B;
      end
      if get(sm,'lags') == 6    %p = 6 case
        b=[b(:,1:K+1) zeros(K,1) b(:,K+2:2*K+1) zeros(K,1) b(:,2*K+2:3*K+1) zeros(K,1) b(:,3*K+2:4*K+1) zeros(K,1) b(:,4*K+2:5*K+1) zeros(K,1) b(:,5*K+2:end) zeros(K,1) ];
        b(end+1,:)=B;
      end
      para.Omega(end+1,end+1)=pinf.Omega(end,end);
      para.Chol = C;
      para.B=b; 
      K=K+1;
      X(end+1,:)=INFL;
      ss=ss+1;
  end
  
  %Store long-term means in structure of VAR parameters  
  para.LTM = LTM;
  para.simLTM = simLTM;
  ss=ss+2;
end
