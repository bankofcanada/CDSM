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
    [ '../optimize/np_regression/:' ...
      '../optimize/np_regression/tools/:' ...
      '../optimize/np_regression/compare/:' ...
      '../optimize/misc_matlab/:' ...
      '../optimize/objective/'];
path(includePathFolders,path);
clear includePathFolders;