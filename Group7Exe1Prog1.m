%% Group 7
% Dimitrios Ioannidis (10415)
% Dimitrios Karatis (10775)

%% Zitima 1

clear; close all; clc;

% Fortwsi dedomenwn
filename = 'TMS.xlsx';
data = readtable(filename);
TMS = data.TMS; 
EDduration = data.EDduration; 

% Filtrarisma dedomenwn vasi katastasis TMS
ED_with_TMS = EDduration(TMS == 1); % Dedomena me TMS
ED_without_TMS = EDduration(TMS == 0); % Dedomena xwris TMS

% Katanomes gia elegxo
distributions = {'Normal', 'Exponential', 'Gamma', 'Lognormal'};
num_bins = 20;
x_range = linspace(min(EDduration), max(EDduration), 100);

% Arxikopoiisi metavlitwn gia apothikeusi twn kaliterwn katanomwn kai p-values
bestDist_with_TMS = '';
bestPValue_with_TMS = 0;
bestDist_without_TMS = '';
bestPValue_without_TMS = 0;

for i = 1:length(distributions)
    dist_name = distributions{i};
    
    % Prosomoiwsi katanomwn stin EDduration me TMS
    dist_with_TMS = fitdist(ED_with_TMS, dist_name);
    
    % Prosomoiwsi katanomwn stin EDduration xwris TMS
    dist_without_TMS = fitdist(ED_without_TMS, dist_name);
    
    % Ypologismos PDFs twn prosomoiwmenwn katanomwn
    pdf_with_TMS = pdf(dist_with_TMS, x_range);
    pdf_without_TMS = pdf(dist_without_TMS, x_range);
    
    % Diagramma istogrammatos kai PDF gia dedomena xwris TMS
    Group7Exe1Fun1(ED_without_TMS, num_bins, x_range, pdf_without_TMS, dist_name, 'without');
    
    % Diagramma istogrammatos kai PDF gia dedomena me TMS
    Group7Exe1Fun1(ED_with_TMS, num_bins, x_range, pdf_with_TMS, dist_name, 'with');
    
    %% Vima 5: Sigkrisi katanomwn
    % Ekteleite elegxos kalis prosarmogis Chi-squared
    % Mi mideniki ipothesi: Ta dedomena akolouthoun tin prosomoiwmeni katanomi
    [h_with_TMS, p_with_TMS] = chi2gof(ED_with_TMS, 'CDF', dist_with_TMS);
    [h_without_TMS, p_without_TMS] = chi2gof(ED_without_TMS, 'CDF', dist_without_TMS);
    
    % Emfanisi apotelesmatwn
    fprintf('Goodness-of-Fit Test Results for %s distribution:\n', dist_name);
    fprintf('With TMS: h = %d, p = %.3f\n', h_with_TMS, p_with_TMS);
    fprintf('Without TMS: h = %d, p = %.3f\n', h_without_TMS, p_without_TMS);
    
    % Enimerosi tis kaliteris katanomis an i trexousa exei megalutero p-value
    if p_with_TMS > bestPValue_with_TMS
        bestPValue_with_TMS = p_with_TMS;
        bestDist_with_TMS = dist_name;
    end
    if p_without_TMS > bestPValue_without_TMS
        bestPValue_without_TMS = p_without_TMS;
        bestDist_without_TMS = dist_name;
    end
end

% Emfanisi twn kaliterwn katanomwn vasi twn p-values
fprintf('Best Distribution with TMS: %s (p-value: %.3f)\n', bestDist_with_TMS, bestPValue_with_TMS);
fprintf('Best Distribution without TMS: %s (p-value: %.3f)\n', bestDist_without_TMS, bestPValue_without_TMS);

%% Simperasmata
% Sigkrisi twn katanomwn optika kai statistika (p-values apo ton elegxo
% Chi-squared). Afto kathorizei an oi katanomes tis EDduration einai
% omoiomorfes i simantika diaforetikes me kai xwris TMS.