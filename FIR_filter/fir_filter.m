function signal = generate_sinusoidal(frequency, amplitude, duration, sample_rate)
    t = 0:1/sample_rate:duration;
    signal = amplitude * sin(2 * pi * frequency * t);
end

function noisy_signal = add_noise(signal, noise_amplitude, noise_frequency, sample_rate)
    t = 0:1/sample_rate:(length(signal)-1)/sample_rate;
    noise = noise_amplitude * sin(2 * pi * noise_frequency * t);
    noisy_signal = signal + noise;
end

function b = design_fir_filter(cutoff_frequency, filter_order, sample_rate)
    nyquist_rate = sample_rate / 2;
    normalized_cutoff = cutoff_frequency / nyquist_rate;
    b = fir1(filter_order, normalized_cutoff);
end

function filtered_signal = apply_fir_filter(b, signal)
    filtered_signal = filter(b, 1, signal);
end

function int_data = convert_to_fixed_point(data, word_length, fraction_length)
    fixed_point_data = fi(data, true, word_length, fraction_length, 'RoundingMethod', 'Nearest', 'OverflowAction', 'Saturate');
    int_data = int16(fixed_point_data * 2^fraction_length); % Scale to integer
end

function save_to_file(filename, data)
    writematrix(data, filename, 'Delimiter', ',');
end


% Parameters
low_freq = 1; % Low frequency of sinusoidal signal (Hz)
amplitude = 1; % Amplitude of sinusoidal signal
duration = 5; % Duration of the signal (seconds)
sample_rate = 1000; % Sampling rate (Hz)

noise_amplitude = 0.5; % Amplitude of high-frequency noise
noise_frequency = 50; % Frequency of noise (Hz)

filter_order = 50; % Order of FIR filter
cutoff_frequency = 10; % Cutoff frequency of FIR filter (Hz)

word_length = 16; % Word length for fixed-point conversion
fraction_length = 14; % Fraction length for fixed-point conversion

% Generate low-frequency sinusoidal signal
signal = generate_sinusoidal(low_freq, amplitude, duration, sample_rate);

% Add high-frequency noise
noisy_signal = add_noise(signal, noise_amplitude, noise_frequency, sample_rate);

% Design FIR filter
b = design_fir_filter(cutoff_frequency, filter_order, sample_rate);

% Apply FIR filter to noisy signal
filtered_signal = apply_fir_filter(b, noisy_signal);

% Plot the results
t = 0:1/sample_rate:duration;

figure;
subplot(3, 1, 1);
plot(t, signal);
title('Original Low-Frequency Sinusoidal Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 2);
plot(t, noisy_signal);
title('Noisy Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 3);
plot(t, filtered_signal);
title('Filtered Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Convert data to fixed-point
fixed_point_signal = convert_to_fixed_point(signal, word_length, fraction_length);
fixed_point_noisy_signal = convert_to_fixed_point(noisy_signal, word_length, fraction_length);
fixed_point_filtered_signal = convert_to_fixed_point(filtered_signal, word_length, fraction_length);
fixed_point_coefficients = convert_to_fixed_point(b, word_length, fraction_length);

% Save data to files
save_to_file('input_signal.txt', fixed_point_noisy_signal);
save_to_file('output_signal.txt', fixed_point_filtered_signal);
save_to_file('filter_coefficients.txt', fixed_point_coefficients);