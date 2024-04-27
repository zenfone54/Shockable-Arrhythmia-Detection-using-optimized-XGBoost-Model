% Preprocessing steps
clc;
clear all;
close all;

% Base file path for input and output files
base_input_path = "D:\Capstone\Databases\VFDB_mat_files\";
base_output_path = "D:\Capstone\MatLab\Final codes\VFDB\psd_band_power_energy\";

for file_num = 418:439
    % Construct input filename
    input_filename = sprintf('%02dm.mat', file_num);
    full_input_path = fullfile(base_input_path, input_filename);

    % Load the .mat file
    load(full_input_path);

    val = (val-0)/200;

    fs=250;
    Fs=250;
    % Bandpass filter to remove noise
    f_low = 0.5; % Hz
    f_high = 45; % Hz
    [b, a] = butter (3, [f_low, f_high]/ (fs/2), 'bandpass') ;
    filtered_signal = filtfilt(b, a, val);

    ecg_signal = filtered_signal(:);
    % Define segment length and number of segments
    segment_length = 5;  % Segment length in seconds
    fs = 250;             % Sampling frequency
    samples_per_segment = fs * segment_length;  % Number of samples per segment
    num_segments = floor(length(ecg_signal) / samples_per_segment);  % Total number of segments


    %% pwelch for calculating PSD

    % Initialize arrays to store band power for each segment
    band_power_array = zeros(1, num_segments);
    band_power_array_new = zeros(1, num_segments);  %multiplying band_power by 10000
    % Initialize a array to store energy values for each segment
    energy_array = zeros(1, num_segments);

    % Define frequency bands for band power calculation
    delta_band = [0.5, 4];
    theta_band = [4, 8];
    alpha_band = [8, 13];
    beta_band = [13, 30];
    gamma_band = [30, 45];

    % Iterate over each segment
    for i = 1:num_segments
        % Extract the current segment
        start_index = (i - 1) * samples_per_segment + 1;
        end_index = i * samples_per_segment;
        current_segment = ecg_signal(start_index:end_index);

        % Compute Power Spectral Density (PSD) using pwelch
        [psd, freq] = pwelch(current_segment, [], [], [], fs);


        % Calculate band power
        delta_power = bandpower(psd, fs, delta_band);
        theta_power = bandpower(psd, fs, theta_band);
        alpha_power = bandpower(psd, fs, alpha_band);
        beta_power = bandpower(psd, fs, beta_band);
        gamma_power = bandpower(psd, fs, gamma_band);

        % Store total band power for the segment
        band_power_array(i) = delta_power + theta_power + alpha_power + beta_power + gamma_power;
        band_power_array_new(i) = band_power_array(i)*10000;
        % Calculate energy for the current segment
        energy_array(i) = sum(current_segment .^ 2);
    end

    % Display band power for each segment
    disp('Band Power for each segment:');
    disp(band_power_array);

    % Display band power for each segment
    disp('Band Power*10000 for each segment:');
    disp(band_power_array_new);

    % Display energy values for each segment
    disp('Energy for each segment:');
    disp(energy_array);

    % Construct output filename
    output_filename = sprintf('power_energy_vf%02d.csv', file_num);
    full_output_path = fullfile(base_output_path, output_filename);

    % Save in csv file
    fileID = fopen(full_output_path, 'w'); % Overwrite existing file
    % fprintf(fileID, 'Shannon_Entropy,Sample_Entropy\n'); % Add a header row
    fclose(fileID);
    dlmwrite(full_output_path, [band_power_array_new', energy_array'], '-append', 'precision', '%.6f', 'delimiter', ',');
end

% % Save in csv file
% name = ('band_power_energy.csv');
% fileID = fopen(name, 'w');
% % fprintf(fileID, 'heart_rates,RR_intervals_seconds_all\n');
% fclose(fileID);
% dlmwrite(name, [band_power_array_new', energy_array'], '-append', 'precision', '%.4f', 'delimiter', ',');