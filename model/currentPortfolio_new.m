%% currentPortfolio_new.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of the DEBT CHARGE ENGINE.

% Updated Jan 2009
byear =2009;
% quarter end and quarter start months
qE = [ 3 6 9 12];
qS = qE - 2;
% Outstanding bond data as of end Sept 2008
% bonds= [year month day coupon issue]

bonds =[    2009	3	1	11.5	139655000  1985
            2009	6	1	3.75	1965828000  2006
            2009	6	1	5.5	    5722192000  1998
            2009	6	1	11	     635846000  1985
            2009	9	1	4.25	7685202000  2003
            2009	10	1	10.75	207790000  1985
            2009	12	1	4.25	6424000000  2007
            2010	3	1	9.75	79534000  1986
            2010	6	1	3.75	3700000000  2007
            2010	6	1	5.5	    5127128000  1999
            2010	6	1	9.5	    2224605000  1986
            2010	9	1	4	    7394884000  2004
            2010	10	1	8.75	97018000  1986 
            2010	12	1	2.75	12184302000  2008
            2011	3	1	9	    463681000  1986
            2011	6	1	6	    9802369000  2000
            2011	6	1	8.5	    606151000  1987
            2011	9	1	3.75	8766862000  2005
            2012	6	1	3.75	6799165000  2006
            2012	6	1	5.25	10356853000  2001
            2013	6	1	3.5	    15063624000  2008
            2013	6	1	5.25	8996594000  2002
            2014	3	15	10.25	709898000  1989
            2014	6	1	3	   3000000000  2008
            2014	6	1	5	   9753802000  2003
            2015	6	1	4.5	   10143325000 2004
            2015	6	1	11.25	456505000  1990
            2016	6	1	4	   10170000000 2005
            2017	6	1	4	   10342526000  2006
            2018	6	1	4.25	10622764000  2007
            2019	6	1	3.75	2800000000  2008
            2021	3	15	10.5	663361000   1990
            2021	6	1	9.75	352523000  1991
            2022	6	1	9.25	255312000  1991
            2023	6	1	8	   5000000000  1992
            2025	6	1	9	   5000000000  1994
            2027	6	1	8	   6471435000  1996
            2029	6	1	5.75	12826093000  1998
            2033	6	1	5.75	13410295000  2001
            2037	6	1	5	   13249089000  2004
            2041	6	1	4	   3000000000  2008 ];

% To approximate the original maturity of the issued bond.
bonds(:,end+1) = bonds(:,1)+bonds(:,2)/12-bonds(:,end);

% Outstanding bill data as of end June, 2008
% Treasury bills= [yr mth day  price  os  yld  mkt-value]
bills=[ 2009	1	8	11	18400000000	1.961376292
        2009	1	22	11	15600000000	2.103300654
        2009	2	5	11	17300000000	2.308741771
        2009	2	19	11	15900000000	2.181925137
        2009	3	5	11	13200000000	2.039304633
        2009	3	19	11	13900000000	1.649287411
        2009	4	2	11	15200000000	1.37608168
        2009	4	16	11	4900000000	2.790304933
        2009	4	30	11	6400000000	2.05420365
        2009	5	14	11	5500000000	2.797727936
        2009	5	28	11	7000000000	1.507846926
        2009	6	11	11	4600000000	3.277997346
        2009	6	25	11	3600000000	0.9769452
        2009	7	9	11	4200000000	3.101185186
        2009	8	6	11	4700000000	2.772735226
        2009	9	3	11	4000000000	2.533517
        2009	10	1	11	5400000000	2.325400178
        2009	10	29	11	6400000000	2.0679623
        2009	11	26	11	7000000000	1.514014789
        2009	12	24	11	3600000000	0.9776 ];

% Outstanding RRB bond data as of end June, 2008
% [year month day  coupon   issuance value   Yield   Inflation Adjusted value]
RRBs=[2021 12 1 4.25 5175000000 1.56 7134772500 1991
      2026 12 1 4.25 5250000000 1.6 6846840000 1996
      2031 12 1 4 5800000000 1.58 7269720000 2000
      2036 12 1 3 5850000000 1.57 6505902000 2004
      2041 12 1 2 3950000000 555  4067907500 2008  ];

% To approximate the original maturity of the issued bond.
RRBs(:,end+1) = RRBs(:,1)+RRBs(:,2)/12-RRBs(:,end);

% Rough back of envelope ATM calculation
(sum((bonds(:,1)-2008).*bonds(:,5)) + ...
 sum((bills(:,1)+(bills(:,2)/12)-2006.25).*bills(:,5)))...
    /(sum(bonds(:,5))+sum(bills(:,5)))

% Here we adjust maturity dates with simulation periods. So, the June
% 2033 will come to maturity in the 124=31*4 (2033-2002) simulated
% period. The idea is merely to transform the dates into quarters.
for i=1:length(bonds)
  if bonds(i,2)>=qS(1) & bonds(i,2)<=qE(1)
    bonds(i,1)=bonds(i,1)-byear + 0.25;
  elseif bonds(i,2)>=qS(2) & bonds(i,2)<=qE(2)
    bonds(i,1)=bonds(i,1)-byear + 0.5;
  elseif bonds(i,2)>=qS(3) & bonds(i,2)<=qE(3)
    bonds(i,1)=bonds(i,1)-byear + 0.75;
  elseif bonds(i,2)>=qS(4) & bonds(i,2)<=qE(4)
    bonds(i,1)=bonds(i,1)-byear + 1;
  end
end
bonds(:,5)=bonds(:,5)/1000000000;

% Here we do the same thing as for bills, i.e. we adjust maturity dates
% of bills with simulation periods.
for i=1:length(bills)
  if bills(i,2)>=qS(1) & bills(i,2)<=qE(1)
    bills(i,1)=bills(i,1)-byear+0.25;
  elseif bills(i,2)>=qS(2) & bills(i,2)<=qE(2)
    bills(i,1)=bills(i,1)-byear+0.5;
  elseif bills(i,2)>=qS(3) & bills(i,2)<=qE(3)
    bills(i,1)=bills(i,1)-byear+0.75;
  elseif bills(i,2)>=qS(4) & bills(i,2)<=qE(4)
    bills(i,1)=bills(i,1)-byear+1;
  end			
end
bills(:,5)=bills(:,5)/1000000000;
%bills(:,7)=bills(:,7)/1000000000; 

% bonds2 = zeros(length(bonds),7);
% jj = 1;
% for ii=1:length(bonds)
%     if bonds(ii,6) >= 2007
%         bonds2(ii,:) = bonds(ii,:)
%     end
% end
% 
%     if s.crown.obonds(ii) > 0
%         pds(jj) = ii;
%         jj = jj+1;
%         for mm=1:length(bonds)
%             if pds(jj) == 4*bonds(mm,1)


% Here we do the same thing as for RRBs, i.e. we adjust maturity dates
% of bills with simulation periods.
RRBs(:,5)=RRBs(:,5)/1000000000;
RRBs(:,7)=RRBs(:,7)/1000000000;
RRBs(:,1)=RRBs(:,1)-byear+1;

%opjopij
% Here we organize the bond maturities by their original issue maturity
% and compute debt charges associated with this debt.
% For bonds:
o.matbonds=zeros(s.nInst,160);
o.initialaccrual=zeros(s.nInst,160);
for i=1:length(bonds)
  if(bonds(i,end) <=3.5)
    o.matbonds(4,bonds(i,1)*4)=bonds(i,5);
    o.initialaccrual(4,1:bonds(i,1)*4)=o.initialaccrual(4,1:bonds(i,1)*4)...
	+bonds(i,4)*bonds(i,5)/400;
  elseif(bonds(i,end)<8)
    o.matbonds(6,bonds(i,1)*4)=bonds(i,5);
    o.initialaccrual(6,1:bonds(i,1)*4)=o.initialaccrual(6,1:bonds(i,1)*4)...
	+bonds(i,4)*bonds(i,5)/400;
  elseif(bonds(i,end)<20)
    o.matbonds(8,bonds(i,1)*4)=bonds(i,5);
    o.initialaccrual(8,1:bonds(i,1)*4)=o.initialaccrual(8,1:bonds(i,1)*4)...
	+bonds(i,4)*bonds(i,5)/400;
  else
    o.matbonds(9,bonds(i,1)*4)=bonds(i,5);
    o.initialaccrual(9,1:bonds(i,1)*4)=o.initialaccrual(9,1:bonds(i,1)*4)...
	+bonds(i,4)*bonds(i,5)/400;
  end
end

% For treasury bills:
for i=1:length(bills)
  if(bills(i,1) > 0.75)
    o.matbonds(3,4)=o.matbonds(3,4)+bills(i,5);
    o.initialaccrual(3,4)=o.initialaccrual(3,4)+bills(i,6)*bills(i,5)/400;  
  elseif(bills(i,1)>0.5)
    o.matbonds(3,3)=o.matbonds(3,3)+bills(i,5);
    o.initialaccrual(3,3)=o.initialaccrual(3,3)+bills(i,6)*bills(i,5)/400;  
  elseif(bills(i,1)>0.25)
    o.matbonds(2,2)=o.matbonds(2,2)+bills(i,5);
    o.initialaccrual(2,2)=o.initialaccrual(2,2)+bills(i,6)*bills(i,5)/400;  
  else
    o.matbonds(1,1)=o.matbonds(1,1)+bills(i,5);
    o.initialaccrual(1,1)=o.initialaccrual(1,1)+bills(i,6)*bills(i,5)/400;  
  end
end
% We don't have all the information we need for Treasury bills so we
% determine the allocation based on the relative weights that are issued
% over the last year.
terms=1./[1 2 4];
%wts1 = (s.billPercentage.*terms)/sum(s.billPercentage.*terms);
wts2 = s.billPercentage(2:end)/sum(s.billPercentage(2:end));
o.matbonds(1:3,1)=o.matbonds(1,1)*s.billPercentage';%wts1';
o.matbonds(2:3,2)=o.matbonds(2,2)*wts2';
o.initialaccrual(1:3,1)=o.initialaccrual(1,1)*s.billPercentage';%wts1';
o.initialaccrual(2:3,2)=o.initialaccrual(2,2)*wts2';

% For real-return bonds
for i=1:size(RRBs,1)
  % Here is the real amount for the RRBs -- recall that we refinance the
  % original amount issued (and assume that the inflation compensation
  % associated with the principal is paid over time).
  o.matbonds(s.nInst,RRBs(i,1)*4)=RRBs(i,5);
  % Here are the real coupons -- these values are not used directly, but
  % rather are used in the subsequent computation to place the coupons in
  % time t=0 terms.
  o.initialaccrual(s.nInst,1:RRBs(i,1)*4)=o.initialaccrual(s.nInst,1:RRBs(i,1)*4)...
	+RRBs(i,4)*RRBs(i,5)/400;
end

% Need to put the real coupon and maturities into time t=0 terms, we do
% this by adjusting for the actual inflation historical inflation
% observed since the issuance of these bonds.
% Historical inflation data.

% Here is the actual adjustment
o.initialaccrualReal=zeros(s.nInst,160);
o.initialmaturityReal=zeros(s.nInst,160);
for i=1:size(RRBs,1)
  o.initialmaturityReal(s.nInst,RRBs(i,1)*4)=RRBs(i,7);
  o.initialaccrualReal(s.nInst,1:RRBs(i,1)*4)=o.initialaccrual(s.nInst,1:RRBs(i,1)*4)...
	+RRBs(i,4)*RRBs(i,7)/400;  
end

% o.initialcharges are the total cost of the issued debt. We start in the
% second period because we make the asumption that the debt comes to
% maturity in the beginning of the period. This assumption makes more
% sense when we get o.matQ.
%o.initialcharges  = sum(o.coup(:,2:end));

o.matQ=sum(o.matbonds);
o.initialcharges = sum(o.initialaccrual(1:s.nNomInst,1))+...
                sum(o.initialaccrualReal(s.nNomInst+1:s.nInst,1));

% matQ is the amount coming to maturity for each of the next quarters.
%o.matQ=sum(o.outstanding(:,1:end-1))-sum(o.outstanding(:,2:end));
%o.matQ(length(o.matQ)+1:160)=0;  % We need a longer matQ for version1.

%o.matQ = o.initialmaturity;

% o.initialmaturity is used in 'version' to calculate 'issuance'. It has
% nothing to see with the maturity of the old debt. The only thing we can
% say is that it is usefull for version.
weitomat=[1 2 4 9 12.5 20 28 40 120 8 10 40 120];
issuanceweight=s.weight./weitomat;
sumissuanceweight=sum(issuanceweight);
relativeweight=issuanceweight./sumissuanceweight;

% 1/ The approach does not work -- it leads to a serious
% overissuance of short-term debt
%o.initialmaturity=relativeweight'*o.matQ;

% 2/ This approach does work, but it leads to an extremely
% fast (too fast, in fact) adjustment to the new debt stock.
%o.initialmaturity=s.weight'*o.matQ;

% 3/ This approach also appears to work and leads to a 
% more gradual transition to the new debt stock by using 
% the relative weights rule in (1), but stopping the allocation 
% of new issuance, once the target allocation is attained. The
% consequence is we avoid the overissuance of short-term debt
YY(1,:)=relativeweight'*o.matQ(1)/s.value;
for(i=2:length(o.matQ))
  YY(i,:)=relativeweight'*o.matQ(i)/s.value;
  for(j=1:length(relativeweight))
    if(sum(YY(1:i,j))>=s.weight(j) && o.matQ(i) ~=0)
      if(sum(YY(1:i-1,j)<s.weight(j)))
	YY(i,j)=s.weight(j)-sum(YY(1:i-1,j));
	remainder(i)=(o.matQ(i)-s.value*sum(YY(i,:)))/s.value;
	YY(i,j+1:end)=YY(i,j+1:end)+...
	    remainder(i)*YY(i,j+1:end)./sum(YY(i,j+1:end));	
      else
	YY(i,j)=0;
      end
    end
  end
end

% Populate o.initialmaturity, which represents how the maturities
% will be reissued to attain the new maturity proportions in the 
% new financing strategy.
for(i=1:length(o.matQ))
  if(sum(YY(i,:))==0)
    o.initialmaturity(i,:)=zeros(1,length(relativeweight));
  else
    o.initialmaturity(i,:)=(YY(i,:)./sum(YY(i,:)))*o.matQ(i);
  end
end
o.initialmaturity=o.initialmaturity';



