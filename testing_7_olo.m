% Clear workspace and close all figures
clear; close all; clc;

% Load the dataset from TMS.xlsx
filename = 'TMS.xlsx';
data = readtable(filename);

% Extract relevant columns
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

% Fit multiple regression models
mdl1 = fitlm(X_train, y_train); % Model 1: Linear regression

mdl2 = stepwiselm(X_train, y_train); % Model 2: Stepwise regression

[B, FitInfo] = lasso(X_train, y_train, 'CV', 10); % Model 3: LASSO regression
lasso_idx = FitInfo.Index1SE;
B0 = FitInfo.Intercept(lasso_idx);
mdl3 = @(X) X * B(:, lasso_idx) + B0;

% Calculate MSE for each model on the test set
y_pred1 = predict(mdl1, X_test);
mse1 = mean((y_test - y_pred1).^2);

y_pred2 = predict(mdl2, X_test);
mse2 = mean((y_test - y_pred2).^2);

y_pred3 = mdl3(X_test);
mse3 = mean((y_test - y_pred3).^2);

% Display MSE for each model
fprintf('MSE for Linear Regression: %.4f\n', mse1);
fprintf('MSE for Stepwise Regression: %.4f\n', mse2);
fprintf('MSE for LASSO Regression: %.4f\n', mse3);

% Repeat the process for stepwise regression and LASSO with variable selection on training set
mdl2_train = stepwiselm(X_train, y_train);
[B_train, FitInfo_train] = lasso(X_train, y_train, 'CV', 10);
lasso_idx_train = FitInfo_train.Index1SE;
B0_train = FitInfo_train.Intercept(lasso_idx_train);
mdl3_train = @(X) X * B_train(:, lasso_idx_train) + B0_train;

% Calculate MSE for each model on the test set
y_pred2_train = predict(mdl2_train, X_test);
mse2_train = mean((y_test - y_pred2_train).^2);

y_pred3_train = mdl3_train(X_test);
mse3_train = mean((y_test - y_pred3_train).^2);

% Display MSE for each model with variable selection on training set
fprintf('MSE for Stepwise Regression (train selection): %.4f\n', mse2_train);
fprintf('MSE for LASSO Regression (train selection): %.4f\n', mse3_train);