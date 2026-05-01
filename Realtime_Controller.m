function Realtime_Controller(data_folder,data_fs, ref_Phasefile, ref_fs, peak_threshold, ref_channel_number)
% Filename: Realtime_Controller 
% Author: Naledi Majake 
% Student ID: 11138055 
% Date: 29 April 2026

% Function which organises the execution of other functions as well as the real time plotting 
    
    % Get files
    file_list = dir(fullfile(data_folder, '*.csv'));
    num_files = length(file_list);

    % MATLAB setup
    fprintf('\n🚀 REAL-TIME PRPD SIMULATOR \n');
    fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    fprintf('Data folder: %s (%d files)\n', data_folder, num_files);
    fprintf('Sampling frequency for ref file and data folder: %d and %d Hz\n', ref_fs, data_fs);
    fprintf('Peak threshold: %.6f\n', peak_threshold);
    
    % --- STEP 1: Find fundamental frequency for the data folder and reference file---
    % Data folder fundamental frequency
    first_file = fullfile(data_folder, file_list(1).name); 
    fprintf('\n Finding fundamental frequency for data folder...\n');
    f0 = Discrete_FFT(first_file, data_fs, 5);  
    fprintf('    f0 = %.2f Hz\n', f0);

    % Reference folder fundamental frequency 
    f0_ref = Discrete_FFT(ref_Phasefile, ref_fs,3); 
    fprintf('\n Finding fundamental frequency for reference folder...\n');
    fprintf('   f0 = %.2f Hz\n', f0_ref);
    
    % --- STEP 2: Get phase angles ---
    fprintf('\n Determining phase relationships...\n');
    [phase_B_angle, phase_C_angle] = Phase_Relationship(ref_Phasefile, ref_fs, f0_ref);
    
    fprintf('\n Phase Mapping:\n');
    fprintf('   Channel 2 (Phase A): 0°\n');
    fprintf('   Channel 3 (Phase B): %d°\n', phase_B_angle);
    fprintf('   Channel 4 (Phase C): %d°\n', phase_C_angle);
    
    % --- STEP 3: Set bin resolution ----- 
    phase_bin_width = 5;      % 5° bins (72 total)
    mag_bin_width = 0.0002;   % 0.2mV resolution
    
    phase_edges = 0:phase_bin_width:360;
    mag_edges = 0:mag_bin_width:0.05;    % 0 to 0.05V range
    
    n_phase_bins = length(phase_edges) - 1;
    n_mag_bins = length(mag_edges) - 1;
    
    % Initialize histograms
    hist_A = zeros(n_mag_bins, n_phase_bins, 'double');
    hist_B = zeros(n_mag_bins, n_phase_bins, 'double');
    hist_C = zeros(n_mag_bins, n_phase_bins, 'double');
    
    fprintf('\n BIN SETTINGS:\n');
    fprintf('   Phase: %.1f° bins (%d total)\n', phase_bin_width, n_phase_bins);
    fprintf('   Magnitude: %.4fV bins (%d total)\n', mag_bin_width, n_mag_bins);
    fprintf('   Magnitude range: 0 to %.3fV\n', mag_edges(end));
    
    total_A = 0;
    total_B = 0;
    total_C = 0;
    
    % --- STEP 4: Create figure ---
    fprintf('\n Creating PRPD figure...\n');
    figure('Position', [50, 50, 1800, 600], 'Name', 'PRPD Analysis - 3 Phase', 'Color', 'white');
    
    % Custom jet colormap with white for zero
    cmap_jet = jet(256);
    cmap_jet(1, :) = [1 1 1];
    
    % FIXED COLORBAR MAX
    FIXED_MAX = 1000; 
    
    % Create sine wave: centered at 0.01V, range 0V to 0.02V
    phase_deg_sine = 0:1:360;
    sine_wave_signal = 0.01 + 0.01 * sin(deg2rad(phase_deg_sine));  % 0 to 0.02V
    
    % Initialize all three subplots
    for ch = 1:3
        subplot(1,3,ch);
        imagesc(phase_edges(1:end-1), mag_edges(1:end-1), zeros(n_mag_bins, n_phase_bins));
        hold on;
        plot(phase_deg_sine, sine_wave_signal, 'k-', 'LineWidth', 1.5);
        hold off;
        axis xy;
        xlabel('Phase (degrees)', 'FontSize', 12);
        ylabel('Magnitude (V)', 'FontSize', 12);
        colorbar;
        xlim([0, 360]);
        ylim([0, 0.05]);
        caxis([0, FIXED_MAX]);
        colormap(gca, cmap_jet);
        set(gca, 'FontSize', 10, 'Color', 'white');
        grid on;
        set(gca, 'GridAlpha', 0.4, 'GridColor', [0.7 0.7 0.7]);
    end
    
    subplot(1,3,1); title('Phase A (0°) - Initializing...', 'FontSize', 12, 'FontWeight', 'bold');
    subplot(1,3,2); title(sprintf('Phase B (%d°) - Initializing...', phase_B_angle), 'FontSize', 12, 'FontWeight', 'bold');
    subplot(1,3,3); title(sprintf('Phase C (%d°) - Initializing...', phase_C_angle), 'FontSize', 12, 'FontWeight', 'bold');
    sgtitle('PRPD Analysis - Loading...', 'FontSize', 14, 'FontWeight', 'bold');
    drawnow;
    
    % Save INITIAL figures
    Save_PRPD_Figures(hist_A, hist_B, hist_C, phase_edges, mag_edges, 0, 0, 0, phase_B_angle, phase_C_angle, 'initial', f0, FIXED_MAX);
    
    % --- STEP 5: Process all files ---
    fprintf('\n⚙️  Processing %d files...\n', num_files);
    fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    t_start = tic;
    
    for i = 1:num_files
        filename = fullfile(data_folder, file_list(i).name);
        
        % Read file once
        data = readmatrix(filename, 'NumHeaderLines', 1);
        
        % Compute phase reference once
        vref_signal = data(:, 5);
        filtered_vref = Filtering(vref_signal, f0, data_fs, 0);

        phase_for_every_sample = Phase_Corrected(filtered_vref);
        
        % Process Channel 2 (Phase A)
        PD_signal_A = data(:, 2);
        if max(PD_signal_A) >= peak_threshold
            [p_vals_A, locs_A] = findpeaks(PD_signal_A, 'MinPeakHeight', peak_threshold);
            p_ph_A = phase_for_every_sample(locs_A);
        else
            p_ph_A = [];
            p_vals_A = [];
        end
        
        % Process Channel 3 (Phase B)
        PD_signal_B = data(:, 3);
        if max(PD_signal_B) >= peak_threshold
            [p_vals_B, locs_B] = findpeaks(PD_signal_B, 'MinPeakHeight', peak_threshold);
            phase_B_shifted = mod(phase_for_every_sample + phase_B_angle, 360);
            p_ph_B = phase_B_shifted(locs_B);
        else
            p_ph_B = [];
            p_vals_B = [];
        end
        
        % Process Channel 4 (Phase C)
        PD_signal_C = data(:, 4);
        if max(PD_signal_C) >= peak_threshold
            [p_vals_C, locs_C] = findpeaks(PD_signal_C, 'MinPeakHeight', peak_threshold);
            phase_C_shifted = mod(phase_for_every_sample + phase_C_angle, 360);
            p_ph_C = phase_C_shifted(locs_C);
        else
            p_ph_C = [];
            p_vals_C = [];
        end
        
        % Update histograms
        hist_A = Update_Histogram(hist_A, p_ph_A, p_vals_A, phase_edges, mag_edges);
        hist_B = Update_Histogram(hist_B, p_ph_B, p_vals_B, phase_edges, mag_edges);
        hist_C = Update_Histogram(hist_C, p_ph_C, p_vals_C, phase_edges, mag_edges);
        
        total_A = total_A + length(p_vals_A);
        total_B = total_B + length(p_vals_B);
        total_C = total_C + length(p_vals_C);
        
        % Update display every file
        % Phase A
        subplot(1,3,1);
        cla;
        imagesc(phase_edges(1:end-1), mag_edges(1:end-1), hist_A, 'AlphaData', double(hist_A > 0));
        hold on;
        plot(phase_deg_sine, sine_wave_signal, 'k-', 'LineWidth', 1.5);
        hold off;
        axis xy;
        xlabel('Phase (degrees)', 'FontSize', 12);
        ylabel('Magnitude (V)', 'FontSize', 12);
        title(sprintf('Phase A (0°) - %d peaks', total_A), 'FontSize', 12, 'FontWeight', 'bold');
        colorbar;
        xlim([0, 360]);
        ylim([0, 0.05]);
        caxis([0, FIXED_MAX]);
        colormap(gca, cmap_jet);
        set(gca, 'FontSize', 10, 'Color', 'white');
        grid on;
        set(gca, 'GridAlpha', 0.4, 'GridColor', [0.7 0.7 0.7]);
        
        % Phase B
        subplot(1,3,2);
        cla;
        imagesc(phase_edges(1:end-1), mag_edges(1:end-1), hist_B, 'AlphaData', double(hist_B > 0));
        hold on;
        plot(phase_deg_sine, sine_wave_signal, 'k-', 'LineWidth', 1.5);
        hold off;
        axis xy;
        xlabel('Phase (degrees)', 'FontSize', 12);
        ylabel('Magnitude (V)', 'FontSize', 12);
        title(sprintf('Phase B (%d°) - %d peaks', phase_B_angle, total_B), 'FontSize', 12, 'FontWeight', 'bold');
        colorbar;
        xlim([0, 360]);
        ylim([0, 0.05]);
        caxis([0, FIXED_MAX]);
        colormap(gca, cmap_jet);
        set(gca, 'FontSize', 10, 'Color', 'white');
        grid on;
        set(gca, 'GridAlpha', 0.4, 'GridColor', [0.7 0.7 0.7]);
        
        % Phase C
        subplot(1,3,3);
        cla;
        imagesc(phase_edges(1:end-1), mag_edges(1:end-1), hist_C, 'AlphaData', double(hist_C > 0));
        hold on;
        plot(phase_deg_sine, sine_wave_signal, 'k-', 'LineWidth', 1.5);
        hold off;
        axis xy;
        xlabel('Phase (degrees)', 'FontSize', 12);
        ylabel('Magnitude (V)', 'FontSize', 12);
        title(sprintf('Phase C (%d°) - %d peaks', phase_C_angle, total_C), 'FontSize', 12, 'FontWeight', 'bold');
        colorbar;
        xlim([0, 360]);
        ylim([0, 0.05]);
        caxis([0, FIXED_MAX]);
        colormap(gca, cmap_jet);
        set(gca, 'FontSize', 10, 'Color', 'white');
        grid on;
        set(gca, 'GridAlpha', 0.4, 'GridColor', [0.7 0.7 0.7]);
        
        % Main title - 
        sgtitle(sprintf('PRPD Analysis - File %d/%d (%.1f%%) | f₀ = %.2f Hz', i, num_files, 100*i/num_files, f0),'FontSize', 14, 'FontWeight', 'bold');
        
        drawnow limitrate;
        
        % Progress report every 10 files
        if mod(i, 10) == 0 || i == num_files
            elapsed = toc(t_start);
            fprintf(' %3d/%d | A:%-7d B:%-7d C:%-7d | %5.1f%% | Time: %.1f sec\n', i, num_files, total_A, total_B, total_C, 100*i/num_files, elapsed);
        end
    end
    
    fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    fprintf('\n SIMULATION COMPLETE!\n');
    fprintf('️  Total time: %.1f seconds (%.1f minutes)\n', toc(t_start), toc(t_start)/60);
    
    fprintf('\n FINAL PEAK COUNTS:\n');
    fprintf('   ┌─────────────────────────────────────────────┐\n');
    fprintf('   │ Phase A (0°):     %10d peaks                │\n', total_A);
    fprintf('   │ Phase B (%d°):  %10d peaks                │\n', phase_B_angle, total_B);
    fprintf('   │ Phase C (%d°):  %10d peaks                │\n', phase_C_angle, total_C);
    fprintf('   ├─────────────────────────────────────────────┤\n');
    fprintf('   │ TOTAL:           %10d peaks (%.2f M)       │\n', total_A+total_B+total_C, (total_A+total_B+total_C)/1e6);
    fprintf('   └─────────────────────────────────────────────┘\n');
    
    % Save FINAL figures
    Save_PRPD_Figures(hist_A, hist_B, hist_C, phase_edges, mag_edges, total_A, total_B, total_C, phase_B_angle, phase_C_angle, 'final', f0, FIXED_MAX);
    
    % Save final figure
    saveas(gcf, 'PRPD_Final_Heatmap.png');
    fprintf('\n Final figure saved: PRPD_Final_Heatmap.png\n');
end

