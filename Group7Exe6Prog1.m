%% Group 7
% Dimitrios Ioannidis (10415)
% Dimitrios Karatis (10775)

%% Zitima 6
clear; close all; clc;

% Load data
filename = 'TMS.xlsx';
data = readtable(filename);

% Filter rows where TMS == 1 and remove rows with missing EDduration
data_full = data(data.TMS == 1, :);
data_full = rmmissing(data_full);

% 'Spike' data included
include_spike = true;
Group7Exe6Fun1(data_full, include_spike);

% 'Spike' data excluded
include_spike = false; 
Group7Exe6Fun1(data_full, include_spike);


%% Conclusions
% Apo ta apotelesmata, kai otan symperilamvanoume to 'Spike' sta predictors kai otan to 
% apokleioume, vlepoume oti to plhres montelo exei megalutero R-squared, alla ta montela 
% epilegmenwn metavlhtwn exoun mikrotero MSE. 

% Ola ta montela wstoso exoun poly xamhlo R^2. Opws eidame kai sto 5o zitima gia to Setup, 
% ayto mallon ofeiletai sto oti ta grammika montela de mporoun na perigrapsoun eparkws 
% th sxesh tou EDduration me tis upoloipes metavlhtes. Typwnontas ta correlations metaksy
% twn predictors kai tou EDduration, vlepoume:
% Correlations between predictors and EDduration:
% Setup: -0.015
% Stimuli: 0.122
% Intensity: 0.168
% Spike: -0.001
% Frequency: -0.232
% CoilCode: -0.168
% Thn isxyroterh sysxetish thn exei to Frequency, kai thn mikroterh to Spike.

% Symperilamvanontas to Spike ta apotelesmata einai peripou idia. Mono to 'full model' 
% exei ligo xeirotero apotelesmata xwris to Spike. Ayto ofeiletai sto oti to Spike sysxetizetai
% poly adynama me to EDduration.
% Episis ta montela epilegmenwn metavlhtwn exoun akrivws ta idia apotelesmata xwris to Spike,
% kathws mallon to apokleioun apo mona tous.
