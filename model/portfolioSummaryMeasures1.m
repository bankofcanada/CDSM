%% portfolioSummaryMeasures1.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine computes a few common summary metrics of the debt
% portfolio as of that quarter (for that scenario for that strategy).


%% 1. Compute portfolio summary metrics, i.e. fixed-floating ratio and ATM

% Adjust for non-market debt
if exist('fAdj')==0
fA=[163 165 168 170 172 174;
    42 41 41 41 41 41];
for kk=1:2
  fAdj(kk,:)=interp1(linspace(1,6,6),fA(kk,:),...
		    linspace(1,s.nperiod/4,s.nperiod),'cubic','extrap');
end
end

if strcmp(s.model,'full')
  % Adjust the RRB cashflows for cumulative actual CPI to date and assumed inflation for the coming periods
  adjustCPI=ones(s.nInst,s.maxMat);
  adjustCPI(s.nNomInst+1:s.nInst,:)=CPI(i)*flatCPI(s.nNomInst+1:s.nInst,:);
  
  adj(i) = sum(sum(adjustCPI(s.nNomInst+1:s.nInst,5:end).*t.maturity(s.nNomInst+1:s.nInst,i+5:i+s.maxMat) - ...
                t.maturity(s.nNomInst+1:s.nInst,i+5:i+s.maxMat)));  % adjustment for inflation-linked debt
  
  % Compute the fixed-floating ratio ("floating" debt is debt maturing in next four quarters)
  nmd(i) = sum(fAdj(1:2,i));
  fxfl(k,i)=(f.outstanding(i)+nmd(i)+ adj(i)...
	     -sum(sum(t.maturity(3:s.nInst,i+1:i+4)))...
	     -fAdj(2,i)...
	     -t.maturity(1,i+1)-sum(t.maturity(2,i+1:i+2))...
	     -0.5*sum(sum(adjustCPI(s.nNomInst+1:s.nInst,5:end).*t.maturity(s.nNomInst+1:s.nInst,i+5:i+s.maxMat))))/...
	    (f.outstanding(i)+nmd(i)+adj(i));
  rfxPgdp(k,i) = ((f.outstanding(i)+nmd(i)+adj(i))*(1-fxfl(k,i)))/GDP(i);
  
  % ATM is the average term to maturity
  ATM(k,i)=sum(adjustCPI.*t.maturity(:,(i+1):(i+s.maxMat))*(ttm'/4),1)/ ...
	   (f.outstanding(i)+adj(i)); 
  
  % Compute the portfolio duration with current discount factor
  dfactor=kron((1+interp1([0.25 0.5 1 u.numPeriods(1:s.nNomBnds)./4],coupon(k,:,i),ttm/4)).^(-ttm/ ...
						  4),ones(s.nInst,1)); 
  cpns=n.newaccrual(:,(i+1):(i+s.maxMat))+o.initialaccrual(:,(i+1):(i+s.maxMat));
  prin=adjustCPI.*t.maturity(:,(i+1):(i+s.maxMat));
  mv=(cpns+prin).*dfactor;
  mDuration(k,i)=sum(mv*(ttm'/4),1)/sum(sum(mv));
else 
  fxfl(i)=(f.outstanding(i)-sum(sum(t.maturity(s.nBill:s.nNomInst,i+1:i+4)))-t.maturity(1,i+1) ...
	     -sum(t.maturity(2,i+1:i+2)))/f.outstanding(i);
  ATM(i)=sum(t.maturity(:,(i+1):(i+s.maxMat))*ttm')/f.outstanding(i);
end


return;


%% 2. Plot Results
delta(1,:)=norminv(0.95)*linspace(0.5,4.25,25);

[AX,H1,H2]=plotyy(delta(1,:),100*mean(squeeze(m.psm.pFF))',delta(1,:),...
		  mean(squeeze(m.psm.pATM)))
set(H1,'LineStyle','--')
set(H2,'LineStyle',':','LineWidth',3)
set(get(AX(1),'Ylabel'),'String','Fixed-Debt Ratio (%)')
set(get(AX(2),'Ylabel'),'String','Market-Debt ATM (yrs.)')
xlabel('Risk Constraint (CAD)')
axis(AX(1),[delta(1) delta(end) 20 100])
axis(AX(2),[delta(1) delta(end) 0 8])

delta=norminv(0.95)*linspace(2.72,4.25,25);  

[AX,H1,H2]=plotyy(delta,100*mean(squeeze(m.psm.pFF))',delta,...
		  mean(squeeze(m.psm.pATM)));

set(H1,'LineStyle','--')
set(H2,'LineStyle',':','LineWidth',3)
set(get(AX(1),'Ylabel'),'String','Fixed-Debt Ratio (%)')
set(get(AX(2),'Ylabel'),'String','Market-Debt ATM (yrs.)')
xlabel('Risk Constraint (CAD)')
set(AX(1),'YTickLabelMode','manual')
set(AX(1),'YTick',[0 20 40 60 80 100])
axis(AX(1),[delta(1) delta(end) 0 100])
set(AX(2),'YTickLabelMode','manual')
set(AX(2),'YTick',[0 2 4 6 8 s.nperiod/4])
axis(AX(2),[delta(1) delta(end) 0 s.nperiod/4])

subplot(2,2,1)
A=squeeze(m.percentMean);
plot(linspace(1,s.nperiod/4,s.nperiod/4),100*A(:,1),'r','LineWidth',2.5);
hold on
plot(linspace(1,s.nperiod/4,s.nperiod/4),100*A(:,2),'b','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),100*A(:,3),'k','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),100*A(:,4),'g','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),100*A(:,5),'c','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),100*A(:,6),'m','LineWidth',2.5);
hold off
axis tight
xlabel('Time (yrs.)')
ylabel('Per cent')
title('Expected Cost');
legend('Current','Historical','Optimal $2.3B','\uparrow 2nd-yr Risk',...
       'No 30Y','No RRB');
subplot(2,2,2)
A=squeeze(m.car.aCaR);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,1),'r','LineWidth',2.5);
hold on
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,2),'b','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,3),'k','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,4),'g','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,5),'c','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,6),'m','LineWidth',2.5);
hold off
axis tight
xlabel('Time (yrs.)')
ylabel('CAD billions')
title('Absolute CaR');
subplot(2,2,3)
A=squeeze(m.car.rCaR);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,1),'r','LineWidth',2.5);
hold on
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,2),'b','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,3),'k','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,4),'g','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,5),'c','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,6),'m','LineWidth',2.5);
hold off
axis tight
xlabel('Time (yrs.)')
ylabel('CAD billions')
title('Relative CaR');
subplot(2,2,4)
A=squeeze(m.bar.base.rCaR);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,1),'r','LineWidth',2.5);
hold on
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,2),'b','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,3),'k','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,4),'g','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,5),'c','LineWidth',2.5);
plot(linspace(1,s.nperiod/4,s.nperiod/4),A(:,6),'m','LineWidth',2.5);
hold off
axis tight
xlabel('Time (yrs.)')
ylabel('CAD billions')
title('Relative BaR');