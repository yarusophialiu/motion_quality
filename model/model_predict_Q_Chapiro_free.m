function [Q, J] = model_predict_Q_Chapiro_free(luminance, frame_rate, speed, params)
% preict quality based on Chapiro, Atkins and Daly [2019]
%  luminance: mean luminance in cd/m^2
%  speed: panning speed in deg/s
%  frame_rate: in Hz
% params: row vector of 10 with the free params

    % coefficients and powers from A.3
    D = [ params;
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
    %gamma = S *1920 / 33; % from the paper. speed should be in px/s
    gamma = S/33;
   
    
    T = repmat([alpha, beta, gamma], size(D, 1), 1); % reping to distribute alpha, beta and gamma
    T2 = T .^ D(:,2:4); % raise to power
    T3 =  prod([D(:,1), T2], 2); % multiply with coefficients
    J = sum(T3); % sum all
end