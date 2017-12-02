clear all
close all


%%%%%%% Transmitter %%%%%%%%%%

% binary phase shift keying

% create a simple word
n = 8; % length of the word

% giving the random word a binary signal
m = randi([0 1], n, 1)

%phase for 0
p1 = 0;

%phase for 1
p2 = pi;

% frequency of the signal
f = 3;

% sampling rate
fs = 100;

% time
t = 0: 1/fs : 1;

psk_sig = [];   % phase shift keyed signal
orig_msg = [];  % the original message
time = [];      % the time vector, good for plotting

for i = 1: 1: length(m)
    
    % creating the psk signal
    psk_sig = [psk_sig (m(i)==0)*cos(2*pi*f*t + p1)+...
        (m(i)==1)*cos(2*pi*f*t + p2)];
    
    % creating the OG signal
    orig_msg = [orig_msg .5*(m(i)==0)*zeros(1,length(t))+...
        .5*(m(i)==1)*ones(1,length(t))];
    
    % updating the time
    time = [time t];
    t = t + 1;
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
    rbb(j) = cos(2*pi*fs)*psk_sig(j);
end

% IS is the integrated signal
IS = [];

for j = 1: length(rbb)/n :length(rbb)
    IS = [IS -trapz(rbb([(j-1+length(rbb)/n) j]))];
end

IS(IS<0) = [0]; % turning negative ones to zeros



