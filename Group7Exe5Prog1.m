%% Group 7
% Dimitrios Ioannidis (10415)
% Dimitrios Karatis (10775)

%% Zitima 5
clear; close all; clc;

% Loading data
filename = 'TMS.xlsx';
data = readtable(filename);
TMS = data.TMS; % TMS status (1 = with TMS, 0 = without TMS)
EDduration = data.EDduration; % Duration of ED
Setup = data.Setup; % Measurement setup (1 to 6)

% Results tables
results_linear = table('Size', [2, 2], 'VariableTypes', {'string', 'double'}, ...
    'VariableNames', {'Condition', 'R_squared'});
results_poly2 = table('Size', [2, 2], 'VariableTypes', {'string', 'double'}, ...
    'VariableNames', {'Condition', 'R_squared'});
results_poly3 = table('Size', [2, 2], 'VariableTypes', {'string', 'double'}, ...
    'VariableNames', {'Condition', 'R_squared'});
results_poly4 = table('Size', [2, 2], 'VariableTypes', {'string', 'double'}, ...
    'VariableNames', {'Condition', 'R_squared'});
results_poly5 = table('Size', [2, 2], 'VariableTypes', {'string', 'double'}, ...
    'VariableNames', {'Condition', 'R_squared'});
results_poly6 = table('Size', [2, 2], 'VariableTypes', {'string', 'double'}, ...
    'VariableNames', {'Condition', 'R_squared'});

% Regression for both cases
conditions = {'Without TMS', 'With TMS'}; % Without TMS (TMS = 0) and With TMS (TMS = 1)
for conditionIdx = 1:2

    if conditionIdx == 1
        idx = (TMS == 0); % without TMS
    else
        idx = (TMS == 1); % with TMS
    end
    EDduration_cond = EDduration(idx);
    Setup_cond = Setup(idx);

    % Linear regression model
    model = fitlm(Setup_cond, EDduration_cond);

    % Polynomial models
    poly2_model = fitlm(Setup_cond, EDduration_cond, 'poly2'); 
    poly3_model = fitlm(Setup_cond, EDduration_cond, 'poly3');
    poly4_model = fitlm(Setup_cond, EDduration_cond, 'poly4');
    poly5_model = fitlm(Setup_cond, EDduration_cond, 'poly5');
    poly6_model = fitlm(Setup_cond, EDduration_cond, 'poly6');

    % Getting R^2 for all models
    results_linear.Condition(conditionIdx) = conditions{conditionIdx};
    results_linear.R_squared(conditionIdx) = model.Rsquared.Ordinary;

    results_poly2.Condition(conditionIdx) = conditions{conditionIdx};
    results_poly2.R_squared(conditionIdx) = poly2_model.Rsquared.Ordinary;

    results_poly3.Condition(conditionIdx) = conditions{conditionIdx};
    results_poly3.R_squared(conditionIdx) = poly3_model.Rsquared.Ordinary;

    results_poly4.Condition(conditionIdx) = conditions{conditionIdx};
    results_poly4.R_squared(conditionIdx) = poly4_model.Rsquared.Ordinary;

    results_poly5.Condition(conditionIdx) = conditions{conditionIdx};
    results_poly5.R_squared(conditionIdx) = poly5_model.Rsquared.Ordinary;

    results_poly6.Condition(conditionIdx) = conditions{conditionIdx};
    results_poly6.R_squared(conditionIdx) = poly6_model.Rsquared.Ordinary;

    % Plots
    Setup_fine = linspace(min(Setup_cond), max(Setup_cond), 100);
    % Data w/ Linear model
    figure;
    scatter(Setup_cond, EDduration_cond, 'filled');
    hold on;
    plot(Setup_fine, predict(model, Setup_fine'), '-r', 'LineWidth', 2);
    hold off;
    title(sprintf('ED Duration vs Setup for %s (Linear Fit)', conditions{conditionIdx}));
    xlabel('Setup');
    ylabel('ED Duration');
    legend('Data', 'Linear Fit', 'Location', 'best');
    grid on;

    % Data w/ Poly models
    figure;
    scatter(Setup_cond, EDduration_cond, 'filled');
    hold on;
    plot(Setup_fine, predict(poly2_model, Setup_fine'), '-g', 'LineWidth', 2);
    plot(Setup_fine, predict(poly3_model, Setup_fine'), '-b', 'LineWidth', 2);
    plot(Setup_fine, predict(poly4_model, Setup_fine'), '-m', 'LineWidth', 2);
    plot(Setup_fine, predict(poly5_model, Setup_fine'), '-c', 'LineWidth', 2);
    plot(Setup_fine, predict(poly6_model, Setup_fine'), '-y', 'LineWidth', 2);
    hold off;
    title(sprintf('ED Duration vs Setup for %s (Polynomial Fits)', conditions{conditionIdx}));
    xlabel('Setup');
    ylabel('ED Duration');
    legend('Data', '2nd Degree Polynomial Fit', '3rd Degree Polynomial Fit', '4th Degree Polynomial Fit', '5th Degree Polynomial Fit', '6th Degree Polynomial Fit', 'Location', 'best');
    grid on;
end

% Display results
disp('Linear Regression Analysis Results:');
disp(results_linear);

disp('2nd Degree Polynomial Regression Analysis Results:');
disp(results_poly2);

disp('3rd Degree Polynomial Regression Analysis Results:');
disp(results_poly3);

disp('4th Degree Polynomial Regression Analysis Results:');
disp(results_poly4);

disp('5th Degree Polynomial Regression Analysis Results:');
disp(results_poly5);

disp('6th Degree Polynomial Regression Analysis Results:');
disp(results_poly6);

%% Conclusion
% Parathroume oti oi times R^2 me to grammiko montelo einai poly xamhles, konta sto 0,
% kai gia tis dyo periptwseis (peripou 0.006 xwris TMS kai 0.08 me TMS).

% Apo tis times R^2 fainetai oti to grammiko montelo perigrafei kalytera ta dedomena me TMS.

% Etsi, apo tis times R^2 alla kai to plot twn dedomenwn me to grammiko montelo mporoume na symperanoume
% oti, nai, tha htan xrhsimo na epektathei to montelo palindromisis se kapoio polywnymiko.

% Dokimasame polywnymika montela 2ou, 3ou, 4ou, 5ou kai 6ou vathmou kai ta apotelesmata htan poly kalytera.
% Ta kalytera montela htan tou 5ou / 6ou vathmou, me R^2 peripoy 0.4 xwris TMS kai 0.48 me TMS.
% Kathws ayksanoume ton vathmo tou montelou ta apotelesmata veltiwnontai, mexri ton 6o vathmo.
% To polywnymo 6ou vathmou bgazei sxedon akrivws idia apotelesmata me tou 5ou - tote ksekinaei to overfitting.