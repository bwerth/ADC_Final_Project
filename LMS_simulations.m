clear
close all

N = 10000;
w0=0.001;                   %frequency of sinewave test input
phi=0;                      %phase for sinewave test input
d=sin(2*pi*[1:N]*w0+phi);   %desired signal in our case just a sinewave
x=d+randn(1,N);             %signal with noise
t=[0:N-1];                  %vector N integers incrementing from 0
figure(1)
subplot(221),plot(t,d),ylabel('Desired Signal'),
subplot(222),plot(t,x),ylabel('Input Signal+Noise'),

a = 1;                  %bias for normalized LMS and variable step nLMS
M = 150;                %LMS filter order
umin = 1e-3;            %adaptation rate minimum
umax = 1.25;            %adaptation rate maximum
beta = 20;              %step size change rate constant
u=[.5 .75 1 1.25 1.5];  %adaptation rate constant
mu=0.01;                %step size for LMS

[mse,yd,w,stepSize] = Acoustic_VariableStep_nLMS(d,x,a,M,umin,umax,beta);

hold on
subplot(223),plot(t,mse),ylabel('Mean Squared Error'),
hold on
subplot(224),plot(t,yd),ylabel('Adaptive Desired output');

figure(2)
[mse,yd,w] = Acoustic_LMS(d,x,M,.00025);
hold on
plot(t,mse),ylabel('Mean Squared Error'),xlabel('number of iterations'),title('MSE vs Step Size for LMS')
[mse,yd,w] = Acoustic_LMS(d,x,M,.0005);
plot(t,mse)
[mse,yd,w] = Acoustic_LMS(d,x,M,.00075);
plot(t,mse)
legend('mu = 0.0025','mu = 0.005', 'mu = 0.0075')
