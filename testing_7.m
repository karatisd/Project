%% Group 7
% Dimitrios Ioannidis (10415)
% Dimitrios Karatis (10775)

%% Zitima 7
clear; close all; clc;

% Load data
filename = 'TMS.xlsx';
data = readtable(filename);
TMS = data.TMS; % TMS status (1 = with TMS, 0 = without TMS)
EDduration = data.EDduration; % Duration of ED

% Select independent variables, excluding 'Spike'
independent_vars = {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode'}; % Removed 'Spike'
data_full = data(TMS == 1, :); % Filter rows where TMS == 1
data_full = rmmissing(data_full); % Remove rows with missing EDduration

% Convert categorical variables to numeric
for var = independent_vars
    if iscell(data_full.(var{:})) || iscategorical(data_full.(var{:}))
        data_full.(var{:}) = double(categorical(data_full.(var{:})));
    end
end

% Extract independent and dependent variables
X_full = data_full{:, independent_vars};
y = data_full.EDduration;

% Split data into training and test sets
cv = cvpartition(size(X_full, 1), 'HoldOut', 0.3);
train_idx = training(cv);
test_idx = test(cv);

X_train = X_full(train_idx, :);
y_train = y(train_idx);
X_test = X_full(test_idx, :);
y_test = y(test_idx);

% --- Full Model ---
mdl_full = fitlm(X_train, y_train, 'VarNames', ['EDduration', independent_vars]);
full_predictions = predict(mdl_full, X_test);
full_mse = mean((y_test - full_predictions).^2);

% --- Stepwise Regression ---
mdl_stepwise = stepwiselm(X_train, y_train, 'VarNames', ['EDduration', independent_vars]);

% Επιλεγμένες μεταβλητές από το Stepwise
selected_vars_stepwise = mdl_stepwise.PredictorNames;
disp('Stepwise selected variables:');
disp(selected_vars_stepwise);

stepwise_predictions = predict(mdl_stepwise, X_test);
stepwise_mse = mean((y_test - stepwise_predictions).^2);

% --- LASSO Regression ---
[B, FitInfo] = lasso(X_train, y_train);
[~, lambda_min_idx] = min(FitInfo.MSE);
lasso_vars = find(B(:, lambda_min_idx) ~= 0);

if ~isempty(lasso_vars)
    X_train_lasso = X_train(:, lasso_vars);
    X_test_lasso = X_test(:, lasso_vars);
    mdl_lasso = fitlm(X_train_lasso, y_train, 'VarNames', ['EDduration', independent_vars(lasso_vars)]);
    lasso_predictions = predict(mdl_lasso, X_test_lasso);
    lasso_mse = mean((y_test - lasso_predictions).^2);
else
    mdl_lasso = [];
    lasso_mse = NaN;
end

% --- Results ---
fprintf('\nModel Comparisons on Test Set:\n');
fprintf('1. Full Model MSE: %.3f\n', full_mse);
fprintf('2. Stepwise Regression Model MSE: %.3f\n', stepwise_mse);
if ~isempty(mdl_lasso)
    fprintf('3. LASSO Regression Model MSE: %.3f\n', lasso_mse);
else
    fprintf('3. LASSO Regression Model: No predictors selected.\n');
end

% --- Repeat process for variable selection based on training set ---
% This step involves reselecting predictors from the training set and repeating the above analysis
% Include handling of "Spike" as necessary based on findings
