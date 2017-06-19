%% forward_split.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

function [model, Basis] = foward_split(model, X, y, varargin)

% function [model, Basis] = foward_split(model, X, y, varargin)
%
%
% varargin
% empty or scalar : value of max_domain in foward splitting the data.
%
%%%%%%
% Tiago Rubin & David Bolder, Bank of Canada, 2006
%%%%%%
% Called by mars().train(...)

%global Basis;

% Get dimensions
[nrow ncolx] = size(X);

%%%%%%%%%%%%
% Set the value of max_basis
%
max_basis = [];

if ~isempty(varargin{1})
    % max_basis was defined explicitly
    max_basis = varargin{1};
    model.max_domain = max_basis;
elseif ~isempty(model.max_domain)
    % max_basis is defined in model
    max_basis = model.max_domain;
elseif ~isempty(model.nsplits)
    % max_basis is undefined, but max number of splits is defined.
    max_basis = ceil(2.3*model.nsplits);
end

if isempty(max_basis)
    % max_basis undefined, default is sqrt of sample size    
    max_basis = 3 + 2*ceil( log2(size(X,1)) * ( (size(X,2)+1)^(1/2) ) );
    display(['Undefined mars max_domain, default is 5 + 2*ceil( log2(size(x,1)) * ( (size(x,2)+1)^(1/2) ) )'])
    model.max_domain = max_basis;
end

% Number of splits -- must be odd.
if mod(max_basis, 2)==0
    max_basis=max_basis+1;
end

%%%%%%%%%%%%
% Initialization
%
minDist   = get(model, 'minknotdist');          % Smoothing parameter for minimum observations between each knots.  Probability tolerance of having a "all same sign" error run is 2^-(minDist-1). Default = 5.
max_inter = model.max_interaction;              % maximum number of interacting (multiplied together) regressors.
if isempty(max_inter), max_inter = ncolx;
end

depth = 0;                                      % The depth of the basis function (cannot permit quadratic terms)
yhat  = 0*y;
tstar = zeros(max_basis, ncolx);     % Knots value for each Basis
x_in  = zeros(max_basis, ncolx);     % variables x_in are {-1,0,1}, indicating if variable x is negative, not included or positive in Basis

Basis = zeros(nrow, max_basis);

%%%%%%%%%%%%
% Generate a matrix of sorted-index of regressors's columns
%
sortedIndex = zeros(size(X));
[sortedx, sortedIndex] = sort( X, 1 );

%%%%%%%%%%%%
% Prepare coming loop
%
Basis(:,1)= 1;             % First basis function covers entire domain.
splits    = 2;             % Begin the loop at second basis function.

%%%%%%%%%%%%
% FOWARD-SPLIT loop
% Start the loop to find all best Basis functions	    
%
while splits < max_basis
  lof = [inf,inf]; 
  kk  = [0,0]; % split variable (x_1,...,x_v)
  ss  = [0,0]; % split location (where we are in the tree)
  tt  = [0,0]; % split point
  DD  = [0,0]; % split distance from edge of its domain
  
  % loop over number of variables
  for k = 1:ncolx 
      
    % loop over number of splits previously created    
    for s = 1:splits-1
      xin_s   = x_in(s,:);
      tstar_s = tstar(s,:);
      tmplof  = inf;  
      
      % Don't create quadratic terms (can't go deeper than dim(x)) AND don't consider higher than max_interaction
      if ( xin_s(k) == 0 ) && ( sum(abs( xin_s )) < max_inter )

        nextDist = 0;
        dist     = 0;

        for t = 1:nrow
              
              xSplit = X( sortedIndex(t,k) , : );               % Look at observations in increasing direction
             
              if ( (xin_s .* xSplit) >= (xin_s .* tstar_s) )    % if ( all elements in xSplit are in domain bounded by t_star)
                  if ( dist == nextDist )

                    % B_m(x) = B_j(x) * 1_{x>t*}
                  	Basis(:,splits)   = Basis(:,s) .* (X(:,k)>=xSplit(k)) .* (X(:,k)-xSplit(k));
                    % B_{m+1}(x) = B_j(x) (x-t*) * 1_{x<t*}
                    Basis(:,splits+1) = Basis(:,s) .* (X(:,k)<=xSplit(k)) .* (X(:,k)-xSplit(k));
                    
                    % Compute the squared Error
                    [tmpparam, tmpyhat, tmplof] = stableOLS( Basis(:,1:splits+1), y );
                    
                    % Compare the loss-of-fit
                    [lof, kk, ss, tt, DD] = lof1_lof2( tmplof,k,s,t,dist, lof,kk,ss,tt,DD);% Running check to find the best and 2nd best fit over all possible split points

                    % Increment to get next location of evaluation.  
                    %
                    if nextDist > 2*minDist, 
                       nextDist = nextDist + 2*minDist; 
                       nextDist = nextDist - (0.25 < rand);      % Substract 1 at random so that we do not visit exactly same locations in each loop.     
                    else
                       nextDist = nextDist + minDist;
                    end 
                  end                           %if
                  
                  % Increment to get distance between next point and edge of current domain
                  %
                  dist = dist+1;
                  
              end                               %if
        end                                     %for t=1:nrow
      end                                       %if
    end                                         %for s=1:splits-1
  end                                           %for k=1:ncolx

  % If we find no split point, there's likely a problem.
  if k(1)<1
    warning('No split. Something probably went wrong!');
    break;
  end 
  
  %%%%%%%%%%%%
  % Overview survey of split sites completed
  % Go back and look carefully in the neighbourhood of the 2 best splits
  %
  
  k1 = kk; s1 = ss; t1 = tt; d1 = DD;
  
  for i = 1:length(lof) 
      
      k = kk(i);
      s = ss(i);
      
      xin_s   = x_in(s,:);
      tstar_s = tstar(s,:);
      tmplof  = inf;
      
      dist = 0;

      distLoEdge = max([ 1, (DD(i) - 2*minDist + 1) ]);
      distUpEdge = 0;
      
      % Loop : Find upper edge of domain
      %
      for t = 1:nrow
        if ( (xin_s .* X(sortedIndex(t,k),:) ) >= (xin_s .* tstar_s) )
            distUpEdge = distUpEdge + 1;
        end
      end
      
      distUpEdge = min([distUpEdge-1, (DD(i) + 2*minDist - 1)]);
      
      % Loop : Compute lof around found best lof.
      %
      for t = 1:nrow
              
              xSplit = X( sortedIndex(t,k) , : );                                               % Look at observations in direction of increasing values
              
              if ( (xin_s .* xSplit) >= (xin_s .* tstar_s) )                                    % if ( all elements in xSplit candidate are in domain bounded by t_star)
                  if ((distLoEdge <= dist)&&(dist <= distUpEdge-minDist))|| (dist == distUpEdge)

                    % B_m(x) = B_j(x) * 1_{x>t*}
                  	Basis(:,splits)   = Basis(:,s) .* (X(:,k)>=xSplit(k)) .* (X(:,k)-xSplit(k));
                    % B_{m+1}(x) = B_j(x) (x-t*) * 1_{x<t*}
                    Basis(:,splits+1) = Basis(:,s) .* (X(:,k)<=xSplit(k)) .* (X(:,k)-xSplit(k));
                    
                    % Compute the squared Error
                    [tmpparam, tmpyhat, tmplof] = stableOLS( Basis(:,1:splits+1), y );
                    
                    [lof, k1, s1, t1, d1] = lof1_lof2( tmplof,k,s,t,dist, lof,k1,s1,t1,d1); % Running check to find the best and 2nd best fit over all possible split points
                  end
                  dist = dist + 1;
              end                               %if
      end                                       %for t=1:nrow    
  end                                           %for i=length(lof)

  %%%%%%%%%%%%
  % Best cutoff Split is found.  Assign value.
  %
  kk = k1(1);
  ss = s1(1);
  tt = sortedIndex( t1(1), k1(1) ); 
  
  % B_m(x) = B_j(x) (x-t*) * 1_{x>t*}
  Basis(:,splits) = Basis(:,ss).*(X(:,kk)>=X(tt,kk)).*(X(:,kk)-X(tt,kk));
  % B_{m+1}(x) = B_j(x) (x-t*) * 1_{x<t*}
  Basis(:,splits+1) = Basis(:,ss).*(X(:,kk)<=X(tt,kk)).*(X(:,kk)-X(tt,kk));
  % {-1,0,1} matrix that determines sign and variables that are included in which split.
  x_in(splits:splits+1,:)=[x_in(ss,:);x_in(ss,:)];    
  x_in(splits,kk) = 1;
  x_in(splits+1,kk) = -1;
  % Save the split location
  tstar(splits:splits+1,:)  = [tstar(ss,:); tstar(ss,:)]; 
  tstar(splits:splits+1,kk) = [X(tt,kk); X(tt,kk)]; 
  % Iterate by 2 (as we've created two siblings)
  splits = splits+2;  

end

%%%%%%%%%%%%
% End of split loop
%

% Compute the final depth variable (can't be greater than dim(x)).
depth = rank(eye(size(x_in,1))*x_in);
% Compute the tmp least square parameters
param = pinv(Basis'*Basis)*Basis'*y;
% Compute the final least square fit
yhat = Basis*param;

% Script, place all relevant values in "model"
put_all_in_model;

end%END of function foward_split
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [lof, kk, ss, tt, DD] = lof1_lof2( tmplof,k,s,t,dist, lof,kk,ss,tt,DD)

if tmplof< lof(1)                             % Running check to find the best and 2nd best fit over all possible split points
	% Replace values
    lof(2) = lof(1);    
	lof(1) = tmplof;
	kk(2) = kk(1);    kk(1) = k ;
	ss(2) = ss(1);    ss(1) = s ;
	tt(2) = tt(1);    tt(1) = t ;
    DD(2) = DD(1);    DD(1) = dist;
elseif tmplof< lof(2)                         % Running check to find the 2nd best fit over all possible split points
	% Replace values
    lof(2) = tmplof;
    kk(2) = k ;
    ss(2) = s ;
    tt(2) = t ;
    DD(2) = dist;
end

end%END of function lof1_lof2( tmplof, lof1,lof2,k1,k2,s1,s2,t1,t2)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

