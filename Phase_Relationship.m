function [phase_B_angle, phase_C_angle] = Phase_Relationship(filename, fs, f0)
% FINAL_PHASE_RELATIONSHIP Returns phase differences rounded to nearest 120°

    fprintf('\n🔍 Phase Relationship Analysis\n');
    fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    fprintf('File: %s\n', filename);
    
    % Load data
    data = readmatrix(filename);
    time = data(:,1);
    n_samples = size(data, 1);
    mid_point = round(n_samples / 2);
    
    fprintf('Using raw data for phase detection (reference file should be clean)\n');
    
    % Process Channel 1
    fprintf('Processing Channel 1...\n');
    filtered_1 = Filtering(filename, f0, fs, 2);  
    phase_1 = Phase_Corrected(filtered_1);  
    phase_1_mid = phase_1(mid_point);
    fprintf('   Phase at middle: %.2f°\n', phase_1_mid);
    
    % Process Channel 2
    fprintf('\nProcessing Channel 2...\n');
    filtered_2 = Filtering(filename, f0, fs, 3); 
    phase_2 = Phase_Corrected(filtered_2);
    phase_2_mid = phase_2(mid_point);
    raw_diff_2 = mod(phase_2_mid - phase_1_mid, 360);
    fprintf('   Phase at middle: %.2f°\n', phase_2_mid);
    fprintf('   Raw difference from Ch1: %.2f°\n', raw_diff_2);
    
    % Process Channel 3
    fprintf('\nProcessing Channel 3...\n');
    filtered_3 = Filtering(filename, f0, fs, 4); 
    phase_3 = Phase_Corrected(filtered_3);
    phase_3_mid = phase_3(mid_point);
    raw_diff_3 = mod(phase_3_mid - phase_1_mid, 360);
    fprintf('   Phase at middle: %.2f°\n', phase_3_mid);
    fprintf('   Raw difference from Ch1: %.2f°\n', raw_diff_3);
    
    % Round to nearest 120°
    possible_angles = [0, 120, 240];
    
    [~, idx_2] = min(abs(raw_diff_2 - possible_angles));
    phase_B_angle = possible_angles(idx_2);
    
    [~, idx_3] = min(abs(raw_diff_3 - possible_angles));
    phase_C_angle = possible_angles(idx_3);
    
    % Summary
    fprintf('\n📊 RESULTS (rounded to nearest 120°)\n');
    fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    fprintf('Channel 1: 0° (reference)\n');
    fprintf('Channel 2: %d° from Ch1 (raw was %.1f°)\n', phase_B_angle, raw_diff_2);
    fprintf('Channel 3: %d° from Ch1 (raw was %.1f°)\n', phase_C_angle, raw_diff_3);
     
    % --- CREATE SUBPLOT: TOP = full signals, BOTTOM = zoomed ---

    % Create invisible figure
    fig_handle = figure('Visible', 'off', 'Position', [100, 100, 1200, 800]);

    % Calculate samples per cycle for zoom window
    samples_per_cycle = round(fs / f0);

    % ========== TOP PLOT: Full Filtered Voltages ==========
    subplot(2, 1, 1);

    plot(time, filtered_1, 'r-', 'LineWidth', 1.5); hold on;
    plot(time, filtered_2, 'g-', 'LineWidth', 1.5);
    plot(time, filtered_3, 'b-', 'LineWidth', 1.5);

    % Mark the middle point
    plot(time(mid_point), filtered_1(mid_point), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    plot(time(mid_point), filtered_2(mid_point), 'go', 'MarkerSize', 10, 'LineWidth', 2);
    plot(time(mid_point), filtered_3(mid_point), 'bo', 'MarkerSize', 10, 'LineWidth', 2);

    xlabel('Time (s)');
    ylabel('Voltage');
    title(sprintf('Filtered Voltages (Ch1=0°, Ch2=%d°, Ch3=%d°)', phase_B_angle, phase_C_angle));
    legend('Channel 1 (Ref)', 'Channel 2', 'Channel 3', 'Location', 'best');
    grid on;
    hold off;

    % ========== BOTTOM PLOT: Zoomed View (±2 cycles around middle) ==========
    subplot(2, 1, 2);

    % Zoom window: ±2 cycles around middle point
    zoom_window = 2 * samples_per_cycle;
    start_idx = max(1, mid_point - zoom_window);
    end_idx = min(n_samples, mid_point + zoom_window);

    plot(time(start_idx:end_idx), filtered_1(start_idx:end_idx), 'r-', 'LineWidth', 1.5); hold on;
    plot(time(start_idx:end_idx), filtered_2(start_idx:end_idx), 'g-', 'LineWidth', 1.5);
    plot(time(start_idx:end_idx), filtered_3(start_idx:end_idx), 'b-', 'LineWidth', 1.5);

    % Mark the middle point
    plot(time(mid_point), filtered_1(mid_point), 'ro', 'MarkerSize', 12, 'LineWidth', 2);
    plot(time(mid_point), filtered_2(mid_point), 'go', 'MarkerSize', 12, 'LineWidth', 2);
    plot(time(mid_point), filtered_3(mid_point), 'bo', 'MarkerSize', 12, 'LineWidth', 2);

    xlabel('Time (s)');
    ylabel('Voltage');
    title(sprintf('Zoomed View (±2 cycles around middle point, f₀ = %.2f Hz)', f0));
    legend('Channel 1 (Ref)', 'Channel 2', 'Channel 3', 'Location', 'best');
    grid on;
    hold off;

    % --- SAVE THE FIGURE ---

    % Save as EPS
    eps_filename = 'phase_relationship_plot.eps';
    print(fig_handle, eps_filename, '-depsc', '-r300');
    fprintf('\n✅ Phase relationship plot saved to: %s\n', eps_filename);

    % Save as PNG
    png_filename = 'phase_relationship_plot.png';
    saveas(fig_handle, png_filename);
    fprintf('✅ Also saved as PNG: %s\n', png_filename);

    % Close the invisible figure
    close(fig_handle);

    % Print phase mapping summary
    fprintf('\n📐 PHASE MAPPING SUMMARY:\n');
    fprintf('   Channel 1: Phase A (0°)\n');
    if phase_B_angle == 120
        fprintf('   Channel 2: Phase B (120°)\n');
        fprintf('   Channel 3: Phase C (240°)\n');
    elseif phase_B_angle == 240
        fprintf('   Channel 2: Phase C (240°)\n');
        fprintf('   Channel 3: Phase B (120°)\n');
    else
        fprintf('   Channel 2: %d° (unexpected)\n', phase_B_angle);
        fprintf('   Channel 3: %d° (unexpected)\n', phase_C_angle);
    end
    
end