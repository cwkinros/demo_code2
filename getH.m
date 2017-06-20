function [H] = getH(W1, W2, g1s, g1_1s, g2_1s, g2_2s, g1_2s, dg1s, dg2s, inputs, lambda, WS, indices, b_w)

[~,n0] = size(W1);
[n2,n1] = size(W2);
n = n2*(n1 + 1) + n1*(n0 + 1);
if WS
    I = eye(n);
    n = b_w;
    H = zeros(b_w);
    for i = 1:b_w
        v = Hv(I(:,indices(i)),W1, W2, g1s, g1_1s, g2_1s, g2_2s, g1_2s, dg1s, dg2s, inputs, lambda);
        for j = 1:b_w
            H(j,i) = v(indices(j));
        end
    end
        
else
    
    I = eye(n);
    H = zeros(n);
    for i = 1:n
        H(:,i) = Hv(I(:,i),W1, W2, g1s, g1_1s, g2_1s, g2_2s, g1_2s, dg1s, dg2s, inputs, lambda);
    end
end
