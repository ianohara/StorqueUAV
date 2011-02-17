%%%%%%%%%%%%%%%%
%   Discrete Fourier Transform of beam vibration
%   data to find fundamental frequency of vibration
%
%   By: Ian O'Hara
%   Date: 2/15/2011
%   Base idea of code taken from mathworks (fft() help page)

function [freq, amplitude] = fftTrussTest(csvFile)

if (exist(csvFile,'file') ~= 2)
    disp(sprintf('fftTrussTest: The file "%s" does not exist.',csvFile));
end

close all;

% This only works on windows...D'OH!
% [numberData, textData, rawData] = xlsread(csvFile);
% 
% time = numberData(:,3);        % [s]
% voltAmplitude = numberData(:,4); % [some Voltage] that depends on
%                                  % settings in the csv file.
% 
% % Get the settings from the output of xlsread
% % Note that this is for a "TDS2002B Oscope"
% recordLen      = rawData{1,2};
% sampleInterval = rawData{2,2};
% triggerPoint   = rawData{3,2};
% voltScale      = rawData{9,2};
% vertOffset     = rawData{10,2};
% timeScale      = rawData{12,2};

fh = fopen(csvFile);
rowCount = 1;
while (1)
   line = fgetl(fh);
   if (line == -1)
       break;
   end
   
   line = native2unicode(line);   % Portability, hopefully.
   colVals = regexp(line,',','split');
   rawData{rowCount} = colVals;
   rowCount = rowCount+1;
end

freq = rawData;
amplitude = 1;

return;
% Some derived data
sampleTime = max(time)-min(time);
sampleRate = recordLen/(sampleTime); % [samples/s]

NFFT = 2^nextpow2(recordLen); % Next power of 2 from length of y
Y = fft(voltAmplitude,NFFT)/recordLen;
freq = sampleRate/2*linspace(0,1,NFFT/2+1);
figure(1);

%Plot single-sided amplitude spectrum.
plot(freq,2*abs(Y(1:NFFT/2+1))) ;
title('Single-Sided Amplitude Spectrum of y(t)');
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');


figure(2);
plot(time,voltAmplitude);
end