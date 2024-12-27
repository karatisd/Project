%% Group 7
% Dimitrios Ioannidis (10415)
% Dimitrios Karatis (10775)

%% Zitima 8
clear; close all; clc;

% Load data
filename = 'TMS.xlsx';
data = readtable(filename);

% Filter rows where TMS == 1 and remove rows with missing EDduration
data_full = data(data.TMS == 1, :);
data_full = rmmissing(data_full);

% Include Spike in the analysis
include_spike = true;

% Call the function for analysis
Group7Exe8Fun1(data_full, include_spike);
