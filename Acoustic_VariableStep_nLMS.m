function [mse,yd,w,stepSize] = Acoustic_VariableStep_nLMS(d,x,a, M, umin, umax, beta)
%This function accepts a desired signal (d), an input with noise (x), nLMS
%bias (a), LMS order M, adaptation rate minimum (umin), adaptation rate
%maximum (umax), and step size change rate constant (beta)

%This function returns an array of format [mse,filtered,w] where mse is the
%mean squared error vector, filtered is the adaptively filter output, and w is the calculated weights vector.

N=length(d);    %Length of input in samples
w=zeros(M,N);   %initialize weight vector

for i=(M+1):N
   yd(i) = x((i-(M)+1):i)*w(:,i);                   %calculate the filtered noisy input
   e(i) = d(i) -  yd(i);                            %error calculation
   sigma_c = (yd(i)'*yd(i))/(rms(x(i))^2);          %tracking error estimate
   u=umax + (umin-umax)*exp(-beta*sigma_c);         %variable step size calculation
   mu = u/(x((i-(M)+1):i)*x((i-(M)+1):i)' + a);     %step size normalization
   stepSize(i)=mu;
   w(:,i+1) = w(:,i) + mu * e(i) * x((i-(M)+1):i)'; %weight update equation
   mse(i)= mean(e.^2);                              %calculate mean squared error for plotting
end
