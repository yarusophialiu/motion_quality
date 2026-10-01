function S = csf_barten_3( u, L, args )
% CSF model from:
%
% Barten, P. G. J. (2004). Formula for the contrast sensitivity of the human eye. 
% In Proc. SPIE 5294, Image Quality and System Performance (pp. 231–238). doi:10.1117/12.537476
%
% u - frequency in cyc per deg
% L - background (adaptation) luminance

% new in Barten 3: args is a length 5 argument vector. 
% [ 5.8518    1.5672    1.1888    2.3904    0.8455] is an optimal fit for
% current monochromatic DayDream and Vive gradient setup

    X_0 = args(1);

    
    S = args(5) * 5200*exp( -0.0016 * u.^2 .* (1+100./L).^0.08 ) ./ sqrt( (1+144/X_0^2 + args(3)*u.^2) .* ( (args(4)./L.^args(2))+1./(1-exp( -0.02*u.^2)) ) );

end