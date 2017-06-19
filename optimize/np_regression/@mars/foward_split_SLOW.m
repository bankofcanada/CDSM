%% forward_split_SLOW.m
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
alpha     = get(model, 'minknotdist');          % Smoothing parameter for min_knot_dist.  Is probability tolerance of having a "all same sign" error run
max_inter = model.max_interaction;              % maximum number of interacting (multiplied together) regressors.
if isempty(max_inter)
    max_inter = ncolx;
end

depth = 0;                                      % The depth of the basis function (cannot permit quadratic terms)
yhat  = 0*y;
tstar = zeros(max_basis, ncolx);    % Knots value for each Basis
x_in  = zeros(max_basis, ncolx);     % variables x_in are {-1,0,1}, indicating if variable x is negative, not included or positive in Basis
Basis = zeros(nrow, max_basis);


%%%%%%%%%%%%
% Prepare coming loop
%
Basis(:,1)= 1;             % First basis function covers entire domain.
splits    = 2;             % Begin the loop at second basis function.

%%%%%%%%%%%%
% Actual foward-splitting loop
% Start the loop to find all best Basis functions	    
%
while splits < max_basis
  lof = inf; 
  kk = 0; % split variable (x_1,...,x_v)
  ss = 0; % split location (where we are in the tree)
  tt = 0; % split point
  % loop over number of variables
  for k = 1:ncolx 
    % loop over number of splits previously created    
    for s = 1:splits-1
      % Don't create quadratic terms (can't go deeper than dim(x)) AND don't consider higher than max_interaction
      if ( x_in(s, k)==0 ) && ( sum(x_in(s,:)) < max_inter )
          for t=1:nrow
            % Do not search over null basis
            if Basis(t,s)~=0    %LOOK OUT
                                %We want to keep available for splits
                                %values at extremes, in order to allow for
                                %simple linear regressions.  A sorting
                                %procedure would be interresting here.  We
                                %do not implement it for now, as we have
                                %other things to do.  But it should be
                                %included in the process within few days.
                                %An other option is to search over all
                                %basis.  Much longer, much simpler.
                % B_m(x) = B_j(x) * 1_{x>t*}
                Basis(:,splits) = Basis(:,s).*(X(:,k)>=X(t,k)).*(X(:,k)-X(t,k));
            	% B_{m+1}(x) = B_j(x) (x-t*) * 1_{x<t*}
            	Basis(:,splits+1) = Basis(:,s).*(X(:,k)<=X(t,k)).*(-X(:,k)+X(t,k));
                
                % Test for minimal number of observations between 2 knots "t"
                good_dist = false;
                d1 = sum( (abs(Basis(:,splits)) < eps ));
                d2 = sum( (abs(Basis(:,splits+1)) < eps ));
                good_dist = min_knot_dist(d1,d2,alpha); %Likely-hood related value for min_dist.
                if good_dist
                    % Compute the squared Error
                    tmplof = OLSErr2( Basis(:,1:splits+1), y );
                    % Running check to find the best fit over all possible split points
                    if tmplof<lof;
                     lof=tmplof;
                        kk = k; 
                        ss = s; 
                        tt = t;    
                    end %if
                else %rien pantoute
                end %if
            end %if
        end
      end %if
    end
  end
  % If we find no split point, there's likely a problem.
  if kk<1
    error('No split. Something probably went wrong!');
    break;
  end 
  
  % B_m(x) = B_j(x) (x-t*) * 1_{x>t*}
  Basis(:,splits) = Basis(:,ss).*(X(:,kk)>=X(tt,kk)).*(X(:,kk)-X(tt,kk));
  % B_{m+1}(x) = B_j(x) (x-t*) * 1_{x<t*}
  Basis(:,splits+1) = Basis(:,ss).*(X(:,kk)<=X(tt,kk)).*(X(:,kk)-X(tt,kk));
  % {-1,0,1} matrix that determines sign and variables that are included in which split.
  x_in(splits:splits+1,:)=[x_in(ss,:);x_in(ss,:)];    
  x_in(splits,kk) = 1;
  x_in(splits+1,kk) = -1;
  % Save the split location
  tstar(splits:splits+1,:)=[tstar(ss,:); tstar(ss,:)]; 
  tstar(splits:splits+1,kk)=[X(tt,kk); X(tt,kk)]; 
  % Iterate by 2 (as we've created two siblings)
  splits = splits+2;  

end
% Compute the final depth variable (can't be greater than dim(x)).
depth = rank(eye(size(x_in,1))*x_in);
% Compute the tmp least square parameters
param = pinv(Basis'*Basis)*Basis'*y;
% Compute the final least square fit
yhat = Basis*param;

% Script, place all relevant values in "model"
put_all_in_model;

end  %END of function


