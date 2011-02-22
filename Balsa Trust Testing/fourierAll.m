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
    %fprintf('%d: %s\n',i,dirStruct(i).name);
    [freq(i,:), amplitude(i,:), time(i,:), sigAmp(i,:)] = fftTrussTest(dirStruct(i).name);
    
    % Exclude those tests that didn't have mass added to the truss.
    if (regexp(dirStruct(i).name,'noMass','once'))
        testType(i) = 3;
        continue;
    end
    if (regexp(dirStruct(i).name,'Ver','once'))
        testType(i) = 1;
    elseif (regexp(dirStruct(i).name,'Lat','once'))
        testType(i) = 2;
    else
        testType(i) = 0;
    end
end

fh1 = figure(1);
grid on;
hold on;
title({'Periodogram for vertical oscillation of single' 'truss arm'},'FontSize',14);
xlabel('Frequency [Hz]','FontSize',14);
ylabel('Magnitude of Fourier Transform','FontSize',14);

fh2 = figure(2);
grid on;
hold on;
title({'Periodogram for lateral oscillation of single' 'truss arm'},'FontSize',14);
xlabel('Frequency [Hz]','FontSize',14);
ylabel('Magnitude of Fourier Transform','FontSize',14);

% Make plots using the cutoff power defined below.
powerCutOff = 3;   % Only plot up to the last frequency that has
                     % a power amplitude of at least this.
                     
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


print(fh1,'-dpng','fourierVert.png');
print(fh2,'-dpng','fourierLat.png');


% Make plots with an arbritrary cut off picked so that we only see
% the blatantly significant frequency peaks.
fh3 = figure(3);
grid on;
hold on;
title({'Periodogram for vertical oscillation of single' 'truss arm'},'FontSize',14);
xlabel('Frequency [Hz]','FontSize',14);
ylabel('Magnitude of Fourier Transform','FontSize',14);

fh4 = figure(4);
grid on;
hold on;
title({'Periodogram for lateral oscillation of single' 'truss arm'},'FontSize',14);
xlabel('Frequency [Hz]','FontSize',14);
ylabel('Magnitude of Fourier Transform','FontSize',14);

% Make plots using the cutoff frequency defined below.
freqCutOff = 300;   % [hz]
        
% Put all of the data from the 10ish trials on one set of plots
for i=1:size(amplitude,1)
   % Switch between the lateral and vertical tests
   % TODO: Also distinguish between tests with mass on the trus
   %       and tests without mass.
   if (testType(i) == 1)
       figure(fh3);
   else
       figure(fh4);
   end
   freqCutInd = max(find(freq(i,:) < freqCutOff));
   plot(freq(i,1:freqCutInd),amplitude(i,1:freqCutInd),'o','MarkerFaceColor','b','MarkerSize',5);
end

print(fh3, '-depsc2','fourierVert300.eps');
print(fh4, '-depsc2','fourierLat300.eps');

%% Raw Gyro Signal Example Trial 13 - Lateral
fh5 = figure(5);
grid on;
hold on;
title({'Raw Voltage signal from Gyro as recorded', 'by an Oscilloscope for Lateral Test'},'FontSize',14);
xlabel('Time [s]','FontSize',14);
ylabel('Voltage [V]','FontSize',14);

plot(time(8,1:2113), sigAmp(8,1:2113),'.');

print(fh5, '-depsc2','rawLat.eps');

fh6 = figure(6);
grid on;
hold on;
title({'Raw Voltage signal from Gyro as recorded', 'by an Oscilloscope for Vertical Test'},'FontSize',14);
xlabel('Time [s]','FontSize',14);
ylabel('Voltage [V]','FontSize',14);

plot(time(7,625:2425), sigAmp(7,625:2425),'.');

print(fh6, '-depsc2','rawVert.eps');