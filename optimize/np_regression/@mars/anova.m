%% anova.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

function [v_implied, LOF_contribution, p_val, yhat_pct] = ...
    anova(model, x, y)
%
% function [v_implied, LOF_contribution, p_val, yhat_pct] = ...
%    anova(model, x, y)
%
% Takes inputs from MARS and outputs different ANOVA values
% Format similar to the one suggested by Friedman, 1991.
% Uses inputs from backwardpruning.
%%%%%%
% Tiago Rubin & David Bolder, Bank of Canada, 2006
%%%%%%

[yhat, Basis] = cubic_predict(model, x);
x_in = model.in_basis;
b = model.param;

% Initialise
colx = size(x_in,2);
[N n_basis] = size(Basis);

% Loss of fit for the complete model
LOF = get_penalized_GCV(Basis, y, n_basis);
% x_in is either 1, -1 or 0.
x_included = abs(x_in);

% Sort the column of x_included, and corresponding indicators
[x_included, sort_v] = sortrows(x_included, [1:size(x_in,2)]);
x_in = x_in(sort_v,:);
Basis = Basis(:,sort_v);

% Residual sum of squares (Full model)
rss = (y-yhat)'*(y-yhat);

% Index to find number of variables in all Basis
diff_var = 0;
% loop over non-constant basis to find number of basis of same variables
for base = 2:n_basis
    % Compare two different Basis involved variables
    if ~isequal( x_included(base-1,:), x_included(base,:))
        % Basis with different variables : increment diff_var (different variables)
        diff_var = diff_var+1;
    end
end
  
fn_var = zeros(diff_var, model.max_interaction);        % Matrix indicating Basis using regressor variables, or product
fn_var(1,1) = 2;                                    % First basis non-constant always the second
% vector of loss of fit contribution
LOF_contribution = zeros(diff_var, 1);
% Vector of F_statistic P-value (Prob of being insignificant)
p_val = ones(diff_var, 1);
v_implied = zeros(diff_var, colx+1);        % Matrix of variables implied in identified basis, last column is basis count using identified variable

% Matrix of percentage contribution to yhat by each variable(s)
yhat_pct = zeros(N,diff_var);

% Basis and Variable Indexes for fn_var matrix
b_index = 1;
var_index=1;
% loop over non-constant basis to find basis of same variables
for base = 3:n_basis
    % check for next one containing same variable(s)
    if isequal(x_included(base-1,:), x_included(base,:))
        % 'base' contains exactly same variable(s) as base+1
        fn_var(var_index,b_index) = base-1;        
    	fn_var(var_index,b_index+1) = base;
        % increment b_index
        b_index = b_index+1;   
    else
        % Variables different: only 'base' uses this variable
        % Reinit b_index, increment var_index
        var_index = var_index+1;
        b_index = 1;
        fn_var(var_index,b_index) = base;

    end
end
kept = {diff_var};
% Loop to get the GCV lost and P_value if one variable(s) is dropped
for X_i = 1:diff_var
    % Set the current variable to drop in computations
    current_drop = zeros(size(fn_var));
    current_drop(X_i,:) = fn_var(X_i,:);
    % Indexes of basis not containing the current variable
    kept{X_i} = nonzeros(fn_var - current_drop);
    % Number of remaining basis after removing variable X_i
    nremain = length(kept{X_i});
    % If kept_vector contains valid indexes, Compute lof and rss.
    if nnz(kept{X_i})>0
        % Compute LOF loss by dropping a variable
        tmp_lof = get_penalized_GCV(Basis(:,kept{X_i}),y,nremain);
        LOF_contribution(X_i) = tmp_lof - LOF;
        
        % From GCV, compute Restricted residuals sum of squares
        r_rss = N*tmp_lof*((1-(6*nremain-3)/N)^2);
        % Compute approximate F_stat and then p_val for dropped variable
        F_stat = (r_rss-rss)/(rss)*(N-n_basis)/(n_basis-nremain);  
%max license reached, tmp removal        p_val(X_i) = 1-fcdf(F_stat,(N-n_basis),(N-n_basis));
   
    else
        LOF_contribution(X_i) = 0;
        F_stat(X_i) = 0;
        p_val(X_i) = NaN;
    end
end

yhat_pct = yhatPercent(model, x, diff_var, Basis, kept);

% Loop to identify the variable(s) referred to in rows of p_val and LOF_contributions
for X_i = 1:diff_var
    for x = 1:colx
        % Get one basis for the current variable
        in_v = fn_var(X_i,1);
        % Identify the regressor x implied in basis
        v_implied(X_i,x) = x*x_included(in_v,x);
    end
    v_implied(X_i,end) = nnz(fn_var(X_i,:));
end

end%END of function anova
%
%%%%%%%%%%%%%%          %%%         %%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%          %%%         %%%

function yhatpct = yhatPercent(model, x, diff_var, Basis, kept)
% Computes the relative contribution of each variable in direction of yhat

yhatpct = zeros(size(Basis,1), diff_var);
absyhat = zeros(size(Basis,1), 1);  % All column of absyhat are identical.

b = model.param;
yhat = Basis*b;

for X_i = 1:diff_var
    if nnz(kept{X_i})>0
        % Compute absolute contribution of variable(s) to yhat and add.
        absyhat = absyhat + abs( Basis(:,kept{X_i})*b(kept{X_i}) );
    end
end


for X_i = 1:diff_var
    if nnz(kept{X_i})>0
        % Compute relative contribution of variable(s) to yhat and add.
        yhatpct(:,X_i) = Basis(:,kept{X_i})*b(kept{X_i})./absyhat;
    end
end

% make yhatpct positive if it has same sign as yhat-(const param), negative otherwise
samesign = true(size(yhatpct));
for i=1:diff_var
    samesign(:,i) = ( yhatpct(:,i).*(yhat-b(1))>=0 );
end
notsamesign = ~samesign;

yhatpct = abs(yhatpct.*samesign) - abs(yhatpct.*notsamesign);

end
%%%% END of fucntion yhatPercent
