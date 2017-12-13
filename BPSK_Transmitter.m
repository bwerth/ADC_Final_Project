clear all
close all


%%%%%%% Transmitter %%%%%%%%%%

% normally distributed training signal, common between transmitter and receiver
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

% binary phase shift keying
%convert text string to binary string to be transmitted
text = 'testing testing 123';
m = dec2bin(text,8) - '0';
m = m';
m = m(:)';
m = [train,m];
n= length(m);

%phase for 0
p1 = 0;

%phase for 1
p2 = pi;

% frequency of the carrier
f = 2000;% in Hz

% sampling rate
fs = 44100;
dt=1/fs; %seconds per sample
symbol_freq = 100; %bitrate in Hz
symbol_period = 1/symbol_freq; %symbol period in seconds

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
