%% makeStrategies.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This script is run for the MAKE STRATEGIES step of the model. It creates
% a set of representative financing strategies which are evaluated in the
% DEBT CHARGE ENGINE step to produce a training set for curve-fitting general functions of
% cost and risk for all strategies. 
% 
% This representative set is thus meant to inform the cost and risk
% behavior of all strategies, with a focus on strategies that satisfy the minimum
% constraints - since those will form the relevant evaluation space for
% optimization. Thus, the specified minimum constraints are applied to some
% (1/6), but not all, of the strategies created here.
%
% Note that the instruments being considered in these strategies (9) is a
% subset of the total instruments in the model (13). 


%% Policy Inputs
% These variables are defined via internal policy decision and are set to --- here as a placeholder:
%
% * _ic_ (see Part 3) : minimum issuance constraints by instrument, in % terms (each term between 0 and 1, sum is less than 1)
%


%% 1. Set Up
N = 2000; % Total number of strategies created
inc=linspace(1,0.5,20); %vector of relevant single-instrument weights in extreme portfolios
A=[];
blockSize=250; % Number of strategies in each block, N/blockSize is number of blocks (an integer)
nInst = 9;  % Number of instruments: 3m, 6m, 1y, 2y, 3y, 5y 10y, 30y, RRB


%% 2. Create extreme strategies
% In these strategies, a fixed extreme allocation is placed in one instrument and the rest is randomly allocated. With 9 instruments and 20 extreme weights (0.5,0.53,...,0.97,1) to consider, there are 9x20 = 180 strategies generated this way. 
 for k=1:length(inc)    %loop over each relevant extreme weight (0.5,...,1)
   randtemp =abs(randn(9));
   randtemp = randtemp - diag(diag(randtemp));
   randtemp = (1-inc(k)) * (randtemp ./ (sum(randtemp')'*ones(1,nInst)));   % remaining instruments randomly allocated
   temp = randtemp + inc(k)*eye(nInst); % allocation in one instrument is high (0.5,...,1)
     
   A = [ A; temp(:,1:6) zeros(nInst,1) temp(:,7:8) zeros(nInst,3) temp(:,9) ];  %A is final matrix of extreme strategies
   
 end

 
%% 3. Create strategies that are consistent with minimum issuance constraints
% In these strategies, a fixed allocation amount is placed in each
% instrument to satisfy their minimum constraints and the rest is randomly
% allocated. 1/6 of all the strategies, i.e. 1/6 x 2000 = 333 strategies
% are generated this way.
%
% See: _<icWts.html icWts>_
ic = [ --- --- --- --- --- --- --- --- ---];   %minimum issuance constraints for each instrument
ic_wts = icWts(ic,round(N/6));  %ic_wts is final matrix of constraint-consistent strategies


%% 4. Create random strategies
% The remaining strategies are randomly allocated, with no constraints.
% Some of these will be replaced by corner strategies. There are thus a
% maximum 2000 - 180 - 333 = 1487 strategies generated this way.
randU=abs(randn(N-size(A,1)-size(ic_wts,1),nInst)); %fully random allocation
allPorts=randU./kron(sum(randU'),ones(nInst,1))';   %allPorts is matrix of random strategies


%% 5. Create corner strategies (with at least one instrument at 0)
% This takes one of the random strategies, and sets the allocation of one instrument to 0 and increases the
% allocation of the others proportionally. For each instrument, as well as for the pair of 30Y nominal and RRB, this is
% done for 1/100 of the strategies; i.e. 2000 x 1/100 x 10 = 200 in total.
% (Thus, there are 1487 - 180 = 1287 random strategies in the set).

if N>=1200  %only put these in if the set of strategies sufficiently large (it is here)
    p = ceil(0.01*N);   %done for 1/100 of all the strategies, for each instrument
    spot = length(allPorts) - (nInst+1)*p;
    for i=1:nInst   %loop across each instrument
        for j=1:p   %do is 2000 x 1/100 = 20 times for each instrument
            spot=spot+1;
            allPorts(spot,i) = 0;   %set that instrument's allocation to 0
        end
    end    
    allPorts(spot+1:spot+p,8:9) = 0;    %set the 30Y nominal and RRB allocations to 0 (20 times)
    allPorts = allPorts ./ (sum(allPorts')'*ones(1,nInst)); %allPorts is final matrix of random strategies, adjusted for corner strategies
end


%% 6. Combine different created strategies and randomize order
allPorts=[allPorts; ic_wts];    %combine random and issuance-constrained strategies
allPorts=[allPorts(:,1:6) zeros(length(allPorts),1) allPorts(:,7:8) zeros(length(allPorts),3) allPorts(:,9)];
allPorts=[A; allPorts]; %combine random and extreme strategies

% Randomize order so that each block (which is run separately) contains a similar sample of the
% representative strategies
x = linspace(1,N,N);

for i = 1:N
   c = x(i);
   c2 = ceil(N*rand(1));
   x(i) = x(c2);
   x(c2) = c;
end
seq=[];
seq = x;
allPorts = allPorts(x,:);  
  

%% 7. Save the strategies in blocks
%%
% Blocks will be evaluated separately in a parallel process, and results will be merged.
for i=1:N/blockSize
  ports=allPorts((i-1)*blockSize+1:i*blockSize,:);  
  eval(['save ../dataFiles/policyPort_MMMYY_vname_block',num2str(i),'.mat ports seq']);
end