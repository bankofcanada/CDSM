%% getRiskPremia.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _nelsonSiegel_ class) estimates term premium at each relevant yield curve tenor for simulations

%% Method Syntax
function TT=getRiskPremia(ns,data)
%%
% _ns_ : method is applied to 'nelsonSiegel' class
%
% _data_ : structure containing simulated zero-coupon yields
%
% _TT_ : matrix of simulated term premia
%
% For term premium computations, simulated 25-year zero rate is taken as 30-year rate, and simulated 30-year rate is taken as 32-year rate


%% 1. Set Up
simTenor = get(ns,'simTenor');  
ttm=linspace(min(simTenor),max(simTenor),...
	     (max(simTenor)-min(simTenor))/min(simTenor)+1);

para = get(ns,'parameters');    %get model parameters
K=size(para.X,1);
for(i=1:get(ns,'dim'))  %compute factor loadings
  H(:,i) = ns_basis(ttm,i,1/2.5)';
end
H=[H zeros(length(H),K-get(ns,'dim'))];  

N=get(ns,'simT')*get(ns,'simN');  %number of quarters simulated
M=get(ns,'numSims');    %number of simulations

% Initialize matrices 
F=zeros(N,size(ttm,2),M);
Zb=zeros(N,size(ttm,2),M);
Zhat=zeros(N,size(ttm,2),M);
T=zeros(N,size(ttm,2),M);
T1=zeros(N,size(ttm,2),M);


%% 2. Compute term premia for VAR(1) model
if get(ns,'lags')==1;

  for p=1:M
    for i=1:N
      Zb(i,:,p)=interp1(simTenor,data.Z(i,:,p)',ttm,'spline');  %interpolated quarterly zero rates
      F(i,:,p)=forward(Zb(i,:,p),ttm);  %compute the forward rates (1-year) 
      X=[];
      
      %Estimate historical rates fitted to VAR model, for term premium computation
      for j=1:12
	if j==1;
	  X=para.B(:,1) + para.B(:,2:end)*data.X(i,:,p)';
	else
	  X=para.B(:,1) + para.B(:,2:end)*X;    
	end
      end
      Zhat(i,:,p)=(H*X)';   %forecasted rates (1-year forward)
      T(i,:,p)=F(i,:,p)-Zhat(i,:,p);    % term premia estimate (model), not used
      T1(i,:,p)=F(i,:,p)-Zb(i,:,p); % term-premia estimate (random walk)
    end  
  end

  
%% 3. Compute term premia for VAR(2) model  
elseif get(ns,'lags')==2
  
  for p=1:M;
    for i=1:N
      Zb(i,:,p)=interp1(simTenor,data.Z(i,:,p)',ttm,'spline');
      F(i,:,p)=forward(Zb(i,:,p),ttm);
      X=[];
      for j=1:12
	if j==1;
	  X(:,j)=para.B(:,1) + para.B(:,2:K+1)*data.X(i,:,p)' ...
		 + para.B(:,K+2:2*K+1)*para.X(:,end);
	elseif j==2;
	  X(:,j)=para.B(:,1) + para.B(:,2:K+1)*X(:,j-1) ...
		 + para.B(:,K+2:2*K+1)*data.X(i,:,p)';	
	else
	  X(:,j)=para.B(:,1) + para.B(:,2:K+1)*X(:,j-1) ...
		 + para.B(:,K+2:2*K+1)*X(:,j-2);		
	end
      end
      Zhat(i,:,p)=(H*X(:,end))';
      T(i,:,p)=F(i,:,p)-Zhat(i,:,p);    % term premia estimate (model)
      T1(i,:,p)=F(i,:,p)-Zb(i,:,p);     % term-premia estimate (random walk)
    end  
  end
end


%% 4. Save term premia for relevant points on zero curve
for k=1:M
  TT(:,:,k) = interp1(ttm,T1(:,:,k)',simTenor)';
end


%% 5. Create Plots
makeGraph=0;
if makeGraph==1;
  
  subplot(2,2,1)
  plot(ttm,100*mean(mean(Zb,3)),'b')
  hold on
  plot(ttm,100*mean(mean(F,3)),'r')
  plot(ttm,100*mean(mean(Zhat,3)),'g')
  hold off
  xlabel('Tenor (yrs.)')
  ylabel('Per cent')
  legend('Current zero','Forward','Forecast zero', ...
	 'Location','Best'); 
  axis([0.25 32 2 5]);
  title('Curves')
  
  subplot(2,2,2)
  plot(ttm,1e4*mean(mean(T,3)),'r')
  hold on  
  plot(ttm,1e4*mean(mean(T1,3)),'g')
  hold off
  legend('Model','RW','Location','Best')
  axis([0.25 32 -70 70]);
  title('Risk Premia')

  subplot(2,2,3)
  surf(2007+(1/4)*linspace(1,N,N),ttm,1e4*mean(T,3)')
  colormap('summer')
  xlabel('Time (yrs.)')
  ylabel('Tenor (yrs.')
  ylabel('Per cent')
  title('Model Risk Premia')
  axis tight
  
  subplot(2,2,4)
  surf(2007+(1/4)*linspace(1,N,N),ttm,1e4*mean(T1,3)')
  colormap('summer')
  xlabel('Time (yrs.)')
  ylabel('Tenor (yrs.')
  ylabel('Per cent')
  title('RW Risk Premia')
  axis tight
  
end;


