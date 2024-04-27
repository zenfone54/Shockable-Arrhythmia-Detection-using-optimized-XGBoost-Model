clc;
clear all;
close all;

% Base file path for input and output files
base_input_path = "D:\Capstone\Databases\VFDB_mat_files\";
base_output_path = "D:\Capstone\MatLab\Final codes\VFDB\shannon_sample_entropy\";

for file_num = 418:439
    % Construct input filename
    input_filename = sprintf('%02dm.mat', file_num);
    full_input_path = fullfile(base_input_path, input_filename);

    % Load the .mat file
    load(full_input_path);
    val = (val-0)/200;

    fs=250;

    % Bandpass filter to remove noise
    f_low = 0.5; % Hz
    f_high = 45; % Hz
    [b, a] = butter (3, [f_low, f_high]/ (fs/2), 'bandpass') ;
    filtered_signal = filtfilt(b, a, val);

    ecg_signal = filtered_signal(:);

    %% 
    % Define segment length and number of segments
    segment_length = 5;  % Segment length in seconds
    fs = 250;             % Sampling frequency
    samples_per_segment = fs * segment_length;  % Number of samples per segment
    num_segments = floor(length(ecg_signal) / samples_per_segment);  % Total number of segments

    % Parameters for Sample Entropy calculation
    m = 2; % Embedding dimension
    r = 0.2; % Tolerance threshold (scaled standard deviation)

    % Initialize arrays to store entropy values for each segment
    shannon_entropy_array = zeros(1, num_segments);
    % Initialize a cell array to store the sample entropy for each segment
    sampen_cell = cell(1, num_segments);

    % Iterate over each segment
    for i = 1:num_segments
        % Extract the current segment
        start_index = (i - 1) * samples_per_segment + 1;
        end_index = i * samples_per_segment;
        current_segment = ecg_signal(start_index:end_index);

        % Compute Shannon entropy
        % shannon_entropy_array(i) = wentropy(current_segment,'shannon');
        shannon_entropy_array(i) = entropy(current_segment);


        % Calculate sample entropy
        sampen_value = sampen(current_segment, m, r);

        % Store the sample entropy value
        sampen_cell{i} = sampen_value;
    end

    % % % Display results or perform further analysis
    % % disp('Shannon Entropy for each segment:');
    % % disp(shannon_entropy_array);
    % % % % Display the calculated sample entropy for each segment
    % % % disp('Sample Entropy for each segment:');
    % % % disp(sampen_cell);
    % %
    % Convert cell array to numeric array
    sampen_values = cellfun(@double, sampen_cell);
    % % % Display the sample entropy values in a single row
    % % disp('Sample Entropy for each segment:');
    % % disp(sampen_values);


    % Display Shannon Entropy for each segment
    fprintf('Shannon Entropy for each segment:\n');
    fprintf('%.3f    ', shannon_entropy_array);
    fprintf('\n');

    % Display Sample Entropy for each segment
    fprintf('Sample Entropy for each segment:\n');
    fprintf('%.3f    ', sampen_values);
    fprintf('\n');

    % Construct output filename
    output_filename = sprintf('shannon_sample_entropy_m-3_r-0-2stdvf%02d.csv', file_num);
    full_output_path = fullfile(base_output_path, output_filename);

    % Save in csv file
    fileID = fopen(full_output_path, 'w'); % Overwrite existing file
    % fprintf(fileID, 'Shannon_Entropy,Sample_Entropy\n'); % Add a header row
    fclose(fileID);
    dlmwrite(full_output_path, [shannon_entropy_array', sampen_values'], '-append', 'precision', '%.3f', 'delimiter', ',');
end

% % Save in csv file
% name = ('shannon_sample_entropy_cu01.csv');
% fileID = fopen(name, 'w');
% % fprintf(fileID, 'heart_rates,RR_intervals_seconds_all\n');
% fclose(fileID);
% dlmwrite(name, [shannon_entropy_array', sampen_values'], '-append', 'precision', '%.3f', 'delimiter', ',');