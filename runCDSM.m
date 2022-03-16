clear all;
addpath ./model/
addpath ./optimize/
addpath ./optimize/np_regression/
addpath ./optimize/misc_matlab/
addpath ./optimize/objective/
addpath ./stochastic/
addpath ./stochastic/matlab/
%% %step1: generate the IR&macro scenarios: CDSM loads the input data
% (historical IR and macro data)to generate the IR&macro scenarios with the
% approach of nelson-siegal method introduced in the paper of Diebold and
% Li (2006), the results are saved in dataFiles/ns_MMMYYResults.mat,
% dataFiles/FinR_ns_MMMYYResults.mat, dataFiles/Coupon_ns_MMMYYResults.mat,
% the user can specify the name of output in the file of
% stochastic/generateScenarios_new.m
generateScenarios_new
%% % %step2: generate the debt strategy scenarios, the user can specify the
% number of debt strategy scenarios in the file of model/makeStrategies.m.
% And the outputs are saved in
% dataFiles/policyPort_MMMYY_vname_blockXXX.mat. The user can change the
% name of the outputs
makeStrategies
%% %step3: debt cost&risk engine: the N debt strategy scenarios are divided
% into blocks in order to use the parallel computation in the server. The
% output block files need to be specified before calling the model/main.m
for i = 1: ceil(N/blockSize) % note that N is the nubmer of debt strategy scenarios defined in the file model/makeStrategies.m
     strategyFile = ['./dataFiles/policyPort_MMMYY_vname_block' num2str(i) '.mat'];
     resultsFile = ['./dataFiles/results_SS_MMMYY_block' num2str(i) '.mat'];
     main;
 end
%% step4: merge the block files to one file, the results are saved in
%dataFiles/results_SS_MMMYY_block_all
mergeResults;
%% step5: optimizing the risk frontier. The optimization engine loads the
%output from step4 to calculate the cost&risk functions using ordinary least
%square method and then optimize the risk frontier based on the issuance
%constraints and risk steps. The results are saved in
%results/optimizationResults/
clear all;
optim_main;
%% step6: run area portfolio of the generated frontier, the same as step3, 
%which generates the costs&risks for each debt strategies in the risk frontier
clear all;
strategyFile = './results/ns/optimizationResults/optResults_MMMYY_blockOLS_percent_cCV_IC.mat';
resultsFile = './results/ns/areaPortfolios/optAreaResults_MMMYY_percent_cCV_IC.mat';
main


