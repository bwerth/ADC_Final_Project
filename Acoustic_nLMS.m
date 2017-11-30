clear

load('handel')
%y = handel music signal
%Fs = sample frequency
step_size=0.001;%Constant for normalized LMS
a=1;%bias for normalized LMS algorithm
noise_signal=.75; %Desired rms amplitude of noise relative to rms amplitude of signal
noise=(noise_signal*rms(y))*randn(size(y)); %Randomly generated gaussian white noise with rms amplitude of noise_signal
H_s=[.1 .7 .1];% impulse response of system (we just made this up for testing purposes)
%H_s=[1];
noise_ear=conv(noise,H_s,'same');% noise passed through this channel
noisy_audio=y+noise_ear;
LMS_order=500;% Order of the LMS - i.e. the size of the weight vector
W_s=zeros(1,length(y));% initialize weight vector of 0s with size LMS order
error=zeros(1,length(y));
x=y+noise;
for i=LMS_order:length(y)
    anti_noise(i) = W_s(i-LMS_order+1:i)*noise(i-LMS_order+1:i);
    error(i) = noise_ear(i)-anti_noise(i);
    W_s(i+1) = W_s(i) + step_size*error(i)*x(i)/((x(i))^2+a);
end
W_s=W_s(2:end);
anti_noise=anti_noise';
plot(anti_noise+noisy_audio)
for i=1:73113
    predicted(i)=W_s(i)*noise(i);
end
subplot(311);
plot(predicted)
subplot(312);
plot(noise_ear)
subplot(313);
plot(noise_ear'-predicted)
