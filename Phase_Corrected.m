function phase_corrected = Phase_Corrected(filtered_voltage)
    % Time to phase converter, time instants to phase angles 
    % time: time vector from data file column 1 
    % filtered votlage: the filtered voltage signal 
    % return: phase angles in degrees (0-360) for each sample

    % Find positive peaks (90°)
    positive_peaks = [];
    for i = 2:length(filtered_voltage)-1 % check values which are not the first or last
        if (filtered_voltage(i) > filtered_voltage(i-1)) && (filtered_voltage(i) > filtered_voltage(i+1)) && filtered_voltage(i) > 0
            positive_peaks = [positive_peaks, i]; % append positive peak index to the positive peaks array 
        end
    end
    
    % Find negative peaks (270°)
    negative_peaks = [];
    for i = 2:length(filtered_voltage)-1
        if (filtered_voltage(i) < filtered_voltage(i-1)) && (filtered_voltage(i) < filtered_voltage(i+1)) && filtered_voltage(i) < 0
            negative_peaks = [negative_peaks, i];
        end
    end
    
    % Find zero crossings
    zero_crossings_rising = [];  % 0°
    zero_crossings_falling = []; % 180°
    
    for i = 2:length(filtered_voltage)
        if filtered_voltage(i-1) < 0 && filtered_voltage(i) >= 0 
            zero_crossings_rising = [zero_crossings_rising, i];
        elseif filtered_voltage(i-1) > 0 && filtered_voltage(i) <= 0
            zero_crossings_falling = [zero_crossings_falling, i];
        end
    end
    
    % Create corrected phase mapping 
    phase_corrected = zeros(size(filtered_voltage));
    
    % Combine all key points and sort them
    all_key_points = sort([positive_peaks, negative_peaks, zero_crossings_rising, zero_crossings_falling]);
    
    % Assign phase values to key points
    key_phases = zeros(size(all_key_points));
    
    for i = 1:length(all_key_points) % 'i' represents the index of the key phase vectors
        idx = all_key_points(i);     % 'idx' represents the index of the filtered voltage vector
       
        % This algorithm gives each key value a phase value
        if ismember(idx, positive_peaks) 
            key_phases(i) = 90;       % Positive peak = 90°
        elseif ismember(idx, negative_peaks)
            key_phases(i) = 270;      % Negative peak = 270°
        elseif ismember(idx, zero_crossings_rising)
            key_phases(i) = 0;        % Rising zero crossing = 0°
        elseif ismember(idx, zero_crossings_falling)
            key_phases(i) = 180;      % Falling zero crossing = 180°
        end
    end
    
    % Linearly interpolate phase between key points
    for i = 1:length(all_key_points)-1
        start_idx = all_key_points(i);
        end_idx = all_key_points(i+1);
        start_phase = key_phases(i);
        end_phase = key_phases(i+1);
        
        % Handle phase wrap-around (360° to 0°)
        if end_phase < start_phase
            end_phase = end_phase + 360;
        end
        
        num_samples = end_idx - start_idx + 1;
        phase_corrected(start_idx:end_idx) = linspace(start_phase, end_phase, num_samples);
    end
    
    % Wrap phases to 0-360 range
    phase_corrected = mod(phase_corrected, 360);

end