% Filename: Realtime_Controller 
% Author: Naledi Majake 
% Student ID: 11138055 
% Date: 01 May 2026
% RUN_ME.m - Simple script to start the PRPD simulation
clear; close all; clc;
fprintf(' STARTING PRPD SIMULATOR...\n\n');

% ===== CONFIGURATION - CHANGE THESE =====
data_folder = "C:\Users\v43367nm\OneDrive - The University of Manchester\Documents\Third year\Github-Test Data (2026)\Final\700V With Test Object 100k Points"; 
ref_Phasefile = "C:\Users\v43367nm\OneDrive - The University of Manchester\Documents\Third year\Github-Test Data (2026)\Final\400V DC Bus - Phase to Ground Voltages.csv";
data_fs = 500000;               % Sampling frequency (Hz) for data folder 
ref_fs = 5000000;               % Sampling frequency (Hz) for reference file
peak_threshold = 0.005;         % Peak detection threshold (adjust based on noise level)
ref_channel_number = 5;         % Column containing Vref in data files
matlab_file_location = "C:\Users\v43367nm\OneDrive - The University of Manchester\Documents\Third year\Individual project\Matlab_Files"; 
% =========================================

% Add MATLAB files to path
addpath(matlab_file_location);

% Run the controller
Realtime_Controller(data_folder, data_fs, ref_Phasefile, ref_fs, peak_threshold, ref_channel_number)