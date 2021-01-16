function [G] = helper_parallelTensorTrainCompression_h2_g(r1, A, r2, dims, dims_identity, accur)
    
    if length(dims_identity) == 1
    G{dims_identity} = reshape(A, r1, numel(A)/(r1*r2), r2);
    return;
    end

    d = length(dims);
    d_half = idivide(d+1, int32(2));

    first_dim = r1 * prod(dims(1:d_half));

    C = reshape(A, first_dim, numel(A)/first_dim);
    [U S V] = svd(C, 'econ');
    accur_per_dim = accur /sqrt(d-1);

    r = findsuitableRankWithAccuracies(S, accur_per_dim);

    d1 = length(dims(1:d_half));
    d2 = length(dims(d_half+1:d));

    sum_1 = trace(S(1:r,1:r));
    delta = accur / sqrt((d-1)*sum_1); 
    lhs_next_level_error = delta * sqrt(d1-1);
    rhs_next_level_error = delta * sqrt(d2-1);

    %next_level_error = accur * sqrt((d-2)/((d-1)*(1+sum_2)));

    U=U(:,1:r);
    S=S(1:r,1:r);
    V=V(:,1:r);

    S_sqrt = sqrt(S);

    G1 = helper_parallelTensorTrainCompression_h2_g(r1, U*S_sqrt, r, dims(1:d_half), dims_identity(1:d_half), lhs_next_level_error);
    G2 = helper_parallelTensorTrainCompression_h2_g(r, S_sqrt*V', r2, dims(d_half+1:d), dims_identity(d_half+1:d), rhs_next_level_error);
    G = {G1{1:dims_identity(d_half)}, G2{dims_identity(d_half+1:d)}};
    
end


