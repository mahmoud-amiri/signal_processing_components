function [inputSignal, outputSignal, coefficients] = readData(inputFile, outputFile, coeffFile)
    % Read input signal from file
    inputSignal = load(inputFile);
    
    % Read output signal from file
    outputSignal = load(outputFile);
    
    % Read coefficients from file
    coefficients = load(coeffFile);
end

function scaledInputSignal = scaleData(inputSignal, scalingFactor)
    % Scale input signal to real numbers
    scaledInputSignal = double(inputSignal) / 2^scalingFactor;
end


function filteredSignal = applyFIRFilter(inputSignal, coefficients)
    % Apply FIR filter using the given coefficients
    filteredSignal = filter(coefficients, 1, inputSignal);
end


function checkResult(filteredSignal, outputSignal)
    % Compare the filtered signal with the expected output signal
    difference = filteredSignal - outputSignal;
    
    % Calculate the mean squared error
    mse = mean(difference .^ 2);
    
    % Display the result
    if mse < 1e-8
        disp('The filtered signal matches the expected output signal.');
    else
        disp('The filtered signal does not match the expected output signal.');
        fprintf('Mean Squared Error: %g\n', mse);
    end

    subplot(3, 1, 1);
    plot(filteredSignal);
    title('filtered Signal');
    

    subplot(3, 1, 2);
    plot(outputSignal);
    title('Readed Signal');
    

    subplot(3, 1, 3);
    plot(difference);
    title('difference');
    
end




% Main script to read data, apply FIR filter, and check results

% Clear workspace and command window
clear;
clc;

% Define file names
inputFile = 'input_signal.txt';
outputFile = 'output_signal.txt';
coeffFile = 'filter_coefficients.txt';

% Read data from files
[inputSignal, outputSignal, coefficients] = readData(inputFile, outputFile, coeffFile);

% Scale input signal to real numbers (assuming fixed-point to integer conversion)
scaledInputSignal = scaleData(inputSignal, 14);%Q14
scaledCoeff = scaleData(coefficients, 14);%Q14
scaledoutputSignal = scaleData(outputSignal, 14);%Q14
% Apply FIR filter
filteredSignal = applyFIRFilter(scaledInputSignal, scaledCoeff);

% Check result
checkResult(filteredSignal, scaledoutputSignal);

