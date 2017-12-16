%%%%%%%% Receiver %%%%%%%%%%

%___________________________receiver parameters__________________________
p1 = 0; %phase for 0
p2 = pi; %phase for 1
f = 5000; %frequency of the carrier in Hz
fs = 44100; %sampling rate in Hz
dt=1/fs; %seconds per sample
symbol_freq = 75; %bitrate in Hz
symbol_period = 1/symbol_freq; %symbol period in seconds
t = 0: dt : symbol_period; % time vector
%receive_time = 10; %recording time in seconds
sig_length = 384028; %length of transmitted signal in samples
n = 652; % number of bits in a packet

a = 1;                  %bias for normalized LMS and variable step nLMS
M = 10;                %LMS filter order
umin = 1e-2;            %adaptation rate minimum
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

% recObj = audiorecorder(fs, 16, 1); %initialize audio recorder
% disp('recording');
% recordblocking(recObj, receive_time); % start recording for receive time
% y = getaudiodata(recObj);
y_norm=(1/max(abs(y))).*y;
time = zeros(sig_length,1);      % the time vector, good for plotting

for i = 1 : sig_length
    % updating the time
    time(i+1) = time(i) + dt;
end

for i = 1 : sig_length
    if (y_norm(i))>0.35
        index = i - 2;
        break
    end
end
y_trim = y_norm(index : index+sig_length - 1);

rbb_c = [];

for j = 1:length(y_trim)
    rbb_c(j) = cos(2*pi*f*time(j) + (pi/2))*y_trim(j);
    rbb_s(j) = cos(2*pi*f*time(j) + (pi/2));%*y_trim(j);
end

rbb_lowpass = filterlp(rbb_c, (2*pi*Fc)/fs);
rbb_lowpass = rbb_lowpass(101:end - 100);%truncate to remove convolution effect

train = repelem(train,294);% turn the train signal into the baseband signal for our system
train = sign(train - 0.5);
downsampled_y = downsample(rbb_lowpass,2);
[mse,yd,w,stepSize,e] = Acoustic_VariableStep_nLMS(train,downsampled_y,a, M, umin, umax, beta);
% 
% IS is the integrated signal
IS = [];
for j = 1 : length(yd)/n : length(yd)
    IS = [IS trapz(yd(j:(j-1+length(yd)/n)))];
end
IS(IS<0) = [0]; % turning anything less than 1 to zeros
IS(IS>0) = [1]; % turning anything greater than 0 to 1