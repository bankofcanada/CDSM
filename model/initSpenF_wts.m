%% initSpen_F.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine loads the parameters describing the penalty functions - for increasing effective coupon rates on debt when issuance amount is outside allowable ranges.
% The values below are for demo purpose only, they are required to be
% calibrated every year.

%% 1. Define allowable ranges for each instrument
%s.terms = repmat([1 2 4 9 13 21 29 42 128 9 21 42 132],2,1);
s.nNomInst = 9;

s.issueRanges=[ 25      70;    % 3 mos. 
                13      21;  % 6 mos. 
                11      17;  % 12 mos.
                2.5      8;     % 2 yrs.
                2        3.5;     % 3 yrs.
                2.5      7.5;     % 5 yrs.
                2       3.5;     % 7 yrs.
                2         5;     % 10 yrs.
                0.8     2;      % 30 yrs.
                3/4     7/4;      % 2 yrs. infl.indexed
                12/4    13/4;      % 5 yrs. infl.indexed
                1.0/4  1;      % 10 yrs. infl.indexed
                0.85     1.2];       % 30 yrs. rrb
 %                1.25      1.4];       % 30 yrs. rrb
%                   1.5  1.6];

% 3-month
x_upper(1,:) = [s.issueRanges(1,2)+[0 6 12 18 25 38 64 90 172 290 550]];
% p_upper(1,:) = [0 3.3 4.7 6.5 11 22 32 42 68 130 265]; % 1
p_upper(1,:) = [0 2.75 6 10 16.5 27.5 47 60 118 164 282]*0.75; % 1 
% 6-month
x_upper(2,:) = [s.issueRanges(2,2) + [0 2.5 5 7.5 11.5 16.5 25 38 70 130 275]];
%p_upper(2,:) = [0 2.9 3.7 4.55 7 12.5 20 38 70 116 200]*3.75;
p_upper(2,:) = [ 0 3 6.25 10.25 15.75 23.5 33.5 48 85 155.5 275];
% 12-month
x_upper(3,:) = [s.issueRanges(3,2) + [0 2.5 5 7.5 11.5 16.5 25 38 60 95 145]];
%p_upper(3,:) = [0 10 15 20 25 35 40 50 60 70 85];
p_upper(3,:) = [0 3.78 4.62 6.62 9 11.75 19 30 60 122 215]*1.85;
% 2-year
x_upper(4,:) = [s.issueRanges(4,2)+ [0 0.5 1 2.5 5 10 16 25 35 45 56]];
%p_upper(4,:) = [0 5  10  15 25   40  90 95 102 104  155];
p_upper(4,:) = [0 1 1.2 1.52 2.3 4.3 7.75 18 30 40 55]*1.15;
% 3-year
x_upper(5,:) = [s.issueRanges(5,2)+ [0 0.25 0.75 1.5 3.5 8 13 18 30 40 52]];
%p_upper(5,:) = [0 5  10  15 25   40  90 95 102 104  155];
p_upper(5,:) = [0 0.8 1.1 1.5 2.4 5 9.2 18 38 62 90]*1.6; %0.48
% 5-year
x_upper(6,:) = [s.issueRanges(6,2)+[0 0.5 1 1.5 2.5 5 7.5 10 13.5 17 23.5]];
%p_upper(6,:) = [0 20 40  60 80   120 125 127 130 132 195];
p_upper(6,:) = [0 1.5 1.9 2.5 5 8.25 14 20 31 41 57];
% 7-year
x_upper(7,:) = [s.issueRanges(7,2)+[0 0.5 1 1.5 2.5 4.5 6.5 9 12 15 20]];
%p_upper(7,:) = [0 20 40  60 80   120 125 127 130 132 195];
p_upper(7,:) = [0 2.5 5.5 8.5 14 25 35 50 68 86 115];

% 10-year
x_upper(8,:) = [s.issueRanges(8,2) + [0 0.5 1 1.5 2 3 4 6 8 10 13]];
%p_upper(8,:) = [0 10 15  20 30   50  52 55  57 59 60];
p_upper(8,:) = [0 2.25 3.1 4.35 7.5 12.5 18 29.5 41.5 55.5 85] *0.65;
% 30-year
x_upper(9,:) = [s.issueRanges(9,2) + [0 0.25 0.5 0.75 1 1.25 1.5 1.75 2.25 2.75 3.5]];
p_upper(9,:) = [0 5 6 8 11 15 21 28 37 48 64.5]*0.6;

% 2-year RRB
x_upper(s.nNomInst+1,:) = [s.issueRanges(s.nNomInst+1,2) 1.25 1.5 1.75 2 2.25 2.5 2.75 3 3.2 3.5];
p_upper(s.nNomInst+1,:) = [0 5 6 10 14 19 25 29 32 40 50];

% 5-year RRB
x_upper(s.nNomInst+2,:) = [s.issueRanges(s.nNomInst+2,2) 4  4.5  5 6.25 7.5 8.5 10  12 15 20];
p_upper(s.nNomInst+2,:) = [0 20 40  60 80   120 125 127 130 132 195];

% 10-year rrb
x_upper(s.nNomInst+3,:) = [s.issueRanges(s.nNomInst+3,2) 1.25 1.5  1.75 2  2.25 2.5 2.75 3  3.2  3.5];
p_upper(s.nNomInst+3,:) =  [0 25 26.7 30   35 41.7 50  60   71.7   82.2  100];
% 30-year rrb
x_upper(s.nNomInst+4,:) = [s.issueRanges(s.nNomInst+4,2)+[0 0.25 0.5 0.75 1 1.25 1.5 2 2.5 3 3.5]];
p_upper(s.nNomInst+4,:) =  [0 9.5 19 28.5 40 53 68 86 105 131 164];%*1.15;
% Cost is a piecewise polynomial about s.issueRanges


for k=1:s.nNomInst+4;
  X=[ones(11,1) x_upper(k,:)' (x_upper(k,:).^2)'];
  s.beta(:,k)=inv(X'*X)*X'*p_upper(k,:)';  
end
s.m1(1)=-20/(s.issueRanges(1,1)^2);          
s.m1(2)=-10/(s.issueRanges(2,1)^2);          
s.m1(3)=-5/(s.issueRanges(3,1)^2);          
s.m1(4)=10/(s.issueRanges(4,1)^2);          
s.m1(5)=10/(s.issueRanges(5,1)^2);          
s.m1(6)=10/(s.issueRanges(6,1)^2);          
s.m1(7)=10/(s.issueRanges(7,1)^2);          
s.m1(8)=-25/(s.issueRanges(8,1)^2);          
s.m1(9)=-28/(s.issueRanges(9,1)^2);          
s.m1(s.nNomInst+1)=-50/(s.issueRanges(s.nNomInst+1,1)^2); 
s.m1(s.nNomInst+2)=-50/(s.issueRanges(s.nNomInst+2,1)^2);
s.m1(s.nNomInst+3)=-50/(s.issueRanges(s.nNomInst+3,1)^2);          
s.m1(s.nNomInst+4)=-50/(s.issueRanges(s.nNomInst+4,1)^2);
% s.m1(s.nNomInst+4)=-135/(s.issueRanges(s.nNomInst+4,1)^2); 
%s.m1(s.nNomInst+4)=-275/(s.issueRanges(s.nNomInst+4,1)^2);

s.penFactor(1:13) = 1;