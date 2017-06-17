%% nonparametric_model.m
% |Copyright (C) 2017, Bank of Canada|
%
% |This source code is licensed under the 3-Clause BSD License found in the
% LICENSE file in the root directory of this source tree.|
%
% This function constructs the parent _nonparametric_model_ class that the core _OLS_ class inherits from.

%% Function Syntax
function model = nonparametric_model(varargin)


%% 1. Construct _nonparametric_model_ class
model.errors = [];
model.cov = [];
model.yhat = [];
model.optional = {};

model = class(model,'nonparametric_model');