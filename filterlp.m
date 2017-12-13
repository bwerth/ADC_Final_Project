function res=filterlp(signal,wc)
% function for low pass filtering where wc is frequency in Radians/Sample
n=[-100:100];
h=wc/pi*sinc(wc*n/pi);
res=conv(h,signal);
end
