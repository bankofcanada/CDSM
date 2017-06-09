%% setApproximationPaths.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This subroutine sets the paths for the cost and risk curve-fitting
% method.


%% 1. Set paths for curve-fitting method
includePathFolders = ...
    [ '~/CDSM-public/optimize/np_regression/:' ...
      '~/CDSM-public/optimize/np_regression/tools/:' ...
      '~/CDSM-public/optimize/np_regression/compare/:' ...
      '~/CDSM-public/optimize/misc_matlab/:' ...
      '~/CDSM-public/optimize/objective/'];
path(includePathFolders,path);
clear includePathFolders;