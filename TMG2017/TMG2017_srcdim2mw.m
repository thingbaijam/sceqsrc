function [Mw, stats] = TMG2017_srcdim2mw(instruc, faultregime)
% returns moment magnitude Mw, for given source dimension(s), computed using the 
% empirical earthquake source-scaling relations (see References). 
%
% SYNTAX
%   Do not use this function directly, instead use srcdim2mw()
%
% REFERENCES
%   Thingbaijam, K.K.S., and P.M. Mai, (2020). Notes on empirical earthquake 
%     source-scaling laws, Bulletin of Seismological Society America, 
%     under review
%   Thingbaijam, K.K.S., P.M. Mai, and K. Goda (2017). New empirical earthquake
%     source-scaling laws, Bulletin of Seismological Society America,
%     107, 2225–2246.
%
% WRITTEN by:
%    Thingbaijam K.K.S (thingbaijam@gmail.com; 
%    Also, see https://github.com/thingbaijam/sceqsrc
% 
%    $ version 0.1.0 Dated: 04/2020
%
% DISCLAIMER
%    This software is provided "as is" with no warranty expressed or implied. 
%

% default
stats = struct;

if isfield(instruc, 'area')
    scale_rupture_area = 1;
    A = instruc.area;
    nsim =length(instruc.area);
elseif isfield(instruc, 'length')
    scale_rupture_area = 0;
    L = instruc.length;
    nsim =length(instruc.length);
else
    error('*** Either area or length should be provided');    
end

% Table 1 of Thingbaijam, Mai and Goda (2017)
% Regarding validity of magnitude range, we take care of smaller
% magnigtudes, but ignore larger magnigtudes 
% 
% Variable Lt is lower length thresholds 
% below which self-similar scaling applies; these values are estimated
% from the scaling relations (see TMG2017_mw2srcdim.m)
%
if scale_rupture_area
    [Mw, sigmaMw] = A2Mw(A, faultregime);
else
    [Mw, sigmaMw] =  L2Mw(L, faultregime);
    Lt  =  Mw2L(5.7, faultregime); % Mt 5.7
end

if ~scale_rupture_area
    % Impose self-similar scaling for L<Lt
    if any(L<Lt)
        [xMw, xsigmaMw] = A2Mw(L.^2, faultregime);
        Mw(L<Lt) = xMw(L<Lt);
        sigmaMw = xsigmaMw;
    end
end
         
if ~strcmpi(instruc.scale, 'median')
    if isfield(instruc,'seeds') && isstruct(instruc.seeds)
        [Mwres, seed] = generate_residuals(nsim, sigmaMw, instruc.seeds(1));
    else
        [Mwres, seed] = generate_residuals(nsim, sigmaMw);
    end
    stats.medianMw = Mw;
    stats.seed = seed;    
    Mw = Mw(:) + Mwres(:);
end

if scale_rupture_area
    % Do not be bothered about finite seismogenic width
    return;
end

% Take care of max. seismogenic width; if Wseis is exceeded, set W = Wseis, 
% and apply area scaling to estimate Mw. 
Wseis  = instruc.seismogenic_width(:);
nWseis = length(Wseis);

if nWseis>1 
    if nWseis ~= nsim
        strerror1 = sprintf('*** Seismogenic_width should be either'); 
        strerror2 = (' one value, or an array of size same as Mw');
        error([strerror1, strerror2]);
    end
else
    if Wseis>500
        return;
    end
end

if strcmpi(instruc.scale, 'median')
    Wseis = median(Wseis);  
end

W = Mw2W(Mw, faultregime);

findx = find(W>Wseis);
if ~isempty(findx)
    xMw =  A2Mw(L.*Wseis, faultregime);
    Mw(findx) = xMw(findx);
end


%-----------------------------------------------------------------------
function [Mw, sigmaMw] =  L2Mw(L, faultregime)
% returns Mw for given Rupture Length
%
log10L = log10(L);
switch faultregime 
   case 1 % reverse faulting, crustal 
      % log10L = -2.693 + 0.614.*Mw;         
      Mw = (log10L+2.693)./0.614; sigmaMw = 0.083;      
   case 2
      %log10L = -2.412 + 0.583.*Mw;  sigmalog10L = 0.107;
      Mw = (log10L+2.412)./0.583; sigmaMw = 0.107;
   case 3
      %log10L = -1.722 + 0.485.*Mw;  sigmalog10L = 0.128;
      Mw = (log10L+1.722)./0.485; sigmaMw = 0.128;
   case 4
      %log10L = -2.943 + 0.681.*Mw;  sigmalog10L = 0.105;
      Mw = (log10L+2.943)./0.681; sigmaMw = 0.105;
end


function [Mw, sigmaMw] = A2Mw(A, faultregime)
% returns Mw for given Rupture Area
%
log10A = log10(A);
% Table 1 of Thingbaijam, Mai and Goda (2017)
switch faultregime 
   case 1 % reverse faulting, crustal 
       %log10A = -4.362 + 1.049.*Mw;        
       Mw = (log10A+4.362)./1.049; sigmaMw = 0.121; 
   case 2 % reverse faulting, subduction interface 
       Mw = (log10A+3.292)./0.949; sigmaMw = 0.150;
   case 3 % normal faulting
       Mw = (log10A+2.551)./0.808; sigmaMw = 0.181;    
   case 4 % strike-slip
       Mw = (log10A+3.486)./0.942; sigmaMw = 0.184;  
end

function L = Mw2L(Mw, faultregime)
%
switch faultregime 
    case 1
    L = 10.^(-2.693 + 0.614.*Mw); 
    case 2      
    L = 10.^(-2.412 + 0.583.*Mw); 
    case 3     
    L = 10.^(-1.722 + 0.485.*Mw);   
    case 4       
    L = 10.^(-2.943 + 0.681.*Mw); 
end

function W = Mw2W(Mw, faultregime)
%
switch faultregime 
    % Table 1 of Thingbaijam, Mai and Goda (2017)
    case 1 % reverse faulting, crustal 
        W = 10.^(-1.669 + 0.435.*Mw); 
    case 2 % reverse faulting, subduction interface 
        W = 10.^(-0.880 + 0.366.*Mw);  
    case 3 % normal faulting
        W = 10.^(-0.829 + 0.323.*Mw);  
    case 4 % strike-slip
        W = 10.^(-0.543 + 0.261.*Mw); 
end


