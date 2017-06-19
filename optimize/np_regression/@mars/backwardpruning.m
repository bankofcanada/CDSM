%% backwardpumping.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

function [model, vsplit_star] = backwardpruning(model, Basis, y)

% function [model, vsplit_star] = backwardpruning(model, Basis, y)
%
% Algorithm 3 from Friedman 1991
%
% Backward pruning of the max_domain regression tree obtained
% in the previous 'forwardsplit(...)' function.
% uses most inputs from 'fowardsplit(...)'
%
%%%%%%
%
% Basis {N by max_domain}: usually received from fowardsplit.  N rows of values associated...
% with splitted regressor 'X', max_domain column corresponding to each basis
% y {N by 1}: dependent variable
%
% Note that model's nsplit value, if defined, is an upper bound on number of splits.
%%%%%%
% Tiago Rubin & David Bolder, Bank of Canada, 2006
%%%%%%
% Called by mars().train(...)

%%%%%%
% Init variables
%

% x_in {nb_regressor by max_domain} : If x_in(row, col)=(+/-)1, regressor 'row' is included in computation of Basis(:,col)
% tstar {nb_regressor by max_domain} : tstar(row,col) = cutoff value for regressor 'row' in Basis(:,col)
% Get variables from model
tstar = model.splitsites;
x_in = model.in_basis;



%%%%%%
% minimum number of splits investigated.
%
min_N_splits = 1;
hasNsplits   = false;       

if ~isempty(model.nsplits)
    min_N_splits = model.nsplits;
    hasNsplits = true;
end

% Inintialise max_domain to number of basis
[N max_domain] = size(Basis);
% final number of splits
best_nsplit = max_domain;
% best vector of splits or leaves
vsplit_star = [1:max_domain];
% init of tested vector of splits or leaves from the tree
vsplit = [1:max_domain];
% loss of fit (init at value of the full, unprunned tree)
min_lof = inf;

%%%%%%%%%%%%
% Actual pruning loop
% loop to find a sequence of {max_domain - 1} models
leaves = max_domain;
while (leaves > min_N_splits)
    
    %%%%%%
    % Shuffle index for Cross-Validation of error2
    shufIndex   = [1:N]';
    [shufIndex] = shuffle_rows(shufIndex);      % Get shuffle index
    %%%%%%
    % number of checks for cross-Val.  The smaller the faster.
    crossValNumber = min( [14, N] );

    lof = inf;
    tmplof = 0;
    % init prune_choice (this loop's best pruning), and tmpsplit (will take all tested pruning values)
    prune_choice = vsplit;
    tmpsplit = vsplit(1:end-1);
    % for all leaves except the last, loop to find worst leaf to remove
    for prune = 2:leaves
        % Prune the vector used for Basis selection from previous optimal pruning
        tmpsplit = [vsplit(1:prune-1),vsplit(prune+1:leaves)];
        
        if leaves < (2/3)*max_domain
            % From the pruned Basis, find LOF computed by CV 
            err2 = cvErr2( Basis(:,tmpsplit), y, crossValNumber, shufIndex);
            % Compute GCV for parsimonious fitting
            tmplof = err2 / N / (  1 - ((length(tmpsplit)-1) / N)^2  );
        else 
           % first third removed automatically by err^2 comparison.
            [param, yhat] = stableOLS( Basis(:,tmpsplit),y );
            tmplof = (y-yhat)'*(y-yhat)*1e6+1e6; % Big number.  Make sure never smaller than remaining 2/3
        end
        
        % check to find the best pruned model at 'leaves' value ('leaves' being the tested number of sub_domain )
        if tmplof <= lof+10*eps
            lof = tmplof;
            prune_choice = tmpsplit;
        end
    end

    % All leaves were tested.
    % If we found no leaf to prune, there's likely a problem.
    if isequal(prune_choice,vsplit)
        error('No pruning. Something probably went wrong!');
        break;
    else
        %we found an optimal split for {leaves} number of leaves
        vsplit = prune_choice;
    end
    
    % Check for best overall LOF and pruning (NB.:'eps' is smallest "float" distance)
    % OR check if we reached the desired preset number of splits 'min_N_splits'
    if (lof <= min_lof+10*eps) || (lof/min_lof <= 1.01) || (hasNsplits && (leaves-1 == min_N_splits))  % (smaller than minLOF) OR (less than 1% higher than minLOF) OR (correspond to max split number)
        % a better regression tree was found, update min_lof
        min_lof = lof;
        % overall best number of split is decremented
        best_nsplit = best_nsplit - 1;
        % update best vector of splits/leafs
        vsplit_star = vsplit;        
    end

    % Decrement 'leaves' (as one split was removed) to test for smaller trees
    leaves = leaves-1;
end

% Get Basis for best overall LOF and pruning
Basis = Basis(:, vsplit_star);
% Get x_in for best overall LOF and pruning
x_in = x_in(vsplit_star,:);
% Get tstar for best overall LOF and pruning
tstar = tstar(vsplit_star,:);
% Compute the final depth variable (can't be greater than dim(x)).
depth = rank(eye(size(x_in,1))*x_in);
% Compute the final least square parameters
param = pinv(Basis'*Basis)*Basis'*y;
% Get final number of splits
nsplits = length(param);

% Script: all relevant variables in mars 'model'
put_all_in_model;

end%END of function [model, vsplit_star] = backwardpruning(model, Basis, y)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function err2 = cvErr2(x, y, numCV, shufIndex)
% function err2 = cvErr2(x, y, numCV, shufIndex) 
% Computes Cross-validation (out-of-sample) error squared.
%%%%%%%


[rowx colx] = size(x);

numIter     = numCV;               % number of model testing
trainRatio  = 1-1/numCV;

err2 = 0;                          % Out of sample estimated error squared

%%%%%%
% Init variables for coming loop
%
decimalLastTest = 0.0;
loopedIndex      = 0;

% size of test sample
testSize    = rowx*(1-trainRatio);             % size of subsample set used for training    


%%%%%%
% The actual Cross-Validation Loop.
% Loop over all subsamples to get model approximation, in and out of
% sample.  Do that while numIter is reached.
%
for i=1:numIter
    
    %%%%%%
    % Select the sizes for training and testing from previously shuffled sample.
    %
    floatTest = testSize + decimalLastTest;
    intTrain  = round( rowx - floatTest );
    
    % Circulate the index of sample to select new ramdom sample each time.
    %
    minSample = min( [intTrain, rowx-intTrain] );
    shufIndex = circshift( shufIndex, -minSample);    
    
    % Select the samples
    %
    sub_sample = shufIndex( 1:intTrain );          % First intTrain indexes.  Contains 90% of the sample's indexes if nb_cv_sample = 10.
    sub_test   = shufIndex( intTrain+1:end );      % (N/nb_cv_samples) of the whole sample contained between last and current test index.
       
    %%%%%%
    % Get the temporary parameters
    %

    R = x(sub_sample,:)'*x(sub_sample,:);
    c = x(sub_sample,:)'*y(sub_sample,:);

    % Try Chol(R) first, if R is non-singular, cholesky decomposition is much faster
    try 
        R = R+eye(length(R))*1e-10;     % To increase stability
        Chol_R = chol(R);
        b = Chol_R\(Chol_R'\c);
    catch
        b = pinv(R)*c;                  % In case of failure of Cholesky decomp., get pseudo-inverse (numerically very stable)
    end


    %%%%%%
    % Get error estimation out of sample
    %
    tmp_err2=(y(sub_test,:)-x(sub_test,:)*b)'*(y(sub_test,:)-x(sub_test,:)*b)/rowx;
    
    % Assign output value
    %
    err2 = err2+tmp_err2;
    
    %%%%%%
    % Prepare next loop.  Store info to be used in next iteration.
    %
    decimalLastTest = decimalLastTest + testSize - (rowx - intTrain);

    % Keep track of visited sample points.
    %
    loopedIndex = loopedIndex + minSample;
    
end


end%END of function cvErr2(basis, y, numCV)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
