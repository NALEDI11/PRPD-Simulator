function fundamental_freq = Discrete_FFT(phase_filename, Fs, i)

    % MATLAB: Fast Fourier Transform 
    % This function has been created to conduct an FFT to find the fundamental
    % frequency of the data which will be used as the cut off frequency of the
    % filter. 
    % This function is only used during the initialisation stage looking
    % The arguments of this function is: Filename and Sampling frequency (Fs)

    signal = readmatrix(phase_filename); 
    time = signal(:,1);
    voltage = signal(:,i); 

    Fs = double(Fs); % This must be changed to a double

    % Set FFT parameters 
    T = 1/Fs; 
    L = length(time); 
    t = (0:L-1)*T; 

    % Compute FFT 
    Y = fft(voltage); 

    % Compute frequency axis
    f = Fs * (0:L/2)/L; 

    % Calculate the magnitude 
    P2 = abs(Y/L);                         % Normalise the magnitude column.
    P1 = P2(1:L/2+1);                      % Remove negative freuquencies as they add no additional information
    P1(2:end-1) = 2*P1(2:end-1);           % As the negative frequencies are removed, the energy of the negative frequencies needs to be included - related to Parseval's Theorem. 
    
    [~, max_frequency] = max(P1);          % Find the index of the maximum value 
    fundamental_freq = f(max_frequency);   % Find the value of the at that specific index
    
    % Plot FFT 
    semilogx(f,P1); 
    grid on;
    
    % plot(f, P1);
    title("Fast Fourier Transform"); 
    xlabel('Frequency (Hz)'); 
    ylabel('Magnitude');
    
    grid off;

end 
