function [W1,W2,bias1,bias2] = addP(p,n0,n1,n2,W1,W2,bias1,bias2)

[P1, P2, P_bias1, P_bias2] = m_to_M1M2(p,n0,n1,n2);

W1 = W1 + P1;
W2 = W2 + P2;
bias1 = bias1 + P_bias1;
bias2 = bias2 + P_bias2;