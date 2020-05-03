function [L, W, stats] = mw2srcdim(varargin)  
% Estimates rupture length L (km) and rupture width (km) for given
% magnitude, using the empirical earthquake source-scaling relations.
% 
% SYNTAX
%    [L, W, stats] = Mw2SrcDim(...,'ParameterName',ParameterValue,...)
% 
% 
% LIST of PARAMETERNAMES
%    Mw                   - Moment Magnitude, for example, 'Mw',7.6
%
%    fault                - faulting type/style. 
%                           ParameterValue can be one of the following:     
%                           'strike-slip', 'reverse', 'normal'
%
%    regime               - seimogenic regime.
%                           ParameterValue can be one of the following:
%                           'crustal', 'interface'
%                           Interface refers to subduction interface.
%                           Also see: "How to implement scaling relations 
%                           from other authors" in Additional notes. 
%                            
%    The above input parameters are mandatory. Optional ones are:
%    Author               - a unique shorthand for the authors
%                           Example: 'Author', 'TMG2017' 
%                           This explicitly specify that the relations of 
%                           Thingbaijam, Mai and Goda(2017) be applied, 
%                           which  is default value.                        
%                           
%                           Also see: "How to implement scaling relations 
%                           from other authors" in Additional notes.  
% 
%    seismogenic_width    - Set fixed (maximum) seismogenic width/s (in km). 
%                           If this is array, its size should be same as Mw. 
%                           Array can be used to account for uncertain 
%                           seismogenic width.   
%                           Seismogenic width (Wseis) is different from seismogenic 
%                           depth (Zseis).Wseis = Zseis/sind(dipAn),
%                           where dipAn is fault-dip in degrees.  
%                           Default value is set 6378 km.
%
%    scale                - This can be use to avoid random sampling.
%                           For example: 'scale', 'median'
%                           In this case, output stats is not set. 
%                           Default value: 'random'     
%
% OUTPUTS
%    L, W                 - Rupture length (in km), Rupture width (in km) 
%    stats                - A structure with field:
%                           medianL: median rupture length (in km)  
%                           medianW: median rupture width (in km)
%                           Lseed  : seed for random sampling of L 
%                           Wseed  : seed for random sampling of W
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
%    If you find any error or have suggestion, please do not hesitate to 
%    drop me an email.
%
%
% DISCLAIMER
%    This software is provided "as is" with no warranty expressed or implied. 
%
% Additional notes:
%   (1) What about average slip? 
%       Preferably, it can be computed using Aki(1966)'s relation: 
%       D = Mo /(Mu A), where Mu is shear modulus (rigidity) 
%       computed from appropiate crustal velocity-density model, and A = L W.
%       
%   (2) How to implement scaling relations from other authors?
%       You got to write the matlab function. The name should be a unique 
%       shorthand for the authors. TMG2017.m can be used a reference template. 
%

if isempty(varargin)
    help mw2srcdim; return; 
end

% defaults
options = struct('Mw', 0, 'fault','none', 'regime', 'none', ...
    'author', 'TMG2017', 'seismogenic_width', 6378, 'scale', 'random', ....
    'sliprate', nan, 'stressdrop', nan, 'seeds', nan);

% parse the input arguments
addpath('utility');
inparams = parse_inputs(varargin, options);
scfunc = inparams.author;
%
addpath(scfunc);
% 
outpar = feval(scfunc,inparams);
L = outpar.L;
W = outpar.W;
stats = outpar.stats; 

rmpath(scfunc, 'utility');



