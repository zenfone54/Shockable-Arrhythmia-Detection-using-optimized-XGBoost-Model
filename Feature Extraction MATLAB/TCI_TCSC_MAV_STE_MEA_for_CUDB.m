clear all
close all
clc
% Base file path for input and output files
base_input_path = "D:\Capstone\Databases\CUDB_mat_files\";
base_output_path = "D:\Capstone\MatLab\Final codes\CUDB\TCI_TCSC_STE_MAV_MEA\";

for file_num = 1:35
    % Construct input filename
    input_filename = sprintf('cu%02dm.mat', file_num);
    full_input_path = fullfile(base_input_path, input_filename);

    % Load the .mat file
    load(full_input_path);
    val = (val-0)/400;
    Fs=250;
    % Bandpass filter to remove noise
    f_low = 0.5; % Hz
    f_high = 45; % Hz
    [b, a] = butter (3, [f_low, f_high]/ (Fs/2), 'bandpass') ;
    filtered_signal = filtfilt(b, a, val);


    ecg_signal = filtered_signal(:);

    % Sample rate (Hz)
    fs = 250;
    %% 
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

    %% features of TCI, TCSC, MAV, STE, MEA
    %  'val' contains segmented signals
    % 'fs' is the sampling frequency of  signal
    % 'num_segments' is the number of segments previously defined
    num_segments = length(segmented_signals);
    % Initialize arrays to store features for each segment
    tci_array = zeros(1, num_segments);
    tcsc_array = zeros(1, num_segments);
    mav_array = zeros(1, num_segments);
    ste_array = zeros(1, num_segments);
    mea_array = zeros(1, num_segments);

    % Iterate over each segment
    for i = 1:num_segments
        % Extract the current segment
        current_segment = ecg_signal((i-1)*fs*5 + 1 : i*fs*5);
        %current_segment = segmented_signals{i};

        % Calculate threshold crossing interval (TCI)
        threshold = 0.2 * max(abs(current_segment));  %  20% threshold
        crossings = find(diff(sign(current_segment - threshold)) == 2);
        tci_array(i) = mean(diff(crossings) / fs); % Average TCI in seconds

        % Calculate threshold crossing sample count (TCSC)
        tcsc_array(i) = length(crossings);

        % Calculate mean absolute value (MAV)
        mav_array(i) = mean(abs(current_segment));

        % Calculate standard exponential (STE)
        ste_array(i) = sum(exp(abs(current_segment) / max(abs(current_segment))));

        % Calculate modified exponential (MEA)
        mea_array(i) = sum(exp(abs(current_segment).^2 / max(abs(current_segment).^2)));
    end

    % Displaying the features
    %disp(['TCI for each segment: ' num2str(round(tci_array, 3))]);
    disp(['TCSC for each segment: ' num2str(tcsc_array)]);
    disp(['MAV for each segment: ' num2str(round(mav_array, 3))]);
    disp(['STE for each segment: ' num2str(round(ste_array))]);
    disp(['MEA for each segment: ' num2str(round(mea_array))]);

    % Construct output filename
    output_filename = sprintf('TCSC_MAV_STE_MEA_cu%02d.csv', file_num);
    full_output_path = fullfile(base_output_path, output_filename);

    % Save in csv file
    fileID = fopen(full_output_path, 'w'); % Overwrite existing file
    % fprintf(fileID, 'Shannon_Entropy,Sample_Entropy\n'); % Add a header row
    fclose(fileID);
    dlmwrite(full_output_path, [tcsc_array', mav_array', ste_array', mea_array'], '-append', 'precision', '%.3f', 'delimiter', ',');
end

% % Save in csv file
% name = ('TCI_TSCS_MAV_STE_MEA_cu35.csv');
% fileID = fopen(name, 'w');
% % fprintf(fileID, 'heart_rates,RR_intervals_seconds_all\n');
% fclose(fileID);
% dlmwrite(name, [tci_array', tcsc_array', mav_array', ste_array', mea_array'], '-append', 'precision', '%.3f', 'delimiter', ',');

%{
% Display the computed feature values for each segment
disp('Segment-wise Feature Values:');
disp('Segment   TCI    TCSC   MAV    STE    MEA');
for i = 1:total_segments
    fprintf('%8d %8.4f %8d %8.4f %8.4f %8.4f\n', i, tci_array(i), tcsc_array(i), mav_array(i), ste_array(i), mea_array(i));
end
%}