function [Mw, stats] = srcdim2mw(varargin)
% Estimates magnigtude (Mw) for given source dimension, either rupture length (km) 
% or rupture area (sq. km)using the empirical earthquake source-scaling relations.
% If both rupture length and rupture area are provided, then the magnitude
% is estimated based on rupture area.
% 
% SYNTAX
%    [L, W, stats] = Mw2SrcDim(...,'ParameterName',ParameterValue,...)
% 
% LIST of PARAMETERNAMES
%    Length               - Rupture length (in km)
% 
%    Area                 - Rupture Area (in sq. km)                            
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
%    Mw                   - Moment Magnitude  
%    stats                - A structure with field:
%                           medianMw: median magnitude (Mw)  
%                           seed  : seed used for random sampling 
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
%    $ version 0.1 Dated: 04/2020
%    
%    If you find any error or have suggestion, please do not hesitate to 
%    drop me an email.
%
% 
% DISCLAIMER
%    This software is provided "as is" with no warranty expressed or implied. 
%
% Additional notes: 
%    (1) The empirical source-scaling relations of Thingbaijam,Mai,and Goda (2017)
%        are invariant under the interchange of variables, i.e., 
%        y = f(x) and x = f(y).
%    (2) How to implement scaling relations from other authors?
%        You got to write the matlab function. The name should be a unique 
%        shorthand for the authors. TMG2017.m can be used a refernce template.

%

if isempty(varargin)
    help srcdim2mw; return; 
end


% defaults
options = struct('length', -1,'area', -1, 'fault','none', 'regime', 'none', ...
    'author', 'TMG2017', 'seismogenic_width', 6378, 'scale', 'random', ....
    'sliprate', nan, 'stressdrop', nan, 'seeds', nan);

addpath('utility');
% parse the input arguments
inparams = parse_inputs(varargin, options);
scfunc = inparams.author;

addpath(scfunc);

inparams.func = 'srcdim2mw';
if inparams.area<0
    inparams = rmfield(inparams, 'area');
end
if inparams.length<0
    inparams = rmfield(inparams, 'length');
end
outpar = feval(scfunc,inparams);
Mw = outpar.Mw;
stats = outpar.stats;

rmpath(scfunc, 'utility');










