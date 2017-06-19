%% find_cubic_knots.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

% Finding knots for first derivative continuity in MARS interpolation.
% Takes sample extremes, x_in {-1,0,1} and tstar linear knots inputs.
% outputs updated model and tcubic knots correspondings to tensor [t_minus ; t_plus], odered as in tstar.
function [model tcubic] = find_cubic_knots(model, var_min, var_max)

tstar = model.splitsites;
x_in = model.in_basis;

% Initialise
[n_basis, colx] = size(tstar);
% Tensor of lower and upper bounds 
tcubic = zeros(n_basis, colx, 2);
t_minus = tstar;
t_plus = tstar;

% loop over non-constant basis to find basis of same variables
% then compare the knots to find closest mid-point
for base = 2:n_basis
    for var_in = 1:colx
        
        t = tstar(base, var_in);        % 't' is the knot location for linear interpolation
        t_plus_ref = var_max(var_in);
        t_minus_ref = var_min(var_in);        
        t_plus(base, var_in)  =(t+var_max(var_in))/2;     % Initialise with midpoint to extreme value
        t_minus(base, var_in) =(t+var_min(var_in))/2;
         
        % Check only for non-zero basis function
        if 0 ~= x_in(base,var_in)
            % Loop over each Basis function
           for base_compare = 2:n_basis
                % check for each basis containing exactly same variable(s)
                if  isequal(x_in(base,:), x_in(base_compare,:)) & (base~=base_compare)
                    t_compare = tstar(base_compare,var_in);

                    if (t_plus_ref > t_compare) & (t < t_compare)   % Look for other, upper cutoff points
                        t_plus_ref = t_compare;
                        t_plus(base,var_in) = (t+t_plus_ref)/2;
                    elseif (t_minus_ref < t_compare) & ( t > t_compare) % Look for other, lower cutoff points
                        t_minus_ref = t_compare;
                        t_minus(base,var_in) = (t+t_minus_ref)/2;
                    end     %elseif
                end         %if
            end
            
        end %if
    end
end

tcubic(:,:,1)=t_minus;
tcubic(:,:,2)=t_plus;

model = set(model, 'tcubic', tcubic);
% END of function