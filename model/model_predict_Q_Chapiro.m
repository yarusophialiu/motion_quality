function [Q, J] = model_predict_Q_Chapiro(luminance, frame_rate, speed)
% preict quality based on Chapiro, Atkins and Daly [2019]
%  luminance: mean luminance in cd/m^2
%  speed: panning speed in deg/s
%  frame_rate: in Hz

    % coefficients and powers from A.3
    D = [ 1620.37, 86.81, 0.32, -95.55, 0.32, 0.00, 0.48, 1.01, 0.00, 2.35;
                2, 1, 1, 1, 0, 0, 0, 0, 0, 0;
                0, 1, 0, 0, 2, 1, 1, 0, 0, 0;
                0, 0, 1, 0, 0, 1, 0, 2, 1, 0]';
        
            
    % coefficients to our fit
    D = [ 2013.29484469932           79.989846691516      1.88776350520202e-13          119.984770037274         0.282434341078023 0.0089055134619841         0.618076452343332          1.40735025498153      0.000213660716844093          5.51941443624633;
                2, 1, 1, 1, 0, 0, 0, 0, 0, 0;
                0, 1, 0, 0, 2, 1, 1, 0, 0, 0;
                0, 0, 1, 0, 0, 1, 0, 2, 1, 0]';
         
    % coefficients from Chapiro's email
    D = [1620.37267080746          86.8082906256909         0.320448868447773         -95.5544193256484        -0.318628091166034 0.000763570204858091         -0.47623126883255     -1.00998175043235e-05     -0.000937624477501955          2.34848262897281;
                        2, 1, 1, 1, 0, 0, 0, 0, 0, 0;
                0, 1, 0, 0, 2, 1, 1, 0, 0, 0;
                0, 0, 1, 0, 0, 1, 0, 2, 1, 0]';
            
    % resize inputs
    len = max([length(luminance), length(frame_rate), length(speed)]);
    if len > 1
        if length(luminance) == 1
            luminance = repmat(reshape(luminance, length(luminance), 1), len, 1);
        end
        if length(frame_rate) == 1
            frame_rate = repmat(reshape(frame_rate, length(frame_rate), 1), len, 1);
        end
        if length(speed) == 1
            speed = repmat(reshape(speed, length(speed), 1), len, 1);
        end
    end

    % apply model for each tuple
    J = arrayfun(@(L,F,S) apply_polynomial(L,F,S,D), luminance(:), frame_rate(:), speed(:));
    Q = -J;
end


function J = apply_polynomial(L,F,S, D)
    % apply the polynomial function from the paper (Sec 6, A.3)
    alpha = 1 / F;
    beta = log10(L);
    gamma = S *1920 / 33; % from the paper. speed should be in px/s   
    
    T = repmat([alpha, beta, gamma], size(D, 1), 1); % reping to distribute alpha, beta and gamma
    T2 = T .^ D(:,2:4); % raise to power
    T3 =  prod([D(:,1), T2], 2); % multiply with coefficients
    J = sum(T3); % sum all
end