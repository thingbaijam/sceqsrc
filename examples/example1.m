% Example 1. For given uncertain magnitude defined by probability distribution  
% (mean and standard deviation), estimate the corresponding rupture width and 
% rupture length for subduction interface event.
% 

% get the distibution of magnitudes
Mw      = 8.0+ 0.2*randn(100,1); % 100 sample would be good!

% estimate the source dimensions
[L, W, stats] = mw2srcdim('Mw', Mw, 'fault', 'reverse',...
    'regime', 'interface');  

% plot the results
subplot(2,1,1);
plot(Mw, log10(W), 'ko', 'markerfacecolor', [0.7 0.7 0.7]);
hold on;
plot(Mw, log10(stats.medianW), 'r-');

xlabel('magnitude (Mw)'); ylabel('log_1_0(W)');
axis([7 9 1.5 3]);

subplot(2,1,2);
plot(Mw, log10(L), 'ko', 'markerfacecolor', [0.7 0.7 0.7]);
hold on;
plot(Mw, log10(stats.medianL), 'r-');
xlabel('magnitude (Mw)'); ylabel('log_1_0(L)');
axis([7 9 1.5 3]);
