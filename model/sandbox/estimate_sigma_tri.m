% estimate gauss sigma for triangle windows

single_factor = 2.019352; % FROM ESTIMATE_SIGMA1.M

f = -120:0.05:120;
ws = linspace(0.00, 3, 300);
sigmas = zeros(size(ws));
for iW=1:length(ws)
    v_b = f_tri(f, ws(iW));
    sigmas(iW) = mygaussianfit(f, v_b, 0.15);
end
a = polyfit(ws, 1./sigmas, 1);
clf;
plot(ws, 1./sigmas); hold on;
plot(ws, a(1) * ws); hold off;
fprintf('gaussian sigma is approx. %f of a single rect window width\n', a(1));
fprintf('gaussian sigma from two rect windows: %f\n', single_factor * sqrt(2));

