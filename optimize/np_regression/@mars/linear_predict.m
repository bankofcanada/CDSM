%% linear_predict.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

% Function Mars_predict, taking inputs from MARS function
function [y_hat, basis] = linear_predict(model, X)
% Inputs are : 
% model : mars class model
% X : regressors classified by column (X(:,1) is regressor 1

param = model.param;
x_in = model.in_basis;
tstar = model.splitsites;
% param : parameters of subdomains, computed from MARS 
% x_in : matrix{nb_subdomains, nb_regressors} as x_in(i,j) is equal to 1 if regressor 'j'-t_star 
% in positive domain 'i', -1 if X(i,:) in negative domain 'j', 0 if regressor not in domain
% tstar : matrix{nb_subdomains, nb_regressors} of cutoff value of regressor
% 'i' in sub-domains 'j'

% Get dimensions of X
[nrowx ncolx] = size(X);
% Get number of subdomains
sub_domains = length(x_in);

% Initialization
y_hat = zeros(nrowx, 1);
basis = zeros(nrowx, sub_domains);
% First basis is constant basis = 1
basis(:,1) = ones(nrowx, 1);

% Start the loop over all domains    
for current_dom = 2:sub_domains
  % loop over number of variables    
  for k = 1:ncolx
     % Check direction of subdomain versus tstar
     if x_in(current_dom, k)==-1
        % 1_{x<=t*}
        is_smaller = ( X(:,k)<=tstar(current_dom,k) );
        % (x-t*)
        X_diff = (X(:,k)-tstar(current_dom,k));
        % check for null vector basis
        if isequal(basis(:,current_dom), zeros(nrowx,1))
            basis(:,current_dom) = ones(nrowx,1);
        end
        % B_{m+1}(x) = B_j(x) (x-t*) * 1_{x<t*}
        basis(:,current_dom) = basis(:,current_dom).*is_smaller.*X_diff;
     elseif x_in(current_dom,k)==1
        % 1_{x>=t*}
        is_larger = ( X(:,k)>=tstar(current_dom,k) );
        % (x-t*)
        X_diff = (X(:,k)-tstar(current_dom,k));
        % check for null vector basis
        if isequal(basis(:,current_dom), zeros(nrowx,1))
            basis(:,current_dom) = ones(nrowx,1);
        end
        % B_{m+1}(x) = B_j(x) (x-t*) * 1_{x<t*}
        basis(:,current_dom) = basis(:,current_dom).*is_larger.*X_diff;
     end
    end
end

% Compute the final least square prediction
y_hat = basis*param;