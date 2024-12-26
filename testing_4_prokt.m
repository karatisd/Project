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
    'VariableNames', {'Setup', 'Correlation', 'Parametric_pValue', 'Permutation_pValue'});

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
        results.Correlation(i) = NaN;
        results.Parametric_pValue(i) = NaN;
        results.Permutation_pValue(i) = NaN;
        continue;
    end
    
    % Calculate correlation coefficient
    r = corr(preTMS_i, postTMS_i, 'Type', 'Pearson');
    
    % Calculate t-statistic for parametric test
    n = length(preTMS_i);
    t_stat = r * sqrt((n-2)/(1-r^2));
    % Two-tailed p-value from Student's t-distribution
    p_parametric = 2 * (1 - tcdf(abs(t_stat), n-2));
    
    % Permutation test
    perm_r = zeros(num_permutations, 1);
    for j = 1:num_permutations
        perm_postTMS = postTMS_i(randperm(length(postTMS_i)));
        perm_r(j) = corr(preTMS_i, perm_postTMS, 'Type', 'Pearson');
    end
    % Two-sided test using absolute values
    p_permutation = mean(abs(perm_r) >= abs(r));
    
    % Store results
    results.Setup(i) = i;
    results.Correlation(i) = r;
    results.Parametric_pValue(i) = p_parametric;
    results.Permutation_pValue(i) = p_permutation;
end

% Display results
disp('Results of correlation analysis between preTMS and postTMS:');
disp(results);

% Interpretation of results
for i = 1:6
    fprintf('\nSetup %d:\n', i);
    fprintf('Correlation coefficient: %.3f\n', results.Correlation(i));
    fprintf('Parametric test p-value: %.3f\n', results.Parametric_pValue(i));
    fprintf('Permutation test p-value: %.3f\n', results.Permutation_pValue(i));
    
    if isnan(results.Parametric_pValue(i))
        fprintf('Insufficient data or contains NaN values\n');
    else
        % Interpret results at 5% significance level
        if results.Parametric_pValue(i) < 0.05
            fprintf('Parametric test: Significant correlation detected\n');
        else
            fprintf('Parametric test: No significant correlation detected\n');
        end
        
        if results.Permutation_pValue(i) < 0.05
            fprintf('Permutation test: Significant correlation detected\n');
        else
            fprintf('Permutation test: No significant correlation detected\n');
        end
    end
end