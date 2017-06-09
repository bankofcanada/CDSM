%% simulateBig.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This method (on the _nelsonSiegel_ class) produces the final data structures of simulation results. It breaks down the number of simulations into multiple smaller blocks, runs the specific _simulate.m_ script (which simulates the macro and yield curve variables based on the VAR model) on those blocks, and combines their results. 

%% Method Syntax
function data = simulateBig(varargin)
%%
% _ns_ : method is applied to _nelsonSiegel_ class
%
% Optional inputs for: starting lag setting, shocked variable(s), user-defined block size
%
% _data_ : structure containing all simulation results (blocks combined)


%% 1. Set size for each block of simulations, default is 200
sm = varargin{1};
numSims = get(sm, 'numSims');
if nargin > 1 && strcmpi(varargin{end-1},'Blocksize')
  Blocksize = varargin{end};
  varargin  = varargin(1:end-2);
else 
  Blocksize = 200;
end


%% 2. Simulate the variables in blocks (via _simulate.m_) and combine results
%
% See: _<../nelsonSiegel/simulate.html simulate>_, _<set.html set>_

%one-block simulation
if numSims <= Blocksize  
  data = simulate(varargin{:});

%multiple-block simulation
elseif numSims > Blocksize
  varargin{1} = set(sm,'numSims',Blocksize);    
  datablock = simulate(varargin{:});    %simulate the first block
  
  try
    %datablock = rmfield(datablock, 'eInf');
  end
  
  try
    data.simTenor = datablock.simTenor;
    datablock = rmfield(datablock, 'simTenor');     %remove 'simTenor' from block simulation results
  end
  
  %Initialize fields with a three-dimensional array to store the
  %two-dimensional matrix result (for each simulation) across all simulations
  dataNames = fieldnames(datablock);
  for ff = 1:length(dataNames)
    fieldSize = size( getfield(datablock,dataNames{ff}) );
    data.(dataNames{ff}) = zeros( fieldSize(1),fieldSize(2),numSims );
  end
  
  %Assign results from first block simulation to array
  for ff = 1:length(dataNames)
    data.(dataNames{ff})(:,:,1:Blocksize)...
        = getfield( datablock, dataNames{ff} );
  end
  
  %Loop to simulate across rest of the blocks
  bTime = clock;
  bb = 2;
  while bb <= floor(numSims/Blocksize)
    datablock = simulate(varargin{:});
    for ff = 1:length(dataNames)    
      data.(dataNames{ff})(:,:,(1+(bb-1)*Blocksize):bb*Blocksize)...
          = getfield( datablock, dataNames{ff} );
    end
    fprintf( '\n Completed: %g   Remaining: %.2f minutes \n', ...
             bb*Blocksize,(-1+numSims/bb/Blocksize)*(etime(clock,bTime)/60) );  %display elapsed time after each block
    bb=bb+1;
  end

  %If the final block is not full size, simulate on the remainder and assign results normally
  if (bb-1)*Blocksize ~= numSims    
    varargin{1} = set(sm,'numSims',numSims-(bb-1)*Blocksize);
    datablock = simulate(varargin{:});
    for ff = 1:length(dataNames)
      data.(dataNames{ff})(:,:,(1+(bb-1)*Blocksize):end)...
          = getfield( datablock, dataNames{ff} );
    end
  end
end