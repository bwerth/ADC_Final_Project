clear
close all

N=10000;    %Length of input in samples
t=[0:N-1];  %vector N integers incrementing from 0
w0=0.001;   %frequency of sinewave test input
phi=0.1;    %phase for sinewave test input
d=sin(2*pi*[1:N]*w0+phi);   %desired signal in our case just a sinewave
x=d+randn(1,N)*0.5;         %signal with noise                 %step size
a = 1;                      %bias for normalized LMS
M = 50;                     %LMS filter order
w=zeros(M,N);               %initialize weight vector
u=.1;                    %adaptation rate constant
for i=(M+1):N
   e(i) = d(i) -  x((i-(M)+1):i)*w(:,i);    %error calculation
   mu = u/(x((i-(M)+1):i)*x((i-(M)+1):i)' + a);     %step size normalization
   w(:,i+1) = w(:,i) + mu * e(i) * x((i-(M)+1):i)'; %weight update equation
end
for i=(M+1):N
    yd(i) = x((i-(M)+1):i)*w(:,i);  %calculate the filtered noisy input
end

for i=1:length(e)
    mse(i)= mean(e(1:i).^2);    %calculate mean squared error for plotting
end

subplot(221),plot(t,d),ylabel('Desired Signal'),
subplot(222),plot(t,x),ylabel('Input Signal+Noise'),
subplot(223),plot(t,mse),ylabel('Mean Squared Error'),
subplot(224),plot(t,yd),ylabel('Adaptive Desired output');
