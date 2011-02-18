% Look through the current directory for other directories and then call
% fftTrussTest for each of those directories, collect the results, and plot
% the results intelligently.

close all;
clear all;

dirStruct = dir('.');

freq = [];
amplitude = [];
testType = [];  % 1 for a vertical test, 2 for a lateral test

for i=1:size(dirStruct,1)
    
    % If this isn't a directory, or is either the current directory '.' or
    % parent directory '..' then move to the next one.
    if ((dirStruct(i).isdir == 0) || (strcmp(dirStruct(i).name,'.')) || (strcmp(dirStruct(i).name,'..')))
        continue;
    end
    
    [freq(i,:), amplitude(i,:), time(i,:), sigAmp(i,:)] = fftTrussTest(dirStruct(i).name);
    if (regexp(dirStruct(i).name,'Ver','once'))
        testType(i) = 1;
    elseif (regexp(dirStruct(i).name,'Lat','once'))
        testType(i) = 2;
    else
        testType(i) = 0;
    end
end


powerCutOff = 3;   % Only plot up to the last frequency that has
                     % a power amplitude of at least this.
fh1 = figure(1);
grid on;
hold on;
title({'Periodogram for vertical oscillation of single' 'truss arm'},'FontSize',14);
xlabel('Frequency [Hz]','FontSize',14);
ylabel('Power (Complex Magnitude of Fourier Transform)','FontSize',14);

fh2 = figure(2);
grid on;
hold on;
title({'Periodogram for lateral oscillation of single' 'truss arm'},'FontSize',14);
xlabel('Frequency [Hz]','FontSize',14);
ylabel('Power (Complex Magnitude of Fourier Transform)','FontSize',14);

for i=1:size(amplitude,1)
   if (testType(i) == 1)
       figure(fh1);
   else
       figure(fh2);
   end
   
   cutOffIndices = find(amplitude(i,:) > powerCutOff);
   maxFreq = max(cutOffIndices);
   
   plot(freq(i,1:maxFreq),amplitude(i,1:maxFreq),'.','MarkerFaceColor','b');
end

