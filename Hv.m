function [hv] = Hv(v,W1,W2, g1s, g1_1s,g2_1s, g2_2s, g1_2s, dg1s, dg2s, inputs, lambda)

[~,m] = size(g1_1s);
[n1,n0] = size(W1);
[n2,~] = size(W2);
% just ignore word
[V1,V2,bias_v1,bias_v2] = m_to_M1M2(v,n0,n1,n2);
if false %isnan(bias_v1)
    R_g1s = g1_1s.*(V1*inputs);
    R_g2s = g2_1s.*(W2*R_g1s + V2*g1s);

    R_dg2s = R_g2s;

    R_dW2 = R_dg2s.*g2_1s*(g1s.') + dg2s.*g2_2s.*(W2*R_g1s + V2*g1s)*(g1s.') + dg2s.*g2_1s*(R_g1s.');%getting too tired -> finish quickly tomorrow

    part1 = (R_dg2s.*g2_1s).'*W2;
    part2 = (dg2s.*g2_2s.*(W2*R_g1s + V2*g1s)).'*W2;
    part3 = (dg2s.*g2_1s).'*V2;
    R_dg1s =  part1 + part2 + part3;


    part1 = (R_dg1s.').*g1_1s*(inputs.');
    part2 = dg1s.*g1_2s.*(V1*inputs)*(inputs.');
    R_dW1 = part1 + part2;


    hv = (1/m)*M1M2_to_m(R_dW1,R_dW2,NaN,NaN)+lambda*v;
else
    R_g1s = g1_1s.*(V1*inputs + bias_v1*ones(1,m));
    R_g2s = g2_1s.*(W2*R_g1s + V2*g1s + bias_v2*ones(1,m));

    R_dg2s = R_g2s;

    R_dW2 = R_dg2s.*g2_1s*(g1s.') + dg2s.*g2_2s.*(W2*R_g1s + V2*g1s + bias_v2*ones(1,m))*(g1s.') + dg2s.*g2_1s*(R_g1s.');%getting too tired -> finish quickly tomorrow
    R_dbias2 = (R_dg2s.*g2_1s + dg2s.*g2_2s.*(W2*R_g1s + V2*g1s + bias_v2*ones(1,m)))*ones(m,1);


    part1 = (R_dg2s.*g2_1s).'*W2;
    part2 = (dg2s.*g2_2s.*(W2*R_g1s + V2*g1s + bias_v2*ones(1,m))).'*W2;
    part3 = (dg2s.*g2_1s).'*V2;
    R_dg1s =  part1 + part2 + part3;


    part1 = (R_dg1s.').*g1_1s*(inputs.');
    part2 = dg1s.*g1_2s.*(V1*inputs + bias_v1*ones(1,m))*(inputs.');
    R_dW1 = part1 + part2;

    R_dbias1 = ((R_dg1s.').*g1_1s + dg1s.*g1_2s.*(V1*inputs + bias_v1*ones(1,m)))*ones(m,1);

    hv = (1/m)*M1M2_to_m(R_dW1,R_dW2,R_dbias1,R_dbias2)+lambda*v;
end


% g1_1s and g2)1s already use biases


