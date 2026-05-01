function Save_PRPD_Figures(hist_A, hist_B, hist_C, phase_edges, mag_edges, ...
                           total_A, total_B, total_C, phase_B_angle, phase_C_angle, ...
                           stage, f0, fixed_max)
    
    cmap_jet = jet(256);
    cmap_jet(1, :) = [1 1 1];
    
    % Sine wave: centered at 0.01V, range 0V to 0.02V
    phase_deg_sine = 0:1:360;
    sine_wave_signal = 0.01 + 0.01 * sin(deg2rad(phase_deg_sine));
    
    if ~exist('PRPD_Figures', 'dir')
        mkdir('PRPD_Figures');
    end
    
    % Phase A
    fig_A = figure('Visible', 'off', 'Position', [100, 100, 800, 600], 'Color', 'white');
    imagesc(phase_edges(1:end-1), mag_edges(1:end-1), hist_A, 'AlphaData', double(hist_A > 0));
    hold on;
    plot(phase_deg_sine, sine_wave_signal, 'k-', 'LineWidth', 1.5);
    hold off;
    axis xy;
    xlabel('Phase (degrees)', 'FontSize', 14);
    ylabel('Magnitude (V)', 'FontSize', 14);
    title(sprintf('Phase A (0°) - %s: %d peaks', stage, total_A), 'FontSize', 14, 'FontWeight', 'bold');
    colorbar;
    xlim([0, 360]);
    ylim([0, 0.05]);
    caxis([0, fixed_max]);
    colormap(gca, cmap_jet);
    set(gca, 'FontSize', 12);
    grid on;
    
    filename_A = sprintf('PRPD_Figures/Phase_A_%s.eps', stage);
    print(fig_A, filename_A, '-depsc', '-r300');
    fprintf('💾 Saved: %s\n', filename_A);
    close(fig_A);
    
    % Phase B
    fig_B = figure('Visible', 'off', 'Position', [100, 100, 800, 600], 'Color', 'white');
    imagesc(phase_edges(1:end-1), mag_edges(1:end-1), hist_B, 'AlphaData', double(hist_B > 0));
    hold on;
    plot(phase_deg_sine, sine_wave_signal, 'k-', 'LineWidth', 1.5);
    hold off;
    axis xy;
    xlabel('Phase (degrees)', 'FontSize', 14);
    ylabel('Magnitude (V)', 'FontSize', 14);
    title(sprintf('Phase B (%d°) - %s: %d peaks', phase_B_angle, stage, total_B), 'FontSize', 14, 'FontWeight', 'bold');
    colorbar;
    xlim([0, 360]);
    ylim([0, 0.05]);
    caxis([0, fixed_max]);
    colormap(gca, cmap_jet);
    set(gca, 'FontSize', 12);
    grid on;
    
    filename_B = sprintf('PRPD_Figures/Phase_B_%s.eps', stage);
    print(fig_B, filename_B, '-depsc', '-r300');
    fprintf('💾 Saved: %s\n', filename_B);
    close(fig_B);
    
    % Phase C
    fig_C = figure('Visible', 'off', 'Position', [100, 100, 800, 600], 'Color', 'white');
    imagesc(phase_edges(1:end-1), mag_edges(1:end-1), hist_C, 'AlphaData', double(hist_C > 0));
    hold on;
    plot(phase_deg_sine, sine_wave_signal, 'k-', 'LineWidth', 1.5);
    hold off;
    axis xy;
    xlabel('Phase (degrees)', 'FontSize', 14);
    ylabel('Magnitude (V)', 'FontSize', 14);
    title(sprintf('Phase C (%d°) - %s: %d peaks', phase_C_angle, stage, total_C), 'FontSize', 14, 'FontWeight', 'bold');
    colorbar;
    xlim([0, 360]);
    ylim([0, 0.05]);
    caxis([0, fixed_max]);
    colormap(gca, cmap_jet);
    set(gca, 'FontSize', 12);
    grid on;
    
    filename_C = sprintf('PRPD_Figures/Phase_C_%s.eps', stage);
    print(fig_C, filename_C, '-depsc', '-r300');
    fprintf('💾 Saved: %s\n', filename_C);
    close(fig_C);
    
    % Combined figure
    fig_combined = figure('Visible', 'off', 'Position', [100, 100, 1800, 600], 'Color', 'white');
    
    subplot(1,3,1);
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
    caxis([0, fixed_max]);
    colormap(gca, cmap_jet);
    grid on;
    
    subplot(1,3,2);
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
    caxis([0, fixed_max]);
    colormap(gca, cmap_jet);
    grid on;
    
    subplot(1,3,3);
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
    caxis([0, fixed_max]);
    colormap(gca, cmap_jet);
    grid on;
    
    sgtitle(sprintf('PRPD Analysis - %s Stage (f₀ = %.2f Hz)', stage, f0), 'FontSize', 16, 'FontWeight', 'bold');
    
    filename_combined = sprintf('PRPD_Figures/All_Phases_%s.eps', stage);
    print(fig_combined, filename_combined, '-depsc', '-r300');
    fprintf('💾 Saved: %s\n', filename_combined);
    
    filename_combined_png = sprintf('PRPD_Figures/All_Phases_%s.png', stage);
    saveas(fig_combined, filename_combined_png);
    fprintf('💾 Saved: %s\n', filename_combined_png);
    
    close(fig_combined);
end