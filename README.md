# Canadian Debt Strategy Model Public Version 1.0

The purpose of the Canadian Debt Strategy Model (CDSM) is to help debt managers determine their optimal financing strategy. It does so by robustly quantifying the cost-risk trade-off between issuing shorter-term or longer-term debt in steady-state.

The CDSM is coded in MATLAB and is run in three modules:
1. The first module ([stochastic](/stochastic/) produces a long-run range of economic and interest rate scenarios. 
2. The second module (model) creates a set of representative strategies, and evaluates them under those scenarios.
3. The third module (optimize) uses those results to curve-fit general functions of cost and risk for any financing strategy, and optimizes over them to produce an efficient frontier.  

The CDSM User Guide is available here. An interactive HTML guide to the line-by-line coding is also available in the documentation folder.

Links to David J. Bolder’s original papers on the CDSM can be found here.

The CDSM was developed by the Bank of Canada as part of its role as a fiscal agent for the Government of Canada. The published code is illustrative and is provided for example and information purposes only. This content does not reflect the views of the Bank of Canada or the Government of Canada.
