function fixedpoint_log_calc(x)
    % Set fimath properties for fixed-point arithmetic
    f = fimath('OverflowAction', 'Wrap', 'RoundingMethod', 'Floor');
    
    % Define numeric types
    Q32_16 = numerictype(1, 32, 16);
    Q18_15 = numerictype(1, 18, 15);
    Q18_13 = numerictype(1, 18, 13);
    Q18_10 = numerictype(1, 18, 10);
    
    % Convert input to fixed-point
    x_fi = fi(x, Q32_16, f);
    Nx = x_fi.WordLength;
    Fx = x_fi.FractionLength;
    
    % LUT ROM parameters
    n = 6; % LUT ROM resolution
    L = 2^n; % LUT ROM length
    LUT = fi(log2(1 + (0:(L-1))/L), Q18_13, f); % LUT ROM
    
    % Leading One Detector (LOD)
    m = find(x_fi.bin == '1'); % Find position of the first '1'
    
    % LUT ROM address calculation
    if numel(m) >= n
        a = bin2dec(x_fi.bin(m(1)+1:m(1)+n)); % Extract bits for LUT address
    else
        a = 0; % Default address if insufficient bits
    end
    
    % Fixed-point calculations
    S = fi(Nx - Fx - m(1), Q18_13, f);
    F = LUT(a + 1);
    temp = fi(3.0103, Q18_15, f) * fi((S + F), Q18_13, f);
    hardware_result = fi(temp, Q18_10, f);
    
    % Golden reference calculation
    golden_result = 10 * log10(x);
    
    % Display results
    disp(['hardware = ' num2str(hardware_result.data)]);
    disp(['golden = ' num2str(golden_result)]);
end
