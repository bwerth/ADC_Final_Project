clear all
close all


%%%%%%% Transmitter %%%%%%%%%%

% binary phase shift keying
%convert text string to binary string to be transmitted
text = 'testing testing 123';
m = dec2bin(text,8) - '0';
m = m';
m = m(:)';
n= length(m);

%phase for 0
p1 = 0;

%phase for 1
p2 = pi;

% frequency of the carrier
f = 1000;% in Hz

% sampling rate
fs = 8192;
dt=1/fs; %seconds per sample
symbol_period = 0.5;

% time
t = 0: dt : symbol_period;

psk_sig = [];   % phase shift keyed signal
orig_msg = [];  % the original message
time = [];      % the time vector, good for plotting

for i = 1: length(m)
    
    % creating the psk signal
    psk_sig = [psk_sig (m(i)==0)*cos(2*pi*f*t + p1)+...
        (m(i)==1)*cos(2*pi*f*t + p2)];
    
    % creating the OG signal
    orig_msg = [orig_msg .5*(m(i)==0)*zeros(1,length(t))+...
        .5*(m(i)==1)*ones(1,length(t))];
    
    % updating the time
    time = [time t];
    t = t + symbol_period;
end

% plotting the phase shift keyed signal
plot(time, psk_sig, 'LineWidth',2);
xlabel('Time (s)');
ylabel('Signal');
hold on

%plotting the original signal
plot(time, orig_msg, 'r', 'LineWidth', 2);
legend('Phase-shifted signal', 'Original binary message');


%%%%%%%% Receiver %%%%%%%%%%

% rbb is the input to the receiver multiplied by
%   the cosine

rbb = [];

for j = 1:1: length(psk_sig)
    rbb(j) = cos(2*pi*f*time(j))*psk_sig(j);
end

rbb_lpf = fftshift(abs(fft(rbb)));

for i = 1:length(rbb_lpf)
    if ((i < (2.6*10^5)) || (i > (3.5 * 10^5))) 
        rbb_lpf(i) = 0;
    end
end

figure;
plot(time, lpf(rbb));
title('lpf signal fft');

figure;

plot(fftshift(abs(fft((rbb)))));
title('orig signal fft');

rbb_ifft = ifft(rbb_lpf,'symmetric');

figure;
plot(time, rbb_ifft);
title('lpf signal ifft')


% IS is the integrated signal
IS = [];

for j = 1: length(rbb)/n :length(rbb)
    IS = [IS -trapz(rbb([(j-1+length(rbb)/n) j]))];
end

[mse_out,yd_out,w_out,stepSize_out] = Acoustic_VariableStep_nLMS(IS,0,1,50,.001,.5,.25);

IS(IS<0) = [0]; % turning negative ones to zeros



