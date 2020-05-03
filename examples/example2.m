

% Example 2. Estimate the magnitude, given fault length for strike-slip 
% event and finite seismogenic width. 
 
 
% median prediction
[Mw, ~] = srcdim2mw('length', 853, 'fault', 'strike-slip', ...
    'seismogenic_width',18, 'scale', 'median');
disp(Mw);

% examine effect of uncertain seismogenic width - 100 samples, for 
% seismogenic width described with lognormal-distributed errors  
 
res = lognrnd(0.05,0.3, 100,1); res=res-median(res);
seismogenic_width = 18+res;
 
[Mw, stats] = srcdim2mw('length', 853.*ones(100,1), 'fault', 'strike-slip', ...
    'seismogenic_width',seismogenic_width);
 
plot(seismogenic_width, Mw, 'ko', 'markerfacecolor', [0.7 0.7 0.7]);

ylabel('magnitude (Mw)');
xlabel('seismogenic width (km)');
