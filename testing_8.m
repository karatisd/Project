% Load the dataset
data = readtable('TMS.xlsx');

% Extract relevant variables
EDduration = data.EDduration;
Setup = categorical(data.Setup);
Stimuli = data.Stimuli;
Intensity = data.Intensity;
Spike = data.Spike; % Handle missing values if necessary
Frequency = data.Frequency;
CoilCode = categorical(data.CoilCode);
preTMS = data.preTMS;
postTMS = data.postTMS;

% Convert categorical variables to dummy variables
Setup_dummy = dummyvar(Setup);
CoilCode_dummy = dummyvar(CoilCode);

% Convert cell arrays to numeric arrays if necessary
if iscell(Stimuli)
    Stimuli = cellfun(@str2double, Stimuli);
end
if iscell(Intensity)
    Intensity = cellfun(@str2double, Intensity);
end
if iscell(Frequency)
    Frequency = cellfun(@str2double, Frequency);
end
if iscell(preTMS)
    preTMS = cellfun(@str2double, preTMS);
end
if iscell(postTMS)
    postTMS = cellfun(@str2double, postTMS);
end

% Prepare the design matrix for the full model
X_full = [Setup_dummy, Stimuli, Intensity, CoilCode_dummy, Frequency, preTMS];

% Model 1: Full regression model
mdl_full = fitlm(X_full, EDduration);

% Model 2: Stepwise regression
mdl_stepwise = stepwiselm(X_full, EDduration);

% Model 3: LASSO regression
[B, FitInfo] = lasso(X_full, EDduration, 'CV', 10);
lassoPlot(B, FitInfo); % Visualize the LASSO path
B_Lasso = B(:, FitInfo.IndexMinMSE); % Coefficients for optimal lambda

% Model 4: PCR (Principal Component Regression)
[coeff, score, ~, ~, explained] = pca(X_full);
n_components = find(cumsum(explained) > 95, 1); % Retain 95% variance
X_pcr = score(:, 1:n_components);
mdl_pcr = fitlm(X_pcr, EDduration);

% Extend all models by adding postTMS
X_extended = [X_full, postTMS];

mdl_full_extended = fitlm(X_extended, EDduration);
mdl_stepwise_extended = stepwiselm(X_extended, EDduration);

[B_ext, FitInfo_ext] = lasso(X_extended, EDduration, 'CV', 10);
lassoPlot(B_ext, FitInfo_ext);

[coeff_ext, score_ext, ~, ~, explained_ext] = pca(X_extended);
n_components_ext = find(cumsum(explained_ext) > 95, 1);
X_pcr_ext = score_ext(:, 1:n_components_ext);
mdl_pcr_ext = fitlm(X_pcr_ext, EDduration);

% Compare models
disp('Full Model Adjusted R^2:'), disp(mdl_full.Rsquared.Adjusted);
disp('Stepwise Model Adjusted R^2:'), disp(mdl_stepwise.Rsquared.Adjusted);
disp('LASSO Adjusted R^2:'), disp(FitInfo.IndexMinMSE);
disp('PCR Adjusted R^2:'), disp(mdl_pcr.Rsquared.Adjusted);

disp('Full Extended Model Adjusted R^2:'), disp(mdl_full_extended.Rsquared.Adjusted);
disp('Stepwise Extended Model Adjusted R^2:'), disp(mdl_stepwise_extended.Rsquared.Adjusted);
disp('PCR Extended Adjusted R^2:'), disp(mdl_pcr_ext.Rsquared.Adjusted);