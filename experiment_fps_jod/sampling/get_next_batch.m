function [next_comp] = get_next_batch(M)
    
    [inf_mat] = fill_kl_divergence_mat(M);
    
    inf_mat = inf_mat+inf_mat';
    inf_mat = 1./inf_mat;
    inf_mat(inf_mat<0) = Inf;
    GrMST = graph(inf_mat);
    t = minspantree(GrMST);
    t_edges = sortrows(t.Edges,2);
    next_comp = t_edges.EndNodes;
    
end