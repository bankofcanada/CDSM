clear all;
addpath ./model/
addpath ./optimize/
addpath ./optimize/np_regression/
addpath ./optimize/misc_matlab/
addpath ./optimize/objective/
addpath ./stochastic/
addpath ./stochastic/matlab/
%step0: loading the input data 
loadDataUpdate
% %step1: generate the macro scenarios
generateScenarios_new
% % %step2: generate the debt strategy scenarios
makeStrategies
% %step3: debt cost&risk engine
for i = 1: ceil(N/blockSize) % note that N is the nubmer of debt strategy scenarios defined in the file model/makeStrategies.m
     strategyFile = ['./dataFiles/policyPort_MMMYY_vname_block' num2str(i) '.mat'];
     resultsFile = ['./dataFiles/results_SS_MMMYY_block' num2str(i) '.mat'];
     main;
 end
%step4: merge the block files to one file
mergeResults;
%step5: optimizing the risk frontier
clear all;
optim_main;
%step6: run area portfolio of the generated frontier, the same as step3
clear all;
strategyFile = './results/ns/optimizationResults/optResults_MMMYY_blockOLS_percent_cCV_IC.mat';
resultsFile = './results/ns/areaPortfolios/optAreaResults_MMMYY_percent_cCV_IC.mat';
main


