%% Group 7
% Dimitrios Ioannidis (10415)
% Dimitrios Karatis (10775)

%% Zitima 2
clear; close all; clc;

% Load data
filename = 'TMS.xlsx';
data = readtable(filename);
TMS = data.TMS; % TMS status (1 = with TMS, 0 = without TMS)
CoilCode = data.CoilCode; % Coil shape (1 = eight shape, 0 = round)
EDduration = data.EDduration; % Duration of ED

% CoilCode -> from cell array to double
if iscell(CoilCode)
    CoilCode = cellfun(@str2double, CoilCode);
end

% Seperation of ED data based on CoilCode and TMS
ED_eight_shape = EDduration(CoilCode == 1 & TMS == 1); % Data with eight-shaped coil, TMS
ED_round_shape = EDduration(CoilCode == 0 & TMS == 1); % Data with round coil, TMS

num_resamples = 1000; % Number of resamples

% Function to perform resampling-based goodness-of-fit test
function p_value = resampling_gof_test(data, num_resamples)
    % Estimate the parameter of the exponential distribution
    lambda_hat = 1 / mean(data); % MLE gia lambda
    
    % Compute the Chi-square statistic for the original sample using the MLE
    cdf_exp = @(x) 1 - exp(-lambda_hat * x);
    [~, ~, stats] = chi2gof(data, 'CDF', cdf_exp);
    chi2_stat_0 = stats.chi2stat; % Chi-square gia to arxiko deigma
    
    % Generate resamples and compute Chi-square statistics
    chi2_resamples = zeros(num_resamples, 1);
    for i = 1:num_resamples
        resample = exprnd(1/lambda_hat, size(data));
        [~, ~, stats_resample] = chi2gof(resample, 'CDF', cdf_exp);
        chi2_resamples(i) = stats_resample.chi2stat;
    end
    
    % Compute the p-value
    p_value = mean(chi2_resamples >= chi2_stat_0);
end

% Perform the resampling-based goodness-of-fit test for both samples
p_value_eight = resampling_gof_test(ED_eight_shape, num_resamples);
p_value_round = resampling_gof_test(ED_round_shape, num_resamples);

% Display the results
fprintf('Resampling-based Goodness-of-Fit Test Results:\n');
fprintf('Eight-shaped coil: p-value = %.3f\n', p_value_eight);
fprintf('Round coil: p-value = %.3f\n', p_value_round);

% Compare with parametric Chi-square goodness-of-fit test
lambda_hat_eight = 1 / mean(ED_eight_shape);
lambda_hat_round = 1 / mean(ED_round_shape);
cdf_exp_eight = @(x) 1 - exp(-lambda_hat_eight * x);
cdf_exp_round = @(x) 1 - exp(-lambda_hat_round * x);
[h_eight, p_eight] = chi2gof(ED_eight_shape, 'CDF', cdf_exp_eight);
[h_round, p_round] = chi2gof(ED_round_shape, 'CDF', cdf_exp_round);

% Display the parametric test results
fprintf('Parametric Goodness-of-Fit Test Results:\n');
fprintf('Eight-shaped coil: h = %d, p-value = %.3f\n', h_eight, p_eight);
fprintf('Round coil: h = %d, p-value = %.3f\n', h_round, p_round);

%% Conclusion
% Compare the results of the resampling-based and parametric goodness-of-fit tests.
% Determine whether the results differ for the two coil shapes (eight-shaped and round).
