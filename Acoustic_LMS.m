clear
close all

N=10000;    %Length of input in samples
t=[0:N-1];  %vector N integers incrementing from 0
w0=0.001;   %frequency of sinewave test input
phi=0.1;    %phase for sinewave test input
d=sin(2*pi*[1:N]*w0+phi);   %desired signal in our case just a sinewave
x=d+randn(1,N)*0.5;         %signal with noise
w=zeros(1,N);               %weights vector initialized at 0
mu=0.05;                    %step size
LMS_ORDER = 500;            %length of weights vector

for i=LMS_ORDER:N
   e(i) = d(i) - w(i)' * x(i);
   w(i+1) = w(i) + mu * e(i) * x(i);
end
for i=1:N
yd(i) = sum(w(i)' * x(i));  
end
subplot(221),plot(t,d),ylabel('Desired Signal'),
subplot(222),plot(t,x),ylabel('Input Signal+Noise'),
subplot(223),plot(t,e),ylabel('Error'),
subplot(224),plot(t,yd),ylabel('Adaptive Desired output');
