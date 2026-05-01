function hist_out = Update_Histogram(hist_in, phases, values, phase_edges, mag_edges)
    hist_out = hist_in;
    
    if isempty(phases)
        return;
    end
    
    phase_idx = discretize(phases, phase_edges);
    mag_idx = discretize(values, mag_edges);
    
    valid = ~isnan(phase_idx) & ~isnan(mag_idx);
    phase_idx = phase_idx(valid);
    mag_idx = mag_idx(valid);
    
    if isempty(phase_idx)
        return;
    end
    
    for i = 1:length(phase_idx)
        hist_out(mag_idx(i), phase_idx(i)) = hist_out(mag_idx(i), phase_idx(i)) + 1;
    end
end