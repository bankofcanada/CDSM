%% getFactors.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _nelsonSiegel_ class) uses Principal Components Analysis (PCA) to decompose the yield curve into three Nelson-Siegel factors (level, slope, curvature), and computes historical values for those factors

%% Method Syntax
function [X,H,HSim] = getFactors(ns);
%%
% _ns_ : method is applied to 'nelsonSiegel' class 
%
% _X_ : historical time series of three Nelson-Siegel factors
%
% _H_ : Nelson-Siegel factor loadings
%
% _HSim_ : Nelson-Siegel factor loadings based on adjusted tenors


%% 1. Compute Nelson-Siegel factor loadings for each factor (level, slope, curvature) 
%
% _See <ns_basis.html ns_basis>_
for(i=1:get(ns,'dim'))
  H(:,i) = ns_basis(get(ns,'ttm'),i,1/2.5)';
  HSim(:,i) = ns_basis(get(ns,'simTenor'),i,1/2.5)';    %factor loadings for alternate tenors, not used
end


%% 2. Load historical yield curve data
Z = get(ns,'zero_data');


%% 3. Solve for the historical factor values, for each month, through least-squares optimization
%
% _See <nsOF.html nsOF>_
options = optimset('MaxIter',5000,'Display','off','MaxFunEvals',10000,...
		   'TolFun',1e-10,'TolX',1e-10);    %optimization options

for(i=1:length(Z));
  xstart = [interp1(get(ns,'ttm'),Z(:,i),10);   %overwritten, not used
	    interp1(get(ns,'ttm'),Z(:,i),10) - ...
	    interp1(get(ns,'ttm'),Z(:,i),0.25);
	    interp1(get(ns,'ttm'),Z(:,i),2) - ...
	    (interp1(get(ns,'ttm'),Z(:,i),10) + ...
	     interp1(get(ns,'ttm'),Z(:,i),0.25))];
  xstart = ones(get(ns,'dim'),1);   %starting value for optimization is 1 for all factors
  X(:,i)=fminunc('nsOF',xstart,options,H,Z(:,i));   %unconstrained optimization of 'nsOF.m' function
end


%% 4. Display the fit to the data
disp([get(ns,'ttm')' 10000*(sqrt(sum((H*X-Z).^2,2)/(get(ns,'histT')* ...
						  get(ns,'histN'))))])