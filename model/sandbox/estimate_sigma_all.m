single_factor = 2.019352; % FROM ESTIMATE_SIGMA1.M

% estimate gauss sigma for combined blur
f = -120:0.05:120;
ws = linspace(0.01, 3, 10);
[ws1, ws2] = meshgrid(ws,ws);

triws = linspace(0.01, 10, 10);

sigmas = zeros(size(ws1));
for iT=1:length(triws)
    for ii=1:numel(ws1)
        v_b1 = f_box(f, ws1(ii));
        v_b2 = f_box(f, ws2(ii));
        v_t = f_tri(f,triws(iT)); 
        v_j = v_b1 .* v_b2 .* v_t;
        sigmas(ii) = mygaussianfit(f, v_j, 0.15);
        %plot(f, v_j); hold on;
        %plot(f, gaussian(f, 0, sigmas(ii), 1));hold off;
        %drawnow;
        if mod(ii, 2000) == 0
            fprintf('%f%%\n', 100 * ii / numel(ws1));
        end
    end
    e_sigmas = sqrt((2 * ws1) .^ 2 + (2 * ws2) .^ 2 + 0.9 * 2 * (2 * triws(iT)) .^2 );
    subplot(4, 3, iT);
    surf(ws, ws, 1./sigmas); hold on;
    surf(ws, ws, e_sigmas, 'EdgeColor', 'red'); hold off;
    %zlim([0, 30]);
end


