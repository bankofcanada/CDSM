%% getEinflation.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function computes the expected inflation of future months, from the point of view of each month in the simulation

%% Function Syntax
function eInf = getEinflation(varargin)
%%
% VAR(1) model has 5 inputs, VAR(2) model has 7 inputs
%
% _eInf_ : matrix of inflation forecasts: [# of forecast months] x [# of simulated months] x [# of simulations]


%% 1. Compute expected inflation for VAR(1) model
%
% See _<getForwardParam.html getForwardParam>_
if nargin == 5
  %Initialize variables
  numForward = varargin{1}; %number of months of inflation forecasts
  X =          varargin{2}; %macro data for current month, y(t)
  idxInfl =    varargin{3}; %index of inflation in matrix (8)
  a0 =         varargin{4}; %VAR coefficients for constant term
  a1 =         varargin{5}; %VAR coefficients for first lag
  eInf = zeros(size(X,1),numForward,size(X,3)); %Initialize matrix of expected inflation simulations
  [A0 A1] = getForwardParam(numForward, a0, a1);    %Get parameters for each forecast equation
  
  %Extract parameters related to inflation only
  A0inf = squeeze( A0(idxInfl,ones(size(X,1),1),:) );
  for jj=1:size(X,2)
    A1inf(:,jj) = A1(idxInfl,jj,:);
  end
  
  %Compute expected inflation
  for i=1:size(X,3)
    eInf(:,:,i) = A0inf + X(:,:,i)*A1inf';
  end
  

%% 2. Compute expected inflation for VAR(2) model
%
% See _<getForwardParam.html getForwardParam>_
elseif nargin == 7
  %Initialize variables  
  numForward = varargin{1}; %number of months of inflation forecasts
  Xlag1 =      varargin{2}; %macro data for current month, y(t)
  Xlag2 =      varargin{3}; %macro data for previous month, y(t-1)
  idxInfl =    varargin{4}; %index of inflation in matrix (8)
  a0 =         varargin{5}; %VAR coefficients for constant term
  a1 =         varargin{6}; %VAR coefficients for first lag
  a2 =         varargin{7}; %VAR coefficients for second lag
  eInf = zeros(size(Xlag1,1),numForward,size(Xlag1,3));
  [A0 A1 A2] = getForwardParam(numForward, a0, a1, a2);

  %Extract parameter values related to inflation only.
  A0inf = squeeze( A0(idxInfl,ones(size(Xlag1,1),1),:) );
  for jj=1:size(Xlag1,2)
    A1inf(:,jj) = A1(idxInfl,jj,:);
    A2inf(:,jj) = A2(idxInfl,jj,:);
  end

  %Compute expected inflation
  for i=1:size(Xlag1,3)
    eInf(:,:,i) = A0inf + Xlag1(:,:,i)*A1inf' + Xlag2(:,:,i)*A2inf';
  end

else
  error('Wrong number of arguments. input has 5 (1-lag) or 7 (2-lags) elements.') 
end