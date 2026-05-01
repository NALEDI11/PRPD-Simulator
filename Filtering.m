function filtered_voltage = Filtering(phase_filename, fundamental_freq, Fs, i)
    % MATLAB: Low pass filter 
    % This function removes all unwanted frequencies from the waveforms and 
    % keeps only the fundamental frequency.
    %
    % Inputs:
    %   phase_filename - either a filename (string) when i>0, OR a signal vector when i=0
    %   fundamental_freq - fundamental frequency (Hz)
    %   Fs - sampling frequency (Hz)
    %   i - column index (if i=0, phase_filename is treated as the raw signal)
    
    % Get the voltage signal based on i
    if i == 0
        % phase_filename is the raw signal vector
        voltage = phase_filename;
    else
        % phase_filename is a filename, read the specified column
        data = readmatrix(phase_filename);
        voltage = data(:, i);
    end
   
    % Design and apply the filter
    cutoff_freq = 3 * fundamental_freq; % 3*F
    normalised_cutoff = cutoff_freq / (Fs/2);

    if normalised_cutoff < 4.22e-5
        % Use 1st order filter for very low cutoff frequencies
        [b, a] = butter(1, normalised_cutoff, 'low');
  
    else 
        % Use 4th order filter for normal cutoff frequencies
        [b, a] = butter(4, normalised_cutoff, 'low');
    end
    
    filtered_voltage = filtfilt(b, a, voltage);

end