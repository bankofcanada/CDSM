%% estimate_new.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _nelsonSiegel_ class) estimates the parameters for vector autoregression (VAR) based on historical data

%% Method Syntax
function ns  = estimate_new(ns,varargin);
%%
% _ns_ : method is applied to, and updates, _nelsonSiegel_ class
%
% _varargin_ : optional inputs for VAR estimation settings


%% 1. Decompose yield curve into three Nelson-Siegel factors (level, slope, curvature) and compute their historical values. The three factors will be combined with the macro variables in the VAR parameterization. 
%
% See: _<../matlab/getFactors.html getFactors>_
[Xf,H,HSim] = getFactors(ns);


%% 2. Compute VAR parameters
%
% _See <../matlab/computeVAR.html computeVAR>_
[para,X] = computeVAR(ns,Xf,varargin{:});


%% 3. Adjust VAR parameters manually 
para1=para;
para.B(4,5) = para.B(4,5)-0.1;  %Lower YGAP's lag-1 autocorrelation
para.B(4,13) = para.B(4,13)+0.1; %Increase YGAP's lag-2 autocorrelation
para.B
ns=set(ns,'macro_data',X(get(ns,'dim')+1:end,:));   %Increase dimension of macro data for contemporaneous INFL


%% 4. Save VAR parameters into the 'parameters' structure in the 'nelsonSiegel' class
ns.parameters=para;
ns.parameters.X=X;
ns.parameters.H=[H zeros(length(H),size(X,1)-get(ns,'dim'))];
ns.parameters.HSim=[HSim zeros(length(HSim),size(X,1)-get(ns,'dim'))];
