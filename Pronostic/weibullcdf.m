function p = weibullcdf(x,Beta,Eta,Teta)
%WEIBULLCDF Weibull cumulative distribution function (cdf).
%   P = WEIBULLCDF(X,Eta,Beta,Teta) returns the cdf of the Weibull distribution
%   with scale parameter Eta, shape parameter Beta and posotion parameter Teta evaluated at the
%   values in X.  The size of P is the common size of the input arguments.
%   A scalar input functions as a constant matrix of the same size as the
%   other inputs.
%
%   Default values for Beta ,Eta and Teta are 1, 1 and 0, respectively.
%
%   See also WEIBULLPDF,CDF, WBLFIT, WBLINV, WBLLIKE, WBLPDF, WBLRND, WBLSTAT.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 2013 LAAS-CNRS , Inc. Said
%   $Revision: 1.1.8.2 $  $Date: 2010/10/08 17:27:16 $

%narginchk(1,4);
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

% Force a zero for negative x.
x = x - Teta;
x(x < 0) = 0;



try
    z = (x./Eta).^Beta;
catch me %#ok<NASGU>
    error(message('stats:wblcdf:InputSizeMismatch'));
end
p = 1 - exp(-z);
end
