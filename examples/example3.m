

% Example 3. Let see for Mw 7.0 magnitude event, how the source dimensions 
% vary across different faulting regimes.

Mw = 7.2.*ones(1000,1);

[L_rr, W_rr, ~] = mw2srcdim('Mw', Mw, 'fault', 'reverse',...
    'regime', 'crustal');
[L_int, W_int, ~] = mw2srcdim('Mw', Mw, 'fault', 'reverse',...
    'regime', 'interface');
[L_nn, W_nn, ~] = mw2srcdim('Mw', Mw, 'fault', 'normal');
[L_ss, W_ss, ~] = mw2srcdim('Mw', Mw, 'fault', 'strike-slip');

yy = 0:1:200;
subplot(4,2,1);
histogram(L_rr); hold on;
plot(median(L_rr).*ones(size(yy)), yy, 'r--');
axis([0 200 0 200]);

subplot(4,2,3);
histogram(L_int);  hold on;
plot(median(L_int).*ones(size(yy)), yy, 'r--');
axis([0 200 0 200]);

subplot(4,2,5);
histogram(L_nn);  hold on;
plot(median(L_nn).*ones(size(yy)), yy, 'r--');
axis([0 200 0 200]);

subplot(4,2,7);
histogram(L_ss); hold on;
plot(median(L_ss).*ones(size(yy)), yy, 'r--');
axis([0 200 0 200]);
