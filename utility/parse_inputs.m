function options = parse_inputs(inpars, options)
% read the inputs - ParameterName,ParameterValue pairs
%
%
% Adapted from 
% https://stackoverflow.com/questions/2775263/
% how-to-deal-with-name-value-pairs-of-function-arguments-in-matlab/
% 60178631#60178631
% 
% 

optionnames = fieldnames(options);
%# count arguments
nargs = length(inpars);
if round(nargs/2)~=nargs/2
   error('**** PropertyName/propertyValue pairs are required!')
end
for pair = reshape(inpars,2,[]) %# pair is {propName;propValue}
   % inpName = lower(pair{1}); %# make case insensitive
   inname = pair{1}; 
   if any(strcmpi(inname,optionnames))
      %# overwrite options. If you want you can test for the right class here
      %# Also, if you find out that there is an option you keep getting wrong,
      %# you can use "if strcmp(inpName,'problemOption'),testMore,end"-statements
      options.(inname) = pair{2};
   else
      error('**** %s is not a recognized parameter name',inname)
   end
end
