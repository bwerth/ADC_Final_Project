%%%%%%%% Receiver %%%%%%%%%%

%___________________________receiver parameters__________________________
p1 = 0; %phase for 0
p2 = pi; %phase for 1
f = 3500; %frequency of the carrier in Hz
fs = 44100; %sampling rate in Hz
dt=1/fs; %seconds per sample
symbol_freq = 75; %bitrate in Hz
symbol_period = 1/symbol_freq; %symbol period in seconds
t = 0: dt : symbol_period; % time vector
receive_time = 10; %recording time in seconds
sig_length = 288184; %length of transmitted signal in samples


a = 1;                  %bias for normalized LMS and variable step nLMS
M = 150;                %LMS filter order
umin = 1e-3;            %adaptation rate minimum
umax = 1.25;            %adaptation rate maximum
beta = 20;              %step size change rate constant


%_______________________training signal and synchronization parameters_______________________

Fc = 1000; %cutoff frequency in Hz
%normally distributed pre-defined training signal, common between
%transmitter and receiver
train = [...
    0,0,0,1,1,1,1,1,1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,1,1,1,0,0,0,0,1,0,0,0,1,1,1,1,1,1,1,0,1,...
    0,1,1,0,0,0,0,1,0,0,0,1,0,1,1,1,1,1,0,0,1,1,0,0,1,1,0,0,0,0,1,0,1,1,1,0,1,0,0,0,1,0,1,0,1,0,0,1,...
    1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,1,0,1,0,0,1,0,1,1,1,1,1,1,0,1,0,0,0,1,0,1,1,1,0,0,0,1,1,1,0,1,...
    1,1,1,1,1,1,0,0,0,0,1,0,0,1,1,0,1,0,0,0,1,0,1,1,1,1,1,0,1,0,1,1,0,0,0,0,1,1,0,1,1,1,1,1,1,0,0,0,...
    1,1,0,1,1,1,1,0,1,1,1,0,0,0,1,1,0,1,0,1,1,0,1,1,0,1,0,1,0,1,1,0,1,1,1,1,0,1,0,0,0,0,1,0,1,0,1,1,...
    1,1,0,1,1,0,1,0,1,0,1,0,1,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,0,1,0,0,1,0,1,1,0,0,0,0,1,0,0,0,0,1,0,0,...
    1,1,1,0,0,0,1,1,0,0,1,0,1,1,1,0,0,1,0,0,0,0,0,1,1,0,1,0,0,1,0,0,0,1,0,1,1,1,1,0,1,0,1,0,1,1,0,0,...
    1,1,0,0,1,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,1,0,1,1,1,0,1,1,1,0,1,0,1,0,1,0,0,0,1,1,1,0,1,1,0,0,0,1,...
    0,1,1,1,1,1,1,0,0,0,1,1,0,0,0,1,1,0,0,1,1,0,0,1,0,1,1,1,1,0,0,1,1,0,1,0,1,0,1,0,1,1,1,0,0,1,0,1,...
    0,0,1,1,0,0,1,1,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,1,0,1,1,0,1,0,...
    1,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,1,1,0];

sync_sig = [];   % phase shift keyed signal for synchronizing to the transmitted signal

recObj = audiorecorder(fs, 16, 1); %initialize audio recorder
disp('recording');
recordblocking(recObj, receive_time); % start recording for receive time
y = getaudiodata(recObj);
time = zeros(length(y),1);      % the time vector, good for plotting

for i = 1 : length(y)
    % updating the time
    time(i+1) = time(i) + symbol_period;
    if abs(y(i))>0.05
        index = i;
        break
    end
end

tmp = y(index:-1:1);
for i = 1:length(tmp)
    if abs(tmp(i))<0.0005
        index = length(tmp) - i;
        break
    end
end

y_trim = y(index : index+sig_length);

rbb_c = [];

for j = 1:1: length(y_trim)
    rbb_c(j) = cos(2*pi*f*time(j))*y_trim(j);
    rbb_s(j) = sin(2*pi*f*time(j))*y_trim(j);
end

rbb_lowpass = filterlp(rbb_c, (2*pi*Fc)/fs);
rbb_lowpass = rbb_lowpass(101:end - 100);%truncate to remove convolution effect

[mse,yd,w,stepSize] = Acoustic_VariableStep_nLMS(train,rbb_lowpass,a, M, umin, umax, beta);

% IS is the integrated signal
IS = [];
for j = 1: length(rbb_c)/n :length(rbb_c)
    IS = [IS -trapz(rbb_c([(j-1+length(rbb_c)/n) j]))];
end
IS(IS<0) = [0]; % turning negative ones to zeros
