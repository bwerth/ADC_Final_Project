function [mse,yd,w,e] = Acoustic_LMS(d,x,M,mu)

N=length(d);    %Length of input in samples
w=zeros(M,N);   %initialize weight vector

for i=(M+1):N
   yd(i) = x((i-(M)+1):i)*w(:,i);                   %calculate the filtered noisy input
   e(i) = d(i) -  yd(i);                            %error calculation
   w(:,i+1) = w(:,i) + mu * e(i) * x((i-(M)+1):i)'; %weight update equation
   mse(i)=mean((e).^2);
end
