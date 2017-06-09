%% computeS_condVol.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine computes various conditional volatility metrics for the
% given financing strategy. 
%
% Conditional cost volatility (cCV) and conditional budgetary volatility
% (cBV) describe the year-to-year volatility of debt costs and budgetary
% balance, respectively, across a given time period.


%% 1. Conditional cost volatility (cCV)
surp = s.frSurplusPerYear;

% For full simulation horizon
DCD_lag=m.DCD(1:s.nscenario,1:end-1,p);
DCD_now=m.DCD(1:s.nscenario,2:end,p);
Xd=[ones(size(DCD_lag,1)*size(DCD_lag,2),1) ...
   reshape(DCD_lag,size(DCD_lag,1)*size(DCD_lag,2),1)];
Yd=reshape(DCD_now,size(DCD_now,1)*size(DCD_now,2),1);
thetaA=inv(Xd'*Xd)*Xd'*Yd;
m.cv.cCV(p)=sqrt((Yd-Xd*thetaA)'*(Yd-Xd*thetaA)/(size(DCD_lag,1)* ...
					      size(DCD_lag,2)-2)); 
clear DCD_lag DCD_now Xd Yd thetaA;

% For first half of simulation horizon (Years 1-5)
DCD_lag_1H=m.DCD(1:s.nscenario,1:(s.nperiod/4/2)-1,p);
DCD_now_1H=m.DCD(1:s.nscenario,2:(s.nperiod/4/2),p);
Xd_1H=[ones(size(DCD_lag_1H,1)*size(DCD_lag_1H,2),1) ...
   reshape(DCD_lag_1H,size(DCD_lag_1H,1)*size(DCD_lag_1H,2),1)];
Yd_1H=reshape(DCD_now_1H,size(DCD_now_1H,1)*size(DCD_now_1H,2),1);
thetaA_1H=inv(Xd_1H'*Xd_1H)*Xd_1H'*Yd_1H;
m.cv.cCV_1stHalf(p)=sqrt((Yd_1H-Xd_1H*thetaA_1H)'*(Yd_1H-Xd_1H*thetaA_1H)/(size(DCD_lag_1H,1)* ...
					      size(DCD_lag_1H,2)-2)); 
clear DCD_lag_1H DCD_now_1H Xd_1H Yd_1H thetaA_1H;

% For second half of simulation horizon (Years 6-10)
DCD_lag_2H=m.DCD(1:s.nscenario,(s.nperiod/4/2)+1:end-1,p);
DCD_now_2H=m.DCD(1:s.nscenario,(s.nperiod/4/2)+2:end,p);
Xd_2H=[ones(size(DCD_lag_2H,1)*size(DCD_lag_2H,2),1) ...
   reshape(DCD_lag_2H,size(DCD_lag_2H,1)*size(DCD_lag_2H,2),1)];
Yd_2H=reshape(DCD_now_2H,size(DCD_now_2H,1)*size(DCD_now_2H,2),1);
thetaA_2H=inv(Xd_2H'*Xd_2H)*Xd_2H'*Yd_2H;
m.cv.cCV_2ndHalf(p)=sqrt((Yd_2H-Xd_2H*thetaA_2H)'*(Yd_2H-Xd_2H*thetaA_2H)/(size(DCD_lag_2H,1)* ...
					      size(DCD_lag_2H,2)-2)); 
clear DCD_lag_2H DCD_now_2H Xd_2H Yd_2H thetaA_2H;


%% 2. Conditional budgetary volatility (cBV)
switch s.frFeedback
    case 'yes'  
        % For full simulation horizon
        FR_lag=m.fr.FinReq(1:s.nscenario,1:end-1,p) + repmat(surp(1:end-1),s.nscenario,1);
        FR_now=m.fr.FinReq(1:s.nscenario,2:end,p)+ repmat(surp(2:end),s.nscenario,1);
        Xf=[ones(size(FR_lag,1)*size(FR_lag,2),1) ...
           reshape(FR_lag,size(FR_lag,1)*size(FR_lag,2),1)];
        Yf=reshape(FR_now,size(FR_now,1)*size(FR_now,2),1);
        thetaA=inv(Xf'*Xf)*Xf'*Yf;
        m.cv.cAdjBV(p)=sqrt((Yf-Xf*thetaA)'*(Yf-Xf*thetaA)/(size(FR_lag,1)* ...
                                  size(FR_lag,2)-2));

        clear FR_lag FR_now Xf Yf thetaA;

        % For first half of simulation horizon (Years 1-5)
        FR_lag_1H=m.fr.FinReq(1:s.nscenario,1:(s.nperiod/4/2)-1,p) + repmat(surp(1:(s.nperiod/4/2)-1),s.nscenario,1);
        FR_now_1H=m.fr.FinReq(1:s.nscenario,2:(s.nperiod/4/2),p) + repmat(surp(2:(s.nperiod/4/2)),s.nscenario,1);
        Xf_1H=[ones(size(FR_lag_1H,1)*size(FR_lag_1H,2),1) ...
           reshape(FR_lag_1H,size(FR_lag_1H,1)*size(FR_lag_1H,2),1)];
        Yf_1H=reshape(FR_now_1H,size(FR_now_1H,1)*size(FR_now_1H,2),1);
        thetaA_1H=inv(Xf_1H'*Xf_1H)*Xf_1H'*Yf_1H;
        m.cv.cAdjBV_1stHalf(p)=sqrt((Yf_1H-Xf_1H*thetaA_1H)'*(Yf_1H-Xf_1H*thetaA_1H)/(size(FR_lag_1H,1)* ...
                                  size(FR_lag_1H,2)-2));
        clear FR_lag_1H FR_now_1H Xf_1H Yf_1H thetaA_1H;

        % For second half of simulation horizon (Years 6-10)
        FR_lag_2H=m.fr.FinReq(1:s.nscenario,(s.nperiod/4/2)+1:end-1,p) + repmat(surp((s.nperiod/4/2)+1:end-1),s.nscenario,1);
        FR_now_2H=m.fr.FinReq(1:s.nscenario,(s.nperiod/4/2)+2:end,p) + repmat(surp((s.nperiod/4/2)+2:end),s.nscenario,1);
        Xf_2H=[ones(size(FR_lag_2H,1)*size(FR_lag_2H,2),1) ...
           reshape(FR_lag_2H,size(FR_lag_2H,1)*size(FR_lag_2H,2),1)];
        Yf_2H=reshape(FR_now_2H,size(FR_now_2H,1)*size(FR_now_2H,2),1);
        thetaA_2H=inv(Xf_2H'*Xf_2H)*Xf_2H'*Yf_2H;
        m.cv.cAdjBV_2ndHalf(p)=sqrt((Yf_2H-Xf_2H*thetaA_2H)'*(Yf_2H-Xf_2H*thetaA_2H)/(size(FR_lag_2H,1)* ...
                                  size(FR_lag_2H,2)-2));
        clear FR_lag_2H FR_now_2H Xf_2H Yf_2H thetaA_2H;

end

clear surp