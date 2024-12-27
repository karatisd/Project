function Group7Exe8Fun1(data_full, include_spike)
    % Function to analyze ED duration using multiple regression models
    % Input:
    %   data_full: table with TMS data
    %   include_spike: boolean to include/exclude Spike variable
    
    % Define independent variables
    base_vars = {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode', 'preTMS'};
    if include_spike
        independent_vars = [base_vars, {'Spike'}];
    else
        independent_vars = base_vars;
    end
    
    % Remove any rows with missing values
    vars_to_check = [independent_vars, {'EDduration'}];
    data_clean = data_full;
    data_clean = rmmissing(data_clean, 'DataVariables', vars_to_check);
    
    % Convert categorical variables to numeric if needed
    for var = independent_vars
        if iscell(data_clean.(var{:})) || iscategorical(data_clean.(var{:}))
            data_clean.(var{:}) = double(categorical(data_clean.(var{:})));
        end
    end
    
    % Extract predictor variables and response
    X = data_clean{:, independent_vars};
    y = data_clean.EDduration;
    
    % Print the correlation matrix of the predictors
    corr_matrix = corr(X);
    fprintf('Correlation matrix of predictors:\n');
    disp(corr_matrix);
    
    % Check for multicollinearity using the variance inflation factor (VIF)
    VIF = diag(inv(corr_matrix));
    highVIF = VIF > 10; % Threshold for high VIF, typically 10

    if any(highVIF)
        fprintf('Variables with high VIF (multicollinearity):\n');
        disp(find(highVIF));
        % Remove variables with high VIF
        X = X(:, ~highVIF);
        independent_vars = independent_vars(~highVIF);
    end

    % 1. Full Model
    try
        mdl_full = fitlm(X, y, 'VarNames', [independent_vars, {'EDduration'}]);
        fprintf('\nFull Model Results:\n');
        fprintf('R-squared: %.3f\n', mdl_full.Rsquared.Ordinary);
        fprintf('Adjusted R-squared: %.3f\n', mdl_full.Rsquared.Adjusted);
        fprintf('MSE: %.3f\n', mdl_full.MSE);
    catch ME
        fprintf('Error in full model: %s\n', ME.message);
    end
    
    % 2. Stepwise Regression
    try
        mdl_stepwise = stepwiselm(X, y, 'VarNames', [independent_vars, {'EDduration'}]);
        fprintf('\nStepwise Model Results:\n');
        fprintf('R-squared: %.3f\n', mdl_stepwise.Rsquared.Ordinary);
        fprintf('Adjusted R-squared: %.3f\n', mdl_stepwise.Rsquared.Adjusted);
        fprintf('MSE: %.3f\n', mdl_stepwise.MSE);
        
        % Display selected variables
        selected_vars = mdl_stepwise.PredictorNames;
        fprintf('Selected variables: ');
        fprintf('%s, ', selected_vars{1:end-1});
        fprintf('%s\n', selected_vars{end});
    catch ME
        fprintf('Error in stepwise model: %s\n', ME.message);
    end
    
    % 3. LASSO Regression
    try
        % Standardize predictors for LASSO
        [X_std, mu, sigma] = zscore(X);
        
        % Perform cross-validated LASSO
        [B, FitInfo] = lasso(X_std, y, 'CV', 10);
        
        % Find best lambda
        lambda_min = FitInfo.Lambda(FitInfo.IndexMinMSE);
        coef = B(:,FitInfo.IndexMinMSE);
        
        % Transform coefficients back to original scale
        coef_orig = coef ./ sigma';
        intercept = FitInfo.Intercept(FitInfo.IndexMinMSE) - sum(coef_orig .* mu');
        
        % Calculate R-squared for best lambda
        y_pred = X_std * coef + FitInfo.Intercept(FitInfo.IndexMinMSE);
        RSS = sum((y - y_pred).^2);
        TSS = sum((y - mean(y)).^2);
        R2_lasso = 1 - RSS/TSS;
        
        fprintf('\nLASSO Model Results:\n');
        fprintf('R-squared: %.3f\n', R2_lasso);
        fprintf('MSE: %.3f\n', FitInfo.MSE(FitInfo.IndexMinMSE));
        
        % Display non-zero coefficients
        nonzero_idx = abs(coef) > 1e-10;
        fprintf('Selected variables: ');
        fprintf('%s, ', independent_vars{nonzero_idx(1:end-1)});
        fprintf('%s\n', independent_vars{nonzero_idx(end)});
        
        % Plot LASSO results
        figure;
        lassoPlot(B, FitInfo, 'PlotType', 'Lambda', 'XScale', 'log');
        title('LASSO Regression Results');
    catch ME
        fprintf('Error in LASSO model: %s\n', ME.message);
    end
end