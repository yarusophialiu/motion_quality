function v = f_tri(f, w)
    % w: base width
    v = sinc(f * w) .^ 2;
end