%% initSpen_F.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine loads the parameters describing the penalty functions - for increasing effective coupon rates on debt when issuance amount is outside allowable ranges.


%% 1. Define allowable ranges for each instrument
s.nNomInst = 9;

s.issueRanges=[ ---  ---;    % 3m 
                ---  ---;     % 6m 
                ---  ---;  % 12m
                ---  ---;     % 2Y
                ---  ---;     % 3Y
                ---  ---;     % 5Y
                ---  ---;     % 7Y
                ---  ---;     % 10Y
                ---  ---;      % 30Y
                ---  ---;      % 2Y RRB
                ---  ---;      % 5Y RRB
                ---  ---;      % 10Y RRB
                ---  ---];       % 30Y RRB


%% 2. Define point estimates for additional coupon associated with amounts of over-issuance            

% 3-month
x_upper(1,:) = [s.issueRanges(1,2)+[--- --- --- --- --- --- --- --- --- --- ---]];
p_upper(1,:) = [--- --- --- --- --- --- --- --- --- --- ---]; % 1 

% 6-month
x_upper(2,:) = [s.issueRanges(2,2) + [--- --- --- --- --- --- --- --- --- --- ---]];
p_upper(2,:) = [--- --- --- --- --- --- --- --- --- --- ---];

% 12-month
x_upper(3,:) = [s.issueRanges(3,2) + [--- --- --- --- --- --- --- --- --- --- ---]];
p_upper(3,:) = [--- --- --- --- --- --- --- --- --- --- ---];

% 2-year
x_upper(4,:) = [s.issueRanges(4,2)+ [--- --- --- --- --- --- --- --- --- --- ---]];
p_upper(4,:) = [--- --- --- --- --- --- --- --- --- --- ---];

% 3-year
x_upper(5,:) = [s.issueRanges(5,2)+ [--- --- --- --- --- --- --- --- --- --- ---]];
p_upper(5,:) = [--- --- --- --- --- --- --- --- --- --- ---]; 

% 5-year
x_upper(6,:) = [s.issueRanges(6,2)+[--- --- --- --- --- --- --- --- --- --- ---]];
p_upper(6,:) = [--- --- --- --- --- --- --- --- --- --- ---];

% 7-year
x_upper(7,:) = [s.issueRanges(7,2)+[--- --- --- --- --- --- --- --- --- --- ---]];
p_upper(7,:) = [--- --- --- --- --- --- --- --- --- --- ---];

% 10-year
x_upper(8,:) = [s.issueRanges(8,2) + [--- --- --- --- --- --- --- --- --- --- ---]];
p_upper(8,:) = [--- --- --- --- --- --- --- --- --- --- ---];

% 30-year
x_upper(9,:) = [s.issueRanges(9,2) + [--- --- --- --- --- --- --- --- --- --- ---]];
p_upper(9,:) = [--- --- --- --- --- --- --- --- --- --- ---];

% 2-year RRB
x_upper(s.nNomInst+1,:) = [s.issueRanges(s.nNomInst+1,2) --- --- --- --- --- --- --- --- --- --- ---];
p_upper(s.nNomInst+1,:) = [--- --- --- --- --- --- --- --- --- --- ---];

% 5-year RRB
x_upper(s.nNomInst+2,:) = [s.issueRanges(s.nNomInst+2,2) --- --- --- --- --- --- --- --- --- --- ---];
p_upper(s.nNomInst+2,:) = [--- --- --- --- --- --- --- --- --- --- ---];

% 10-year RRB
x_upper(s.nNomInst+3,:) = [s.issueRanges(s.nNomInst+3,2) --- --- --- --- --- --- --- --- --- --- ---];
p_upper(s.nNomInst+3,:) =  [--- --- --- --- --- --- --- --- --- --- ---];

% 30-year RRB
x_upper(s.nNomInst+4,:) = [s.issueRanges(s.nNomInst+4,2)+[--- --- --- --- --- --- --- --- --- --- ---]];
p_upper(s.nNomInst+4,:) =  [--- --- --- --- --- --- --- --- --- --- ---];


%% 3. Regress point estimates into continuous penalty functions
for k=1:s.nNomInst+4;
  X=[ones(11,1) x_upper(k,:)' (x_upper(k,:).^2)'];
  s.beta(:,k)=inv(X'*X)*X'*p_upper(k,:)';  
end
s.m1(1)=---/(s.issueRanges(1,1)^2);          
s.m1(2)=---/(s.issueRanges(2,1)^2);          
s.m1(3)=---/(s.issueRanges(3,1)^2);          
s.m1(4)=---/(s.issueRanges(4,1)^2);          
s.m1(5)=---/(s.issueRanges(5,1)^2);          
s.m1(6)=---/(s.issueRanges(6,1)^2);          
s.m1(7)=---/(s.issueRanges(7,1)^2);          
s.m1(8)=---/(s.issueRanges(8,1)^2);          
s.m1(9)=---/(s.issueRanges(9,1)^2);          
s.m1(s.nNomInst+1)=---/(s.issueRanges(s.nNomInst+1,1)^2); 
s.m1(s.nNomInst+2)=---/(s.issueRanges(s.nNomInst+2,1)^2);
s.m1(s.nNomInst+3)=---/(s.issueRanges(s.nNomInst+3,1)^2);          
s.m1(s.nNomInst+4)=---/(s.issueRanges(s.nNomInst+4,1)^2);

s.penFactor(1:13) = 1;