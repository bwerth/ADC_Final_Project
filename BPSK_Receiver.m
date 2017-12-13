%%%%%%%% Receiver %%%%%%%%%%

%___________________________receiver parameters__________________________
p1 = 0; %phase for 0
p2 = pi; %phase for 1
f = 2000; %frequency of the carrier in Hz
fs = 44100; %sampling rate in Hz
dt=1/fs; %seconds per sample
symbol_freq = 100; %bitrate in Hz
symbol_period = 1/symbol_freq; %symbol period in seconds
t = 0: dt : symbol_period; % time vector
receive_time = 10; %recording time in seconds


%_________________________low pass filter parameters_____________________
N   = 500;        % FIR filter order
Fp  = 1000;       % cuttoff frequency in Hz
Rp  = 0.00057565; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-4;       % Corresponds to 80 dB stopband attenuation
eqnum = firceqrip(N,Fp/(fs/2),[Rp Rst],'passedge'); % eqnum = vec of coeffs
lowpassFIR = dsp.FIRFilter('Numerator',eqnum); %or eqNum200 or numMinOrder
%_______________________training signal and synchronization parameters_______________________
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

recObj = audiorecorder(fs, 8, 1); %initialize audio recorder
recordblocking(recObj, receive_time); % start recording for receive time
x = getaudiodata(recObj);

for i = 1: length(train)  
    % creating the psk signal
    sync_sig = [sync_sig (train(i)==0)*cos(2*pi*f*t + p1)+...
        (train(i)==1)*cos(2*pi*f*t + p2)];
end

sync = xcorr(sync_sig,x);


rbb = [];

for j = 1:1: length(psk_sig)
    rbb(j) = cos(2*pi*f*time(j))*psk_sig(j);
end

rbb_lowpass = lowpassFIR(rbb);

% IS is the integrated signal
IS = [];
for j = 1: length(rbb)/n :length(rbb)
    IS = [IS -trapz(rbb([(j-1+length(rbb)/n) j]))];
end
IS(IS<0) = [0]; % turning negative ones to zeros
