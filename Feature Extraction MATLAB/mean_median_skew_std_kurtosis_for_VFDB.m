clc;
clear all;
close all;

% Base file path for input and output files
base_input_path = "D:\Capstone\Databases\VFDB_mat_files\";
base_output_path = "D:\Capstone\MatLab\Final codes\VFDB\skewness_std_dev_kurtosis\";

for file_num = 418:439
    % Construct input filename
    input_filename = sprintf('%02dm.mat', file_num);
    full_input_path = fullfile(base_input_path, input_filename);

    % Load the .mat file
    load(full_input_path);

    val = (val-0)/200;
    Fs=250;
    % Bandpass filter to remove noise
    f_low = 0.5; % Hz
    f_high = 45; % Hz
    [b, a] = butter (3, [f_low, f_high]/ (Fs/2), 'bandpass') ;
    filtered_signal = filtfilt(b, a, val);


    ecg_signal = filtered_signal(:);

    % Sample rate (Hz)
    fs = 250;
    %% % Initialize arrays to store heart rates and RR intervals
    % Segment length in seconds
    segment_length = 5;
    % Calculate the number of samples per segment
    samples_per_segment = fs * segment_length;

    % Calculate the total number of segments
    total_segments = floor(length(ecg_signal) / samples_per_segment);

    % Initialize a cell array to store the segmented signals
    segmented_signals = cell(1, total_segments);

    % Segment the ECG signal
    for i = 1:total_segments
        start_index = (i - 1) * samples_per_segment + 1;
        end_index = i * samples_per_segment;
        segmented_signals{i} = ecg_signal(start_index:end_index);
    end

    %% Mean, Median, skewness kurtosis, standard deviation

    %  'val' contains segmented signals
    % 'fs' is the sampling frequency of  signal
    % 'num_segments' is the number of segments previously defined
    num_segments = length(segmented_signals);
    % Initialize arrays to store features for each segment
    % % mean_array = zeros(1, num_segments);
    % median_array = zeros(1, num_segments);
    skewness_array = zeros(1, num_segments);
    kurtosis_array = zeros(1, num_segments);
    std_dev_array = zeros(1, num_segments);

    % Iterate over each segment
    for i = 1:num_segments
        % Extract the current segment
        current_segment = segmented_signals{i};

        % Calculate mean
        % mean_array(i) = mean(current_segment);

        % Calculate median
        % median_array(i) = median(current_segment);

        % Calculate skewness
        skewness_array(i) = skewness(current_segment);

        % Calculate kurtosis
        kurtosis_array(i) = kurtosis(current_segment);

        % Calculate standard deviation
        std_dev_array(i) = std(current_segment);
    end

    % Displaying the features
    % disp(['Mean for each segment: ' num2str(mean_array)]);
    % disp(['Median for each segment: ' num2str(round(median_array,3))]);
    disp(['Skewness for each segment: ' num2str(round(skewness_array,3))]);
    disp(['Kurtosis for each segment: ' num2str(round(kurtosis_array,2))]);
    disp(['Standard Deviation for each segment: ' num2str(round(std_dev_array,3))]);

    % Construct output filename
    output_filename = sprintf('skew_kurt_std_vf%02d.csv', file_num);
    full_output_path = fullfile(base_output_path, output_filename);

    % Save in csv file
    fileID = fopen(full_output_path, 'w'); % Overwrite existing file
    % fprintf(fileID, 'Shannon_Entropy,Sample_Entropy\n'); % Add a header row
    fclose(fileID);
    dlmwrite(full_output_path, [skewness_array', kurtosis_array', std_dev_array'], '-append', 'precision', '%.4f', 'delimiter', ',');
end