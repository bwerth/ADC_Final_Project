function [mse,yd,w] = Acoustic_nLMS(d,x,a,M,u)
N=length(d);    %Length of input in samples
w=zeros(M,N);   %initialize weight vector

for i=(M+1):N
   yd(i) = x((i-(M)+1):i)*w(:,i);                   %calculate the filtered noisy input
   e(i) = d(i) -  yd(i);                            %error calculation
   mu = u/(x((i-(M)+1):i)*x((i-(M)+1):i)' + a);     %step size normalization
   w(:,i+1) = w(:,i) + mu * e(i) * x((i-(M)+1):i)'; %weight update equation
   mse(i)= mean(e.^2);                              %calculate mean squared error for plotting
end
