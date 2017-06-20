function [m0x] = M0x(x, g, gamma, W1, W2, g1s, g1_1s, g2_1s, g2_2s, g1_2s, dg1s, dg2s, inputs, lambda)

[two_n,m] = size(x);

if (m > two_n)
    two_n = m;
    x = x.';
end

n = two_n / 2;

m0x = zeros(two_n,1);

m0x(1:n) = -x(1:n) + Hv(x(n+1:two_n),W1, W2, g1s, g1_1s, g2_1s, g2_2s, g1_2s, dg1s, dg2s, inputs, lambda);
m0x(n+1:two_n) = Hv(x(1:n),W1, W2,g1s, g1_1s, g2_1s, g2_2s, g1_2s, dg1s, dg2s, inputs, lambda)- g*(g.'*x(n+1:two_n)) / gamma^2;


