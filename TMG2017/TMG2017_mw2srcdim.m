
function [L, W, stats] = TMG2017_mw2srcdim(instruc, faultregime)     
% returns source dimensions for given magnitude(s), computed using the 
% empirical earthquake source-scaling relations (see References). 
%
% SYNTAX
%   Do not use this function directly, instead use mw2srcdim()
%
% 
% REFERENCES
%    Thingbaijam, K.K.S., and P.M. Mai, (2020). Notes on empirical earthquake 
%      source-scaling laws, Bulletin of Seismological Society America, 
%      under review
%
%    Thingbaijam, K.K.S., P.M. Mai, and K. Goda (2017). New empirical earthquake
%      source-scaling laws, Bulletin of Seismological Society America,
%      107, 2225–2246.
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
% Additonal notes:
%    (1) Area-scaling is assumed applicable for entire magnitude range.
%    (2) For lower magnitudes, it is possible to generate rupture width W
%        longer than rupture length L. If the users require L > W, these 
%        two can be swaped. 
%

% default
stats = struct;
Mw = instruc.Mw(:);
nsim =length(instruc.Mw);

switch faultregime 
    % Table 1 of Thingbaijam, Mai and Goda (2017)
    % Regarding validity of magnitude range, we take care of the smaller
    % magnitude bound, but ignore upper magnitude bound
    % 
    % Variable Mt is lower magnitude threshold below 
    % which self-similar scaling applies  
    %
    case 1 % reverse faulting, crustal 
        log10L = -2.693 + 0.614.*Mw;  sigmalog10L = 0.083;
        log10W = -1.669 + 0.435.*Mw;  sigmalog10W = 0.087;     
        Mt = 5.7; % this is a revised value
        
    case 2 % reverse faulting, subduction interface 
        log10L = -2.412 + 0.583.*Mw;  sigmalog10L = 0.107;
        log10W = -0.880 + 0.366.*Mw;  sigmalog10W = 0.099;      
        Mt = 7.1; % revised
     
    case 3 % normal faulting
        log10L = -1.722 + 0.485.*Mw;  sigmalog10L = 0.128;
        log10W = -0.829 + 0.323.*Mw;  sigmalog10W = 0.128; 
        Mt = 5.6;
       
    case 4 % strike-slip
        log10L = -2.943 + 0.681.*Mw;  sigmalog10L = 0.105;
        log10W = -0.543 + 0.261.*Mw;  sigmalog10W = 0.184;        
        Mt = 5.8; % this is a revised value!
end

% impose self-similar scaling for Mw<Mt
if any(Mw<Mt)
    log10A = Mw2medianlog10A(Mw, faultregime);
    log10L(Mw<Mt) =  log10A(Mw<Mt)./2; % this is same as
    log10W(Mw<Mt) =  log10A(Mw<Mt)./2; % log10(sqrt(A))
end
        
if ~strcmpi(instruc.scale, 'median')
    if isfield(instruc,'seeds') && isstruct(instruc.seeds)
        [Lres, Lseed] = generate_residuals(nsim, sigmalog10L, instruc.seeds(1));
        [Wres, Wseed] = generate_residuals(nsim, sigmalog10W, instruc.seeds(2));
    else
        [Lres, Lseed] = generate_residuals(nsim, sigmalog10L);
        [Wres, Wseed] = generate_residuals(nsim, sigmalog10W);
    end
    
    stats.medianL = 10.^log10L;
    stats.medianW = 10.^log10W; 
    stats.Lseed = Lseed;
    stats.Wseed = Wseed;
    
    log10L = log10L(:) + Lres(:);
    log10W = log10W(:) + Wres(:);
end

W = 10.^(log10W);
L = 10.^(log10L);

% % ---------------------------------------------------------------------
% % For smaller magnitudes, it can be possible to generate W longer than L
% % Question is should we take care to make W smaller than L? 
% % Time-being, this is not addressed.
% indx    = find(W>L);
% W_temp  = W(indx);
% W(indx) = L(indx);
% L(indx) = W_temp;
% % --------------------------------------------------------------------

% Take care of max. seismogenic width; if Wseis is exceeded, set W = Wseis, 
% and apply area scaling to estimate L. 
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

findx = find(W>Wseis);
if ~isempty(findx)
    clear log10A;
    log10A   = log10(W.*L);
    if length(Wseis)>1
        W(findx) = Wseis(findx);
        L(findx) = (10.^log10A(findx))./Wseis(findx);
    else
        W(findx) = Wseis;
        L(findx) = (10.^log10A(findx))./Wseis;
    end
end

%------------------------------------------------------------------------
function log10A = Mw2medianlog10A(mag, faultregime)
% returns log10A  based on Table 1 of Thingbaijam, Mai and Goda (2017)
switch faultregime
    case 1
        log10A = -4.362 + 1.049.*mag; 
    case 2
        log10A = -3.292 + 0.949.*mag;
    case 3
        log10A = -2.551 + 0.808.*mag; 
    case 4
        log10A = -3.486 + 0.942.*mag; 
end