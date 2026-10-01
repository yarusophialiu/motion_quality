single_factor = 2.019352; % FROM ESTIMATE_SIGMA1.M

% estimate gauss sigma for rect windows
f = -120:0.05:120;
ws = linspace(0.01, 3, 100);
[ws1, ws2] = meshgrid(ws,ws);

sigmas = zeros(size(ws1));
for ii=1:numel(ws1)
    v_b1 = f_box(f, ws1(ii));
    v_b2 = f_box(f, ws2(ii));
    v_j = v_b1 .* v_b2;
    sigmas(ii) = mygaussianfit(f, v_j, 0.15);
    %plot(f, v_j); hold on;
    %plot(f, gaussian(f, 0, sigmas(ii), 1));hold off;
    %drawnow;
    if mod(ii, 2000) == 0
        fprintf('%f%%\n', 100 * ii / numel(ws1));
    end
end

e_sigmas = sqrt((single_factor * ws1) .^ 2 + (single_factor * ws2) .^ 2);
surf(ws, ws, 1./sigmas); hold on;
surf(ws, ws, e_sigmas); hold off;

