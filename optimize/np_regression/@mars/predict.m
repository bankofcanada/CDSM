%% predict.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

function [ yhat Basis ]= predict(marsmodel, x, varargin)

% function predict(marsmodel, x, varargin)
%
% Predicts the estimated value of y from input regressors x.  Default
% estimation for MARS is cubic, but varargin can specify linear prediction.
% 
%%%%%%
%
% Inputs are
%
% marsmodel : The already estimated model of class mars.
%
% x         : Locations of desired predictions
%
% varargin  : either 'linear', or irrelevant. 'linear' triggers linear
%           prediction, anything else leads to cubic.
%
%%%%%%
%
% Outputs are
% 
% yhat      : Estimated values of y given x
%
% Basis     : Constructed basis predictors from x.  Can be used for overview 
%           of the  different divisions in the data.
%
%%%%%%
%Tiago Rubin & David Bolder, Bank of Canada, June 2006
%%%%%%

yhat  = [];
Basis = [];

if isempty(varargin)
    [ yhat Basis ] = cubic_predict(marsmodel(1), x);
elseif isequal( varargin{1}, 'linear')
    [ yhat Basis ] = linear_predict(marsmodel(1), x);
else
    [ yhat Basis ] = cubic_predict(marsmodel(1), x);
end

% In case their is more than one mars model in the array, predict the total
% as the simple average of each estimation.
if length(marsmodel) > 1
    for i = 2:length(marsmodel)
        if isempty(varargin)
            yhat = yhat + cubic_predict(marsmodel(1), x);
        elseif isequal( varargin{1}, 'linear')
            yhat = yhat + linear_predict(marsmodel(1), x);
        else
            yhat = yhat + cubic_predict(marsmodel(1), x);
        end
    end
    yhat = yhat/length(marsmodel);
end

end%END of function predict(...)