%% permutecols.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

function model = permutecols(model, perm1, perm2)

% function that permutes the internal position of the variables inside model class mars.
% does not affect the ouptut or behavior of model.

[row1 col1] = size(perm1);
[row2 col2] = size(perm2);

% Check input
if (row1*row2~=1)|(col1~=col2)
    error('perm1, perm2 should be row vectors');
end

splitsites = model.splitsites;
tplus = model.tupper;
tminus = model.tlower;
x_in = model.in_basis;

% create the permutation index
pindex = 1:size(x_in,2);

for i=1:length(perm1)
    pindex(perm1(i)) = perm2(i);
    pindex(perm2(i)) = perm1(i);
end
 
  
 model.splitsites = splitsites(:,pindex);
 model.tupper = tplus(:,pindex);
 model.tlower = tminus(:,pindex);
 model.in_basis = x_in(:,pindex);
        
        
        