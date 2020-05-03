function outpar = TMG2017(instruc)
% Implements empirical earthquake-source scaling relations of 
% Thingbaijam, Mai and Goda (2017)   
% 
% INPUTS
% instruc        -  A structure with fields (defined as in Mw2SrcDim.m): 
%                   Mw, fault, regime, seismogenic_depth (optional), 
%                   scale (optional), seeds(optional)
%                         
% OUTPUTS
%    L, W, stats - as in Mw2SrcDim.m 
%
% DEPEDENCIES
%    TMG2017_mw2srcdim
%    TMG2017_srcdim2mw
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
%    Also, see https://github.com/thingbaijam/eqsrcdim
% 
%    $ version 0.1 Dated: 04/2020
%
% DISCLAIMER
%   This software is provided "as is" with no warranty expressed or implied.
%
% Additional notes: 
%   (1) Errors of L and W are independent of each other. Hence, explicit 
%       scaling of fault aspect-ratio is avoided.  
%


% check for optionals
if ~isfield(instruc, 'seismogenic_width')
    instruc.seismogenic_width = 6378;
end
if ~isfield(instruc, 'scale')
    instruc.scale = 'random';
end
if ~isfield(instruc, 'func')
    instruc.func = 'mw2srcdim';
end


% get faulting regime
if strcmpi(instruc.fault, 'reverse') ...  
           && strcmpi(instruc.regime, 'crustal')   
    faultregime = 1;
elseif strcmpi(instruc.fault, 'reverse') ...
           && strcmpi(instruc.regime, 'interface')
    faultregime = 2;
elseif strcmpi(instruc.fault, 'normal')
    faultregime = 3;
elseif strcmpi(instruc.fault, 'strike-slip')
    faultregime = 4;
else
    strerror1 = sprintf('**** TMG2017 does not define source-scaling relations ');
    strerror2 = sprintf('for fault: %s and regime: %s',instruc.fault, ...
        instruc.regime);
    error([strerror1, strerror2]);
end

if strcmpi(instruc.func,'mw2srcdim')
   [L, W, stats] = TMG2017_mw2srcdim(instruc, faultregime);  
   outpar.L = L;
   outpar.W = W;
   outpar.stats = stats;
elseif strcmpi(instruc.func,'srcdim2mw')
   [Mw, stats]  = TMG2017_srcdim2mw(instruc, faultregime);  
   outpar.Mw    = Mw;
   outpar.stats = stats;
end


%------------------------------------------------------------------------







