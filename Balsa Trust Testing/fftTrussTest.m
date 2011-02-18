%%%%%%%%%%%%%%%%
%   Discrete Fourier Transform of beam vibration
%   data to find fundamental frequency of vibration
%
%   By: Ian O'Hara
%   Date: 2/15/2011
%   Base idea of code taken from mathworks (fft() help page)

function [freq, amplitude, time, voltAmp] = fftTrussTest(csvDir)

if (exist(csvDir,'file') ~= 7)
    disp(sprintf('fftTrussTest: The Directory "%s" does not exist.',csvDir));
    freq = -1;
    amplitude = -1;
    return;
end

close all;

[status, result] = system(['perl formatScopeData.pl ' csvDir '/']);

numFile = [csvDir '/Numerical.csv'];
setFile = [csvDir '/Settings.csv'];

if (exist(numFile,'file') ~= 2)
   fprintf('fftTrustTest: Numerical.csv does not exist in specified directory. Perl script failure.\n');
   freq = -1;
   amplitude = -1;
   return;
end

numData = csvread(numFile);
settings = csvread(setFile);

time = numData(:,1);
voltAmp = numData(:,2);

numSamples = settings(1);      % Number of samples
sampleInterval = settings(2);  % Time between samples [s]
trigPoint = settings(3);       % Not entirely sure what this is.
vertScale = settings(6);       % Volts/1 count
vertOffset = settings(7);      % Volts
horScale = settings(9);        % Seconds/1 count

% Some derived data
sampleTime = numSamples*sampleInterval - sampleInterval;   % [s]
sampleRate = 1/sampleInterval;   % [1/s]

fourierPoints = 500; % Next power of 2 from length of y
normFreq = fft(voltAmp);
normFreq(1) = []; % First term is just the sum of all terms.

fourierLen = length(normFreq);
amplitude = abs(normFreq(1:floor(fourierLen/2))).^2;

% Return both as 1xfourierLen/2 vectors.
freq = sampleRate.*(1:fourierLen/2)/(fourierLen/2)*(1/2);  % Help from mathworks.
amplitude = amplitude';
end