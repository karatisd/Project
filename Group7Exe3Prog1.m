%% Group 7
% Dimitrios Ioannidis (10415)
% Dimitrios Karatis (10775)

%% Zitima 3
% Clear workspace and close all figures
clear; close all; clc;

% Step 1: Load the dataset from TMS.xlsx
filename = 'TMS.xlsx';
data = readtable(filename);

% Extract the relevant columns
TMS = data.TMS; % TMS status (1 = with TMS, 0 = without TMS)
Setup = data.Setup; % Measurement setup (1 to 6)
EDduration = data.EDduration; % Duration of ED

% Calculate the mean duration of ED without TMS (μ0)
ED_no_TMS = EDduration(TMS == 0);
mu0 = mean(ED_no_TMS);

% Perform analysis for each setup
results = Group7Exe3Fun1(TMS, Setup, EDduration, mu0);

% Initialize arrays to store which setups have normal distribution
normal_no_TMS = results.H0_rejected_no_TMS == 0;
normal_with_TMS = results.H0_rejected_with_TMS == 0;

% Display results
Group7Exe3Fun2(results, mu0, normal_no_TMS, normal_with_TMS);