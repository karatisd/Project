%% Group 7
% Dimitrios Ioannidis (10415)
% Dimitrios Karatis (10775)

%% Zitima 6 - Synarthsh
% Kanei fit plhres montelo, montelo vimatikis palindromisis kai montelo lasso
% Analoga me to input 'include_spike' symperilamvanoume th metavlhth 'Spike'
function func_8(data_full, include_spike, include_postTMS)
    % Include or exclude 'Spike' and 'postTMS'
    if include_spike && include_postTMS
        independent_vars = {'Setup', 'Stimuli', 'Intensity', 'Spike', 'Frequency', 'CoilCode', 'preTMS', 'postTMS'};
        disp('------ INCLUDING SPIKE AND postTMS ------');
    elseif include_spike && ~include_postTMS
        independent_vars = {'Setup', 'Stimuli', 'Intensity', 'Spike', 'Frequency', 'CoilCode', 'preTMS'};
        disp('------ INCLUDING SPIKE ------');
    elseif ~include_spike && include_postTMS
        independent_vars = {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode', 'preTMS', 'postTMS'};
        disp('------ INCLUDING postTMS ------');
    else
        independent_vars = {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode', 'preTMS'};
        disp('------ EXCLUDING SPIKE AND postTMS ------');
    end

    % Convert categorical variables to numeric
    for var = independent_vars
        if iscell(data_full.(var{:})) || iscategorical(data_full.(var{:}))
            data_full.(var{:}) = double(categorical(data_full.(var{:})));
        end
    end

    % Extract independent and dependent variables
    X_full = data_full{:, independent_vars};
    y = data_full.EDduration;

    % Print correlations between predictors and EDduration
    fprintf('Correlations between predictors and EDduration:\n');
    for i = 1:numel(independent_vars)
        corr_with_y = corr(X_full(:, i), y);
        fprintf('  %s: %.3f\n', independent_vars{i}, corr_with_y);
    end

    % Models
    full_model = fitlm(X_full, y, 'VarNames', ['EDduration', independent_vars]); % Full model
    stepwise_model = stepwiselm(X_full, y, 'VarNames', ['EDduration', independent_vars]); % Stepwise Model
    [B, FitInfo] = lasso(X_full, y, 'CV', 50, 'LambdaRatio', 0.01); % LASSO Model

    % Explore predictors selected with minimum MSE
    [~, lambda_min_idx] = min(FitInfo.MSE); % Index of minimum MSE
    lasso_vars_min = find(B(:, lambda_min_idx) ~= 0); % Predictors at minimum MSE

    if isempty(lasso_vars_min)
        disp('LASSO did not select any predictors.');
        mdl_lasso = []; % No model can be fitted
    else
        X_lasso = X_full(:, lasso_vars_min); % Reduced dataset based on LASSO
        mdl_lasso = fitlm(X_lasso, y, 'VarNames', ['EDduration', independent_vars(lasso_vars_min)]);
    end

    % Principal Component Regression (PCR)
    [coeff, score, ~, ~, explained] = pca(X_full);
    n_components = find(cumsum(explained) >= 95, 1); % Retain components explaining 95% variance
    X_pcr = score(:, 1:n_components);
    mdl_pcr = fitlm(X_pcr, y);

    % Compare models
    fprintf('\nModel Comparisons:\n');
    fprintf('1. Full Model:\n');
    fprintf('  R-squared: %.3f\n', full_model.Rsquared.Ordinary);
    fprintf('  Adjusted R-squared: %.3f\n', full_model.Rsquared.Adjusted);
    fprintf('  Mean Squared Error: %.3f\n', full_model.MSE);

    fprintf('\n2. Stepwise Regression Model:\n');
    fprintf('  R-squared: %.3f\n', stepwise_model.Rsquared.Ordinary);
    fprintf('  Adjusted R-squared: %.3f\n', stepwise_model.Rsquared.Adjusted);
    fprintf('  Mean Squared Error: %.3f\n', stepwise_model.MSE);
    
    % Display selected variables for stepwise model
    selected_vars_stepwise = stepwise_model.PredictorNames;
    fprintf('  Selected variables: ');
    fprintf('%s, ', selected_vars_stepwise{1:end-1});
    fprintf('%s\n', selected_vars_stepwise{end});

    if ~isempty(mdl_lasso)
        fprintf('\n3. LASSO Regression Model (Min MSE Lambda):\n');
        fprintf('  R-squared: %.3f\n', mdl_lasso.Rsquared.Ordinary);
        fprintf('  Adjusted R-squared: %.3f\n', mdl_lasso.Rsquared.Adjusted);
        fprintf('  Mean Squared Error: %.3f\n', mdl_lasso.MSE);
        
        % Display selected variables for LASSO model
        fprintf('  Selected variables: ');
        fprintf('%s, ', independent_vars{lasso_vars_min(1:end-1)});
        fprintf('%s\n', independent_vars{lasso_vars_min(end)});
    else
        fprintf('\n3. LASSO Regression Model: No predictors selected.\n');
    end

    fprintf('\n4. Principal Component Regression (PCR):\n');
    fprintf('  R-squared: %.3f\n', mdl_pcr.Rsquared.Ordinary);
    fprintf('  Adjusted R-squared: %.3f\n', mdl_pcr.Rsquared.Adjusted);
    fprintf('  Mean Squared Error: %.3f\n', mdl_pcr.MSE);
end
