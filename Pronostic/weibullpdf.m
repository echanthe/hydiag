function y = weibullpdf(x,Beta,Eta,Teta)
%WEIBULLPDF Weibull probability density function (pdf).
%   Y = WEIBULLPDF(X,Beta,Eta,Teta) returns the pdf of the Weibull distribution with 
%   scale parameter Eta,shape parameter Beta and posotion parameter Teta evaluated 
%   at the values in X.  The size of Y is the common size of the input arguments.
%   A scalar input functions as a constant matrix of the same size as the
%   other inputs.
%
%   Default values for Beta ,Eta and Teta are 1, 1 and 0, respectively.
%
%   See also WEIBULLCDF,WBLCDF, WBLFIT, WBLINV, WBLLIKE, WBLRND, WBLSTAT, PDF.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 2013 LAAS-CNRS , Inc. Said
%   $Revision: 1.1.8.2 $  $Date: 2010/10/08 17:27:16 $

if nargin<1
    error(message('stats:wblpdf:TooFewInputs'));
end
if nargin < 2
    Eta = 1;
end
if nargin < 3
    Beta = 1;
end
if nargin < 4
    Teta = 0;
end


Teta = Teta * ones(size(x));

% Return NaN for out of range parameters.
Eta(Eta <= 0) = NaN;
Beta(Beta <= 0) = NaN;
Teta(Teta >  x) = NaN;

x = x - Teta;
try
    z = x ./ Eta;

    % Negative data would create complex values when B < 1, potentially
    % creating spurious NaNi's in other elements of y.  Map them to the far
    % right tail, which will be forced to zero.
    z(z < 0) = Inf;

    w = exp(-(z.^Beta));
catch 
    error(message('stats:wblpdf:InputSizeMismatch'));
end
y = z.^(Beta-1) .* w .* Beta ./ Eta;

% Force zero for extreme right tail, instead of Inf*exp(-Inf)==NaN.  This
% also catches negative x values.
y(w == 0) = 0;
