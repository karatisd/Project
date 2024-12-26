% Clear workspace and close all figures
clear; close all; clc;

% Load the dataset from TMS.xlsx
filename = 'TMS.xlsx';
data = readtable(filename);

% Extract the relevant columns
Setup = data.Setup; % Measurement setup (1 to 6)
preTMS = data.preTMS; % Time from start of ED to TMS administration
postTMS = data.postTMS; % Time from TMS administration to end of ED

% Initialize results table
results = table('Size', [6, 4], 'VariableTypes', {'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'Setup', 'Parametric_pValue', 'Permutation_pValue', 'Correlation'});

% Number of permutations
num_permutations = 1000;

for i = 1:6
    % Extract data for the current setup
    idx = (Setup == i);
    preTMS_i = preTMS(idx);
    postTMS_i = postTMS(idx);

    % Remove missing values
    valid_idx = ~isnan(preTMS_i) & ~isnan(postTMS_i);
    preTMS_i = preTMS_i(valid_idx);
    postTMS_i = postTMS_i(valid_idx);

    % Check for constant or insufficient data
    if length(preTMS_i) < 3 || std(preTMS_i) == 0 || std(postTMS_i) == 0
        warning('Setup %d has invalid data. Skipping...', i);
        results.Parametric_pValue(i) = NaN;
        results.Permutation_pValue(i) = NaN;
        results.Correlation(i) = NaN;
        continue;
    end

    % Calculate correlation coefficient
    [r, p_parametric] = corr(preTMS_i, postTMS_i, 'Type', 'Pearson');

    % Permutation test
    perm_r = zeros(num_permutations, 1);
    for j = 1:num_permutations
        perm_postTMS = postTMS_i(randperm(length(postTMS_i)));
        perm_r(j) = corr(preTMS_i, perm_postTMS, 'Type', 'Pearson');
    end
    p_permutation = mean(abs(perm_r) >= abs(r));

    % Store results
    results.Setup(i) = i;
    results.Parametric_pValue(i) = p_parametric;
    results.Permutation_pValue(i) = p_permutation;
    results.Correlation(i) = r;
end

% Display results
disp(results);

% Interpretation of results
for i = 1:6
    fprintf('Setup %d:\n', i);
    fprintf('Parametric p-value: %.3f\n', results.Parametric_pValue(i));
    fprintf('Permutation p-value: %.3f\n', results.Permutation_pValue(i));
    fprintf('Correlation: %.3f\n', results.Correlation(i));
    if isnan(results.Parametric_pValue(i))
        fprintf('Insufficient data or contains NaN values for parametric test.\n');
    elseif results.Parametric_pValue(i) < 0.05
        fprintf('There is a significant correlation based on the parametric test.\n');
    else
        fprintf('There is no significant correlation based on the parametric test.\n');
    end
    if isnan(results.Permutation_pValue(i))
        fprintf('Insufficient data or contains NaN values for permutation test.\n');
    elseif results.Permutation_pValue(i) < 0.05
        fprintf('There is a significant correlation based on the permutation test.\n');
    else
        fprintf('There is no significant correlation based on the permutation test.\n');
    end
    fprintf('\n');
end