function [res, rseed] = generate_residuals(N, sigma, rseed)
% this could be in a toolkit
if nargin>2
   rng(rseed);
else
   rseed = rng;
end
res =  sigma.*randn(1,N);
