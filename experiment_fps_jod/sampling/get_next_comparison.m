function [next_comp] = get_next_comparison(M)
    
    [kl_divs] = fill_kl_divergence_mat(M);
    next_comp=argmax_mat(kl_divs);
    
end