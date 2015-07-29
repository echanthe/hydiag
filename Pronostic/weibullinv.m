function x = weibullinv(p,Beta,Eta,Teta)
%WEIBULLINV Inverse of the Weibull cumulative distribution function (cdf).
%   X = WEIBULLLINV(P,Eta,Beta,Teta) returns the inverse cdf for a Weibull
%   distribution with scale parameter Eta, shape parameter Beta and posotion parameter Teta 
%   evaluated at the values in P.  The size of X is the common size of the
%   input arguments.  A scalar input functions as a constant matrix of the
%   same size as the other inputs.
%   
%   Default values for Beta ,Eta and Teta are 1, 1 and 0, respectively.
%
%   See also WBLCDF, WBLFIT, WBLLIKE, WBLPDF, WBLRND, WBLSTAT, ICDF.

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
Teta = Teta * ones(size(p));


k = (0 < p & p < 1);
if all(k(:))
    q = -log(1-p);
    
else
    if isa(p,'single')
        q = zeros(size(p),'single');
    else
        q = zeros(size(p));
    end
    q(k) = -log(1-p(k));
    
    % Avoid log(0) warnings.
    q(p == 1) = Inf;
    
    % Return NaN for out of range probabilities.
    q(p < 0 | 1 < p | isnan(p)) = NaN;
end

% Return NaN for out of range parameters.
Eta(Eta <= 0) = NaN;
Beta(Beta <= 0) = NaN;
try
    X = Eta .* q.^(1./Beta);
    
    x = X + Teta;
    
    %x(x<0) = NaN;
catch me %#ok<NASGU>
    error(message('stats:wblinv:InputSizeMismatch'));
end


end
