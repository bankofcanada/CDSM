%% cubic_predict.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

function [yhat, Basis] = cubic_predict(model, X)

% Function Mars_predict, taking inputs from MARS function
%
% Inputs are : 
% model : mars class model
% X : regressors classified by column X(:,1) is regressor 1

param  = model.param;
x_in   = model.in_basis;
tstar  = model.splitsites;
tcubic = get(model, 'tcubic');

% ALL contained in class MARS: 
%
% param : parameters of subdomains, computed from MARS 
% x_in : matrix{nb_subdomains, nb_regressors} as x_in(i,j) is equal to 1 if regressor 'j'-t_star 
% in positive domain 'i', -1 if X(i,:) in negative domain 'j', 0 if regressor not in domain
% tstar : matrix{nb_subdomains, nb_regressors} of cutoff value of regressor
% 'i' in sub-domains 'j'

% Get dimensions of X
[nrowx ncolx] = size(X);
% Get number of subdomains
sub_domains = size(x_in, 1);

% Initialization
y_hat = zeros(nrowx, 1);
Basis = ones(nrowx, sub_domains);

%%%%%%
% Create the appropriate Basis of approximation function
%

% Loop over all different variable    
for k = 1:ncolx

  % loop over number of non-constant basis function 
  for current_dom = 2:sub_domains
    t = tstar(current_dom, k);
    t_minus = tcubic(current_dom, k, 1);
    t_plus = tcubic(current_dom, k, 2);
    
    % Check if direction of subdomain is negative
    if x_in(current_dom, k)==-1
        % Compute p_minus and r_minus
        p_minus = (3*t-2*t_minus-t_plus)/(t_minus-t_plus)^2;
        r_minus = (t_minus+t_plus-2*t)/(t_minus-t_plus)^3;
          
        % Loop and test the 3 different regions of x
        for i=1:nrowx 
            if ( X(i,k)<=t_minus )
                Basis(i,current_dom) = Basis(i,current_dom)*(X(i,k)-t);
            elseif ( X(i,k)<t_plus )
                mid_basis = p_minus*(X(i,k)-t_plus)^2 + r_minus*(X(i,k)-t_plus)^3;
                Basis(i,current_dom) = Basis(i,current_dom)*(-1)*mid_basis;
            elseif i<=nrowx            
                Basis(i,current_dom)=0;
            end
        end
        
    % Else : Check if direction of domain is positive
    elseif x_in(current_dom,k)==1
         % Compute p_plus and r_plus
         p_plus = (2*t_plus+t_minus-3*t)/(t_plus-t_minus)^2;
         r_plus = (2*t-t_minus-t_plus)/(t_plus-t_minus)^3;
          % Loop and test over the 3 different regions of x
         for i=1:nrowx
             if ( X(i,k)<=t_minus )
                 Basis(i,current_dom)=0;
             elseif ( X(i,k)<t_plus )
                mid_basis = p_plus*(X(i,k)-t_minus)^2 + r_plus*(X(i,k)-t_minus)^3;
                Basis(i,current_dom)=Basis(i,current_dom)*mid_basis;
             elseif  i<=nrowx            
                Basis(i,current_dom)=Basis(i,current_dom)*(X(i,k)-t);
             end
         end
    end
     
    
  end
end

%%%%%%
% 'Basis' regressors reconstructed.  
% Compute the final prediction vector
%

yhat = Basis*param;

%END of function cubic_predict
