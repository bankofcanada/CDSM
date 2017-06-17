%% getRegMatrix.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function creates a matrix defining each OLS regressor variable in terms of powers of each instrument allocation.


%% Function Syntax
function interMatrix = getRegMatrix(olsmodel, colx, varargin)
%%
%
% _olsmodel_ : function is applied to _OLS_ class
%
% _colx_ : number of instruments
%
% _varargin_ : other arguments (blank here)
%
% _interMatrix_ : matrix of each instrument's power in each regressor term


%% 1. Set up variables
olsmodel = set(olsmodel, varargin{:});  %no effect here

pow   = olsmodel.pow;           % powers of individual-instrument regressors (1 and 2 here)
inter = olsmodel.interact;      % powers of instruments used in interaction regressors (1 here)

powTerms   = length(pow);
interTerms = length(inter);


%% 2. Create matrix of instrument powers (0, 1, or 2) for each regressor
interMatrix = zeros( 1, colx );   % Matrix of all instrument powers corresponding to each regressor, to be populated.
pos = 1;

% Populate rows for single-instrument regressors
for p=1:powTerms            % Loop over all powers (1, 2)
    for j=1:colx
        interMatrix(pos, j) = pow(p);           %set power for each variable      
        pos = 1+pos;
    end
end

% Populate rows for interaction regressors and delete multiples
for i=1:interTerms          % Loop over powers of first interaction variable (just 1)
    for j=1:interTerms      % Loop over powers of second interaction variable (just 1)
        for k=1:colx
             for m=1:colx
                 if k~=m
                    interMatrix(pos, k) = inter(i);    %set power for 1st interaction variable
                    interMatrix(pos, m) = inter(j);    %set power for 2nd interaction variable
                    pos = 1+pos;
                 end
            end
        end
    end
end


L1 = 1;
while L1 <= size(interMatrix, 1)    %Loop over all lines and delete those identical to others
    Line1 = interMatrix(L1,:);
    
    L2 = L1+1;
    while L2 <= size(interMatrix, 1)            
        Line2 = interMatrix(L2,:);
        
        if isequal(Line1, Line2)                
            interMatrix = [interMatrix( 1:(L2-1), :) ;...
                           interMatrix( (L2+1):end, :)];
        else
            L2 = L2+1;
        end
    end
    L1 = L1+1;
end

end