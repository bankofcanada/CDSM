%% annualMacroForecast.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _stochasticModel_ class) computes a set of macroeconomic forecasts for each simulated quarter, as of the start of that year. The forecasts are derived from simulated macro variables, and are used for computing the government's financial requirements.

%% Method Syntax
function yMacro=annualMacroForecast(sm,data);
%%
% _sm_ : method is applied to 'stochasticModel' class
%
% _data_ : structure with the monthly simulated variables, which the macroeconomic forecasts are based on
%
% _yMacro_ : matrix of quarterly macroeconomic forecasts, as of the start of that year
    %
    % # expected average real GDP growth for that quarter
    % # expected average inflation for the previous year (quarterly basis)
    % # expected average inflation for that year (quarterly basis)
    % # expected change in overnight rate for last 12 months (quarterly basis)
    %
%
% In summary: simulated macro variables are on a monthly basis, macroeconomic forecasts are on a quarterly basis.


%% 1. Set Up
%
% See _<get_Xlag.html get_Xlag>_
if isa(sm,'obsAffine'); %ensure correct number of lags
  lags = 2;
else;
  lags = get(sm,'lags');
end;

Q40 = [1:( 12/get(sm,'simN') ):( 12*get(sm,'simT') )] + lags;   %index vector to convert variables to a quarterly basis, taking the second month from each quarter
para = get(sm,'parameters');    %structure of VAR parameters
K=size(para.X,1);   %number of variables
Xlag = get_Xlag(sm, get(sm, 'startLag'));   %matrix of lagged variables
M=get(sm,'macro_data'); %matrix of historical macro data

beg=get(sm,'dim');  %number of NS variables
mFactors = K-beg;   %number of macro variables


%% 2. Obtain monthly starting lagged variables for last 12 months, depending on setting
switch lower(get(sm,'startLag'))
  case {'last', 0}  %'last' setting: last 12 months of historical data  
    Xyearlag(:,1:12) = M(1:mFactors,end-11:end);    %lag 1
    Xyearlag2(:,1:12) = M(1:mFactors,end-12:end-1); %lag 2
    Xyearlag13(:,1:12) = M(1:mFactors,end-23:end-12);   %lag 13
  case {'mean', 1}  %'mean' setting: arithmetic mean from historical data
    Xyearlag = Xlag(ones(12,1),beg+1:beg+mFactors)';    %lag 1
    Xyearlag2 = Xlag(ones(12,1),beg+1:beg+mFactors)';   %lag 2
    Xyearlag13 = Xlag(ones(12,1),beg+1:beg+mFactors)';  %lag 13
  case {'ltm', 2}   %'ltm' setting: long-term mean, pre-set or stationary mean from VAR(p)
    Xyearlag = Xlag(ones(12,1),beg+1:beg+mFactors)';    %lag 1
    Xyearlag2 = Xlag(ones(12,1),beg+1:beg+mFactors)';   %lag 2
    Xyearlag13 = Xlag(ones(12,1),beg+1:beg+mFactors)';  %lag 13
  otherwise
    error('wrong first lag argument');
end


%% 3. Compute macroeconomic forecasts for VAR(1) specification.
if lags==1;
  eMacro = zeros(40,beg,size(data.X,3));    %Initialize matrix of expected macro variables    
  yMacro = zeros(40,5,size(data.X,3));      %Initialize matrix of realized macro variables 
  for i=1:get(sm,'numSims');
    E_x = [];
    Y_x = [];
    
    %Compute matrix of expected macro variables for each month, as of the start of that year.    
    for h=1:get(sm,'simT')*get(sm,'histN'); %for each simulated month
       if mod(h-1,12)==0;
        if h==1;
          E_x(:,h) = Xlag(1,:)';    %for first month of simulation
        else;
          E_x(:,h) = para.B(:,1)+para.B(:,2:K+1)*data.X(h-1,:,i)';  %for first month of future years 
        end;
      else;
        E_x(:,h) = para.B(:,1)+para.B(:,2:K+1)*E_x(:,h-1);  %for months (2-12) after first, uses forecast for previous month
      end;
    end;    
    
    %1st macro forecast: expected average real GDP growth for that quarter
    yMacro(:,1,i) = E_x(beg+4,Q40).*(1+E_x(beg+1,Q40)); %product of that quarter's expected potential output growth and expected output gap
    
    %2nd macro forecast: expected average inflation for the previous year (quarterly basis)
 yMacro(1:sm.simN,2,i) = -1 + (1+mean(Xyearlag(5,:))).^(1/sm.simN); %first year of simulation
    for tt=sm.simN+1:sm.simN*get(sm,'simT')
      if mod(tt-1,sm.simN)==0
        yMacro([tt:tt+sm.simN-1],2,i)= ...
            -1 + (1+mean(data.X(Q40(tt-sm.simN:tt-1),beg+5,i))).^(1/sm.simN);   %subsequent years
      end
    end
    
    %3rd macro forecast: expected average inflation for that year (quarterly basis)
    yMacro(:,3,i) = -1 + (1+E_x(beg+5,Q40)).^(1/sm.simN);
    
    %4th macro forecast: expected change in overnight rate in last 12 months (quarterly basis)
    rateDiff = E_x(beg+3,:) - [ Xyearlag(3,:)  E_x(beg+3,1:end-12) ];
    yMacro(:,4,i) = rateDiff(Q40)/sm.simN;
    
    %5th macro forecast: expected lagged change in overnight rate is past 12 months (quarterly basis)
    rateDiff2 = [ Xyearlag(3,:) data.X(1:end-12,beg+3,i)' ] - ...
        [ Xyearlag13(3,:) Xyearlag(3,:) data.X(1:end-24,beg+3,i)' ];
    yMacro(:,5,i) = rateDiff2(Q40)/sm.simN;
  end;
  


  
  
%% 4. Compute macroeconomic forecasts for VAR(2) specification. 
elseif lags==2;
  eMacro = zeros(40,beg,size(data.X,3));    %Initialize matrix of expected macro variables 
  yMacro = zeros(40,5,size(data.X,3));      %Initialize matrix of realized macro variables 
    for i=1:get(sm,'numSims')
    E_x = [];
    
    %Compute matrix of expected macro variables for each month, as of the start of that year.
    for h=1:get(sm,'simT')*get(sm,'histN') %for first month of a year
      if mod(h-1,12)==0; 
        if h==1;
          E_x(:,h) = Xlag(2,:)';    
        else    
          E_x(:,h) = para.B(:,1)+para.B(:,2:K+1)*data.X(h-1,:,i)'...
            + para.B(:,K+2:2*K+1)*data.X(h-2,:,i)';
        end

      elseif mod(h-2,12)==0;    %for second month of a year, uses forecasts 
        if h==2;    
          E_x(:,h) = Xlag(1,:)';
        else
          E_x(:,h) = para.B(:,1)+para.B(:,2:K+1)*E_x(:,h-1)...
            + para.B(:,K+2:2*K+1)*data.X(h-2,:,i)';
        end
 
      else  %for other months of a year, uses forecasts 
        E_x(:,h) = para.B(:,1)+para.B(:,2:K+1)*E_x(:,h-1)...
          + para.B(:,K+2:2*K+1)*E_x(:,h-2);
      end
    end

    %1st macro forecast: expected average real GDP growth for that quarter
    %Since computation of expected variables in VAR(2) is conditional on previous
    %quarter, use output gap relative to previous quarter
    switch lower(get(sm,'startLag'))
        case {'ltm', 0}
            yMacro(1,1,i)=(((1+E_x(beg+1,Q40(1)))./(1+0))-1)+E_x(beg+4,Q40(1)); %LTM starting point for output gap is 0
    	otherwise
    		yMacro(1,1,i)=(((1+E_x(beg+1,Q40(1)))./(1+M(1,end)))-1)+E_x(beg+4,Q40(1));
    end
    for tt=2:4
      yMacro(tt,1,i)=(((1+E_x(beg+1,Q40(tt)))./(1+E_x(beg+1,Q40(tt-1))))-1)...
    	  +E_x(beg+4,Q40(tt));      
    end
    
    for tt=get(sm,'simN')+1:get(sm,'simN')*get(sm,'simT')
      if mod(tt-1,get(sm,'simN'))==0;
	yMacro(tt,1,i)=(((1+E_x(beg+1,Q40(tt)))./...
	    (1+data.X(Q40(tt-1),beg+1,i)))-1)+E_x(beg+4,Q40(tt));
      else
    	yMacro(tt,1,i)=(((1+E_x(beg+1,Q40(tt)))./...
    	    (1+E_x(beg+1,Q40(tt-1))))-1)+E_x(beg+4,Q40(tt));
      end
    end
   
    %2nd macro forecast: expected average inflation for the previous year (quarterly basis)
    yMacro(1:sm.simN,2,i) = -1 + (1+mean(Xyearlag(5,:))).^(1/sm.simN);
    for tt=sm.simN+1:sm.simN*get(sm,'simT')
      if mod(tt-1,sm.simN)==0
        yMacro([tt:tt+sm.simN-1],2,i)= ...
         -1 + (1+mean(data.X(Q40(tt-sm.simN:tt-1),beg+5,i))).^(1/sm.simN);
      end
    end

    %3rd macro forecast: expected average inflation for that quarter (quarterly basis)
    yMacro(:,3,i) = -1 + (1+E_x(beg+5,Q40)).^(1/sm.simN);
        
    %4th macro forecast: expected change in overnight rate in last 12 months (quarterly basis)
    rateDiff = E_x(beg+3,:) - [ Xyearlag(3,:)  E_x(beg+3,1:end-12) ];
    yMacro(:,4,i) = rateDiff(Q40)/sm.simN;
    
    %5th macro forecast: expected lagged change in overnight rate is past 12 months (quarterly basis)
    rateDiff2 = [ Xyearlag(3,:) data.X(3:end-12,beg+3,i)' ] - ...
        [ Xyearlag13(3,:) Xyearlag(3,:) data.X(3:end-24,beg+3,i)' ];
    yMacro(:,5,i) = rateDiff2(Q40)/sm.simN;  
  end;

  
%% 5. Compute macroeconomic forecasts for VAR(6) specification. 
elseif lags==6;
  eMacro = zeros(40,beg,size(data.X,3));
  yMacro = zeros(40,5,size(data.X,3));
  for i=1:get(sm,'numSims')
    E_x = [];
    
    %Compute matrix of expected macro variables for each month, as of the start of that year. They all use forecasts.
    for h=1:get(sm,'simT')*get(sm,'histN')
      if mod(h-1,12)==0;    %first month in year
        if h==1;
          E_x(:,h) = Xlag(6,:)';
        else
          E_x(:,h) = para.B(:,1)+para.B(:,2:K+1)*data.X(h-1,:,i)'...
            + para.B(:,K+2:2*K+1)*data.X(h-2,:,i)'...
          + para.B(:,2*K+2:3*K+1)*data.X(h-3,:,i)'...
          + para.B(:,3*K+2:4*K+1)*data.X(h-4,:,i)'... 
          + para.B(:,4*K+2:5*K+1)*data.X(h-5,:,i)'...
          + para.B(:,5*K+2:6*K+1)*data.X(h-6,:,i)';
  
        end
        
      elseif mod(h-2,12)==0;    %second month in year
        if h==2;    
          E_x(:,h) = Xlag(5,:)';
        else
          E_x(:,h) = para.B(:,1)+para.B(:,2:K+1)*data.X(h-1,:,i)'...
            + para.B(:,K+2:2*K+1)*data.X(h-2,:,i)'...
          + para.B(:,2*K+2:3*K+1)*data.X(h-3,:,i)'...
          + para.B(:,3*K+2:4*K+1)*data.X(h-4,:,i)'... 
          + para.B(:,4*K+2:5*K+1)*data.X(h-5,:,i)'...
          + para.B(:,5*K+2:6*K+1)*data.X(h-6,:,i)';
        end
       
      elseif mod(h-3,12)==0;    %third month in year
        if h==3;
          E_x(:,h) = Xlag(4,:)';
        else
          E_x(:,h) = para.B(:,1)+para.B(:,2:K+1)*data.X(h-1,:,i)'...
            + para.B(:,K+2:2*K+1)*data.X(h-2,:,i)'...
          + para.B(:,2*K+2:3*K+1)*data.X(h-3,:,i)'...
          + para.B(:,3*K+2:4*K+1)*data.X(h-4,:,i)'... 
          + para.B(:,4*K+2:5*K+1)*data.X(h-5,:,i)'...
          + para.B(:,5*K+2:6*K+1)*data.X(h-6,:,i)';
        end
    
      elseif mod(h-4,12)==0;    %fourth month in year
        if h==4;
          E_x(:,h) = Xlag(3,:)';
        else
          E_x(:,h) = para.B(:,1)+para.B(:,2:K+1)*data.X(h-1,:,i)'...
            + para.B(:,K+2:2*K+1)*data.X(h-2,:,i)'...
          + para.B(:,2*K+2:3*K+1)*data.X(h-3,:,i)'...
          + para.B(:,3*K+2:4*K+1)*data.X(h-4,:,i)'... 
          + para.B(:,4*K+2:5*K+1)*data.X(h-5,:,i)'...
          + para.B(:,5*K+2:6*K+1)*data.X(h-6,:,i)';
        end

      elseif mod(h-5,12)==0;    %fifth month in year
        if h==5;
          E_x(:,h) = Xlag(2,:)';
        else
          E_x(:,h) = para.B(:,1)+para.B(:,2:K+1)*data.X(h-1,:,i)'...
            + para.B(:,K+2:2*K+1)*data.X(h-2,:,i)'...
          + para.B(:,2*K+2:3*K+1)*data.X(h-3,:,i)'...
          + para.B(:,3*K+2:4*K+1)*data.X(h-4,:,i)'... 
          + para.B(:,4*K+2:5*K+1)*data.X(h-5,:,i)'...
          + para.B(:,5*K+2:6*K+1)*data.X(h-6,:,i)';
        end

      elseif mod(h-6,12)==0;    %sixth month in year
        if h==6;
          E_x(:,h) = Xlag(1,:)';
        else
          E_x(:,h) = para.B(:,1)+para.B(:,2:K+1)*data.X(h-1,:,i)'...
            + para.B(:,K+2:2*K+1)*data.X(h-2,:,i)'...
          + para.B(:,2*K+2:3*K+1)*data.X(h-3,:,i)'...
          + para.B(:,3*K+2:4*K+1)*data.X(h-4,:,i)'... 
          + para.B(:,4*K+2:5*K+1)*data.X(h-5,:,i)'...
          + para.B(:,5*K+2:6*K+1)*data.X(h-6,:,i)';
        end

      else  %rest of months in year
        E_x(:,h) = para.B(:,1)+para.B(:,2:K+1)*E_x(:,h-1)...
          + para.B(:,K+2:2*K+1)*E_x(:,h-2) ...
          + para.B(:,2*K+2:3*K+1)*E_x(:,h-3) ...
          + para.B(:,3*K+2:4*K+1)*E_x(:,h-4) ... 
          + para.B(:,4*K+2:5*K+1)*E_x(:,h-5) ...
          + para.B(:,5*K+2:6*K+1)*E_x(:,h-6) ;
      end
    end
    
    %1st macro forecast: expected average real GDP growth for that quarter
    %Since computation of expected variables in VAR(2) is conditional on previous
    %quarter, use output gap relative to previous quarter
    yMacro(:,1,i) = E_x(beg+4,Q40)+((1+E_x(beg+1,Q40))./(1+E_x(beg+1,Q40-1))-1);
   
    %2nd macro forecast: expected average inflation for last year (quarterly basis)
    yMacro(1:sm.simN,2,i) = -1 + (1+mean(Xyearlag(5,:))).^(1/sm.simN);
    for tt=sm.simN+1:sm.simN*get(sm,'simT')
      if mod(tt-1,sm.simN)==0
        %yMacro([tt:tt+sm.simN-1],2,i)= ...
        %  -1+geomean( 1+data.X(Q40(tt-sm.simN:tt-1),beg+1,i) );
        yMacro([tt:tt+sm.simN-1],2,i)= ...
            -1 + (1+mean(data.X(Q40(tt-sm.simN:tt-1),beg+5,i))).^(1/sm.simN);
      end
    end
    
    %3rd macro forecast: expected average inflation for that quarter (quarterly basis)
    yMacro(:,3,i) = -1 + (1+E_x(beg+5,Q40)).^(1/sm.simN);
    
    %4th macro forecast: expected change in overnight rate in last 12 months (quarterly basis)
    rateDiff = E_x(beg+3,:) - [ Xyearlag(3,:)  E_x(beg+3,1:end-12) ];
    yMacro(:,4,i) = rateDiff(Q40)/sm.simN;
    
    %5th macro forecast: expected lagged change in overnight rate is past 12 months (quarterly basis)
    rateDiff2 = [ Xyearlag(3,:) data.X(1:end-12,beg+3,i)' ] - ...
    [ Xyearlag13(3,:) Xyearlag(3,:) data.X(1:end-24,beg+3,i)' ];
    yMacro(:,5,i) = rateDiff2(Q40)/sm.simN;  
  end;
end; 
  
  
%% 6. Plot Charts  
return

for k=1:size(data.X,3)
  err1(k,:)=1e4*mean(abs([data.eMacro(:,1,k) data.X(:,9,k) data.eMacro(:,1, ...
						  k)-data.X(:,9,k)]));
end
mean(err1)


fH=[linspace(1,37,10)
    linspace(2,38,10)
    linspace(3,39,10)
    linspace(4,40,10)]'


for k=1:size(data.X,3)
  err1(k,:)=1e4*mean(abs([data.eMacro(:,1,k) ...
		    data.X(:,9,k) ...
		    data.eMacro(:,1,k)-data.X(:,9,k)]));
end

for j=1:4
  for k=1:size(data.X,3)
    forecast(k,:,j)=mean((data.eMacro(fH(:,j),1,k)));
    err(k,:,j)=sqrt(sum((data.eMacro(fH(:,j),1,k)-data.X(fH(:,j),9,k)).^2)/9);
  end
end


plot(linspace(0.25,1,4),1e4*mean(squeeze(forecast)),'r','LineWidth',2.5)
hold on
plot(linspace(0.25,1,4),1e4*mean(squeeze(forecast))+norminv(0.95)*1e4*mean(squeeze(err)),'r:','LineWidth',2.5)
plot(linspace(0.25,1,4),1e4*mean(squeeze(forecast))-norminv(0.95)*1e4*mean(squeeze(err)),'r:','LineWidth',2.5)
hold off
xlabel('Time (yrs.)')
ylabel('Quarterly QDP (bps.)')
set(gca,'XTick',[0.25 0.5 0.75 1]);
set(gca,'XTickLabel',{'Q1';'Q2';'Q3';'Q4'});