%% train.m
% |Copyright (C) 2017, Bank of Canada & Department of Finance Canada|
%
% |This source code is licensed under the GNU LGPL v2.1 license found in the
% LICENSE file in the root directory of this source tree.|
%
%% Not used in this version of PRODUCE EFFICIENT FRONTIERS.

% Wrapped up mars approximation.

function [model yhat s_anova basisKept] = train(model, x, y, varargin)

% train, fucntion of mars class
% varargin should be of format : 'optionName', value, optionName, value

%%%%%%
% Handle options from varargin
%
graphresults = false;    % Option to graph or not the results
s_anova  = false;        % Option : get anova decomposition
savefile = false;
slow     = false;         % Option : train faster mars(), with little loss of accuracy.

max_domain = [];         % Option : explicitly defined max_domain


optionsin = varargin;
% Loop over all input argument and fill field if appropriate
while length(optionsin) >= 2,
    optionName = optionsin{1};      % First of two is option name
    val = optionsin{2};     % Second of two is option value
    optionsin = optionsin(3:end);     % Remove first two from option
    switch optionName
        case 'max_domain'
            max_domain = val;
            model.max_domain = max_domain;
            varargin = optionsin;
        case 'graph'
            graphresults = val;
            varargin = optionsin;
        case 'anova'
            s_anova = val;
            varargin = optionsin;
        case 'save'
            savefile = val;
            varargin = optionsin;
        case 'slow'
            slow = val;
            varargin = optionsin;
    end
end

%%%%%%
% With remaining parameters, set the model.
%

model = set(model, varargin{:});

if isempty(max_domain) 
    max_domain = model.max_domain;
end

%% profile on;
%% tic

%%%%%%
% Train the model
%
if slow
    [model, basis] = foward_split_SLOW(model, x, y, max_domain);     % Split and regress the data set optimally until max_domain is reach
else
    [model, basis] = foward_split(model, x, y, max_domain);
end

[model, basisKept] = backwardpruning(model, basis, y);          % Delete splits that are irrelevant to the model


% Once linear approx. found, get knots for cubic spline 
%
[model, tcubic] = find_cubic_knots(model, min(x), max(x));
[yhat, basis] = cubic_predict(model, x);

% Cubic approx. found, get final optimal parameters
model.param = pinv(basis'*basis)*basis'*y;                  % model.param : final estimation of parameters value.
yhat = basis*model.param;                                   % y_hat : final estimation of y

%% toc
%% profile report;

%%%%%%
% Training completed.  Handle graphs and g-o-fit info
%
% If desired, graph both y and yhat
if graphresults
    subplot(2,1,1), gridplot3d(x(:,1),x(:,2),y);
    subplot(2,1,2), gridplot3d(x(:,1),x(:,2),yhat);
end

% Anova decomposition 
if s_anova
    s_anova = {};
    [s_anova.variable, s_anova.lof, s_anova.pval, s_anova.yhatpct] ...
            = anova(model,x,y);
end

%%%%%%
% if specified, save results
%
if savefile
    save(savefile, 'model', 's_anova');
end

%%END of function mars.train(...)