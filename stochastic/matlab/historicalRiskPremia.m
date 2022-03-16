%% historicalRiskPremia.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _nelsonSiegel_ class) estimates historical term premium at each relevant yield curve tenor

%% Method Syntax
function TT=historicalRiskPremia(ns)
%%
% _ns_ : method is applied to _nelsonSiegel_ class
%
% _T_ : matrix of historical term premia


%% 1. Set Up
%
% See: _<ns_basis.html ns_basis>_
Z=get(ns,'zero_data');
simTenor = get(ns,'ttm');  
ttm=linspace(min(simTenor),max(simTenor),...
	     (max(simTenor)-min(simTenor))/min(simTenor)+1);

% Get the model parameters and compute factor loadings
para = get(ns,'parameters');
K=size(para.X,1); 
for i=1:get(ns,'dim') 
  H1(:,i) = ns_basis(get(ns,'ttm'),i,1/2.5)';
  H(:,i) = ns_basis(ttm,i,1/2.5)';
end
H=[H zeros(length(H),K-get(ns,'dim'))];  
H1=[H1 zeros(length(H1),K-get(ns,'dim'))];  

%For historical term premium computations, use the smooth NS-parameterized rates instead of actual. Simulated 25-year zero rate is taken as 30-year rate, and simulated 30-year rate is taken as 32-year rate. 
for i=1:size(Z,2)
  ZZ(:,i)=H1*para.X(:,i);
end
Z = ZZ;

% Initialize matrices
N=size(Z,2);
F=zeros(N,size(ttm,2));
Zb=zeros(N,size(ttm,2));
Zhat=zeros(N,size(ttm,2));
T=zeros(N,size(ttm,2));
T1=zeros(N,size(ttm,2));


%% 2. Compute historical term premia
%
% See: _<forward.html forward>_
for i=3:N
  Zb(i,:)=interp1(simTenor,Z(:,i)',ttm,'spline');   %interpolated quarterly zero rates
  F(i,:)=forward(Zb(i,:),ttm);  %compute the forward rates (1-year)
  X=[];
  
	%Estimate historical rates fitted to VAR model, for term premium computation
  for j=1:12
    if get(ns,'lags') == 1  %for VAR(1) model
      if j==1;
        X(:,j)=para.B(:,1) + para.B(:,2:K+1)*para.X(:,i-1);
      else
        X(:,j)=para.B(:,1) + para.B(:,2:K+1)*X(:,j-1);		
      end

    elseif get(ns,'lags') == 2  %for VAR(2) model
      if j==1;
        X(:,j)=para.B(:,1) + para.B(:,2:K+1)*para.X(:,i-1); ...
            + para.B(:,K+2:2*K+1)*para.X(:,i-2);
      elseif j==2;
        X(:,j)=para.B(:,1) + para.B(:,2:K+1)*X(:,j-1) ...
             + para.B(:,K+2:2*K+1)*para.X(:,i-1);	
      else
        X(:,j)=para.B(:,1) + para.B(:,2:K+1)*X(:,j-1) ...
             + para.B(:,K+2:2*K+1)*X(:,j-2);		
      end
    end
  end
  Zhat(i,:)=(H*X(:,end))';
  
  T(i,:)=F(i,:)-Zhat(i,:);  % Term premia estimate (model), not used
  T1(i,:)=F(i,:)-Zb(i,:);   % Term-premia estimate (random walk)
end  


%% 3. Save historical term premia for relevant points on zero curve
TT=interp1(ttm,T1(:,:)',simTenor)';


%% 4. Print four charts for historical risk premium
% makeGraph=0;
% 
% % These charts not produced
% if makeGraph==1;
%   
%   subplot(2,2,1)
%   plot(ttm,100*mean(mean(Zb,3)),'b')
%   hold on
%   plot(ttm,100*mean(mean(F,3)),'r')
%   plot(ttm,100*mean(mean(Zhat,3)),'g')
%   hold off
%   xlabel('Tenor (yrs.)')
%   ylabel('Per cent')
%   legend('Current zero','Forward','Forecast zero', ...
% 	 'Location','Best'); 
%   axis([0.25 32 2 5]);
%   title('Curves')
%   
%   subplot(2,2,2)
%   plot(ttm,1e4*mean(mean(T,3)),'r')
%   hold on  
%   plot(ttm,1e4*mean(mean(T1,3)),'g')
%   hold off
%   legend('Model','RW','Location','Best')
%   axis([0.25 32 -70 70]);
%   title('Risk Premia')
% 
%   subplot(2,2,3)
%   surf(2007+(1/4)*linspace(1,N,N),ttm,1e4*mean(T,3)')
%   colormap('summer')
%   xlabel('Time (yrs.)')
%   ylabel('Tenor (yrs.')
%   ylabel('Per cent')
%   title('Model Risk Premia')
%   axis tight
%   
%   subplot(2,2,4)
%   surf(2007+(1/4)*linspace(1,N,N),ttm,1e4*mean(T1,3)')
%   colormap('summer')
%   xlabel('Time (yrs.)')
%   ylabel('Tenor (yrs.')
%   ylabel('Per cent')
%   title('RW Risk Premia')
%   axis tight
%   
% end;
% 
% % 1st chart: historical term premium (in bps) across tenors, average and 95% confidence intervals
% subplot(2,2,1)
% final=18;
% plot(simTenor(1:final),1e4*mean(TT(3:end,1:final)),'LineWidth',2)
% hold on
% plot(simTenor(1:final),1e4*mean(TT(3:end,1:final))+...
%      norminv(0.95)*1e4*std(TT(3:end,1:final)),'r:','LineWidth',2);
% plot(simTenor(1:final),zeros(size(simTenor)),'g-.','LineWidth',2) 
% plot(simTenor(1:final),1e4*mean(TT(3:end,1:final))-...
%      norminv(0.95)*1e4*std(TT(3:end,1:final)),'r:','LineWidth',2)
% hold off
% axis tight;
% legend('Term Premia','95% CI','Zero-Risk Level',0)
% xlabel('Tenor')
% ylabel('Basis points')
% title('Average Term Premia')
% 
% % 2nd chart: historical nominal and real zero rates (in %) across tenors, average
% eInf = 0.02*ones(size(Z));
% R=mean(Z')-mean(eInf')-mean(TT);
% R=((1+mean(Z'))./((1+mean(eInf')).*(1+mean(TT))))-1;
% 
% subplot(2,2,2)
% plot(simTenor,100*R,'b-','LineWidth',2);
% hold on
% plot(simTenor,100*mean(Z'),'r--','LineWidth',2);
% plot(simTenor,100*(mean(Z')-R),'k-.','LineWidth',2);
% hold off
% xlabel('Tenor')
% ylabel('Per cent')
% axis([simTenor(1) simTenor(end) 0 8]);
% legend('Real','Nominal','Difference')
% title('Zero curves')
% 
% % 3rd chart: historical nominal and real par rates (in %) across tenors, average
% v=linspace(2,30,29);
% for j=1:length(v);
%     steps=linspace(1/2,v(j),2*v(j));
%     p=(1+interp1(simTenor,mean(Z'),steps)').^(-steps');
%     c_n(j)=((1-p(end))./sum(p')')*2;
% end
% 
% for j=1:length(v);
%     steps=linspace(1/2,v(j),2*v(j));
%     p=(1+interp1(simTenor,R,steps)').^(-steps');
%     c_r(j)=((1-p(end))./sum(p')')*2;
% end
% 
% disp('-----  Par Coupons -----');
% disp([v' 100*(c_n-c_r)']);
% 
% 
% subplot(2,2,3)
% plot(v,100*c_r,'b-','LineWidth',2);
% hold on
% plot(v,100*c_n,'r--','LineWidth',2);
% plot(v,100*(c_n-c_r),'k-.','LineWidth',2);
% hold off
% xlabel('Tenor')
% ylabel('Per cent')
% axis([v(1) v(end) 0 8]);
% legend('Real','Nominal','Difference')
% title('Par curves')
% 
% % 4th chart: historical term premium (in bps) across tenors through time
% subplot(2,2,4)
% surf(linspace(1994+1/12,2007+8/12,length(Z)-2)',...
%     simTenor(1:final),1e4*TT(3:end,1:final)')
% %axis([1 length(Z)-2 1 30 -25 50])
% axis tight;
% xlabel('Time (yrs.)')
% ylabel('Tenor (yrs.)')
% zlabel('Risk Premia (bps.)')
% title('Evolution of Term Premia')
end