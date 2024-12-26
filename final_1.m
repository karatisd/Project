function plot_histogram_and_pdf(data, num_bins, x_range, pdf_values, dist_name, TMS_status)
    % Plot histogram and PDF for the given data
    figure;
    histogram(data, num_bins, 'Normalization', 'pdf', 'FaceColor', [0.7 0.7 0.7]);
    hold on;
    plot(x_range, pdf_values, 'LineWidth', 2);
    xlabel('EDduration (seconds)');
    ylabel('Density');
    title(['EDduration ' TMS_status ' TMS - ' dist_name]);
    legend('Empirical PDF', ['Fitted ' dist_name ' PDF']);
    grid on;
end

%% KARATIS DIMITRIOS 10775
%% IWANNIDIS DIMITRIOS 10415

%% MATLAB Script: Exercise 1
% This script analyzes the EDduration data with and without TMS, identifies
% the best-fitting probability distributions, and plots the empirical and
% fitted probability density functions (PDFs).


% Clear workspace and close all figures
clear; close all; clc;

% Load the dataset from TMS.xlsx
filename = 'TMS.xlsx';
data = readtable(filename);

% Extract the relevant columns
TMS = data.TMS; % TMS status (1 = with TMS, 0 = without TMS)
EDduration = data.EDduration; % Duration of ED

% Separate data based on TMS status
ED_with_TMS = EDduration(TMS == 1); % Data with TMS
ED_without_TMS = EDduration(TMS == 0); % Data without TMS

% List of distributions to test
distributions = {'Normal', 'Exponential', 'Gamma', 'Lognormal', 'Weibull'};
num_bins = 20;
x_range = linspace(min(EDduration), max(EDduration), 100);

% Initialize variables to store the best distributions and p-values
bestDist_with_TMS = '';
bestPValue_with_TMS = 0;
bestDist_without_TMS = '';
bestPValue_without_TMS = 0;

for i = 1:length(distributions)
    dist_name = distributions{i};
    
    % Fit distributions to EDduration with TMS
    dist_with_TMS = fitdist(ED_with_TMS, dist_name);
    
    % Fit distributions to EDduration without TMS
    dist_without_TMS = fitdist(ED_without_TMS, dist_name);
    
    % Compute PDFs of the fitted distributions
    pdf_with_TMS = pdf(dist_with_TMS, x_range);
    pdf_without_TMS = pdf(dist_without_TMS, x_range);
    
    % Plot histogram and PDF for data without TMS
    plot_histogram_and_pdf(ED_without_TMS, num_bins, x_range, pdf_without_TMS, dist_name, 'without');
    
    % Plot histogram and PDF for data with TMS
    plot_histogram_and_pdf(ED_with_TMS, num_bins, x_range, pdf_with_TMS, dist_name, 'with');
    
    %% Step 5: Compare distributions
    % Perform a Chi-squared goodness-of-fit test
    % Null hypothesis: Data follows the fitted distribution
    [h_with_TMS, p_with_TMS] = chi2gof(ED_with_TMS, 'CDF', dist_with_TMS);
    [h_without_TMS, p_without_TMS] = chi2gof(ED_without_TMS, 'CDF', dist_without_TMS);
    
    % Display results
    fprintf('Goodness-of-Fit Test Results for %s distribution:\n', dist_name);
    fprintf('With TMS: h = %d, p = %.3f\n', h_with_TMS, p_with_TMS);
    fprintf('Without TMS: h = %d, p = %.3f\n', h_without_TMS, p_without_TMS);
    
    % Update the best distribution if the current one has a higher p-value
    if p_with_TMS > bestPValue_with_TMS
        bestPValue_with_TMS = p_with_TMS;
        bestDist_with_TMS = dist_name;
    end
    if p_without_TMS > bestPValue_without_TMS
        bestPValue_without_TMS = p_without_TMS;
        bestDist_without_TMS = dist_name;
    end
end

% Display the best distributions based on p-values
fprintf('Best Distribution with TMS: %s (p-value: %.3f)\n', bestDist_with_TMS, bestPValue_with_TMS);
fprintf('Best Distribution without TMS: %s (p-value: %.3f)\n', bestDist_without_TMS, bestPValue_without_TMS);

%% Conclusion
% Compare the distributions visually and statistically (p-values from the
% Chi-squared test). This determines whether the EDduration distributions
% are similar or significantly different with and without TMS.