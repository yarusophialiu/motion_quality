function [sigma,mu,A]=mygaussianfit(x,y,h)
% source: https://uk.mathworks.com/matlabcentral/fileexchange/11733-gaussian-curve-fit
% [sigma,mu,A]=mygaussfit(x,y)
% [sigma,mu,A]=mygaussfit(x,y,h)
%
% this function is doing fit to the function
% y=A * exp( -(x-mu)^2 / (2*sigma^2) )
%
% the fitting is been done by a polyfit
% the lan of the data.
%
% h is the threshold which is the fraction
% from the maximum y height that the data
% is been taken from.
% h should be a number between 0-1.
% if h have not been taken it is set to be 0.2
% as default.
%
%% threshold
if nargin==2, h=0.2; end
%% cutting
ymax = max(y);
idcs = y > ymax*h;
xnew = x(idcs);
ynew = y(idcs);

%% fitting
ylog=log(ynew);
xlog=xnew;
p = fminsearch(@(p) sqrt(mean( (p * xlog .^2 - ylog) .^ 2)), -0.1);
%p=polyfit(xlog,ylog,2);
A2=p;
A1=0;
A0=0;
sigma=sqrt(-1/(2*A2));
mu=A1*sigma^2;
A=exp(A0+mu^2/(2*sigma^2));