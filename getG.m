function [g,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,error] = getG(W1,W2,bias1,bias2,inputs,outputs,lambda,m)

if isnan(bias1)
    h1s = W1*inputs;
    g1s = sigmoid(h1s);
    h2s = W2*g1s;
    g2s = sigmoid(h2s);
    errors = (g2s - outputs);
    actual_error = 0.5*sum(sum(errors.*errors));
    reg_error = 0.5*lambda*(sum(sum(W1.*W1)) + sum(sum(W2.*W2)));
    error = (1/m)*actual_error + reg_error;
    g2_1s = sigmoid_1(h2s);
    g1_1s = sigmoid_1(h1s);

    gradW2 = (errors.*g2_1s)*g1s.';
    dg1s = ((errors.*g2_1s).'*W2).';
    gradW1 = (dg1s.*g1_1s)*inputs.';

    gradW2 = (1/m)*gradW2 + lambda*W2;
    gradW1 = (1/m)*gradW1 + lambda*W1;

    % all the updates

    dg2s = errors;
    g2_2s = sigmoid_2(h2s);
    g1_2s = sigmoid_2(h1s);
    g = M1M2_to_m(gradW1,gradW2,NaN,NaN);    
else

    h1s = W1*inputs + bias1*ones(1,m);
    g1s = sigmoid(h1s);

    h2s = W2*g1s + bias2*ones(1,m);
    g2s = sigmoid(h2s);

    errors = (g2s - outputs);
    actual_error = 0.5*sum(sum(errors.*errors));
    reg_error = 0.5*lambda*(sum(sum(W1.*W1)) + sum(sum(W2.*W2)) + sum(bias1.*bias1) + sum(bias2.*bias2));
    error = (1/m)*actual_error + reg_error;
    g2_1s = sigmoid_1(h2s);
    g1_1s = sigmoid_1(h1s);

    gradW2 = (errors.*g2_1s)*g1s.';
    grad_bias2 = (errors.*g2_1s)*ones(m,1);
    dg1s = ((errors.*g2_1s).'*W2).';
    gradW1 = (dg1s.*g1_1s)*inputs.';
    grad_bias1 = (dg1s.*g1_1s)*ones(m,1);

    gradW2 = (1/m)*gradW2 + lambda*W2;
    gradW1 = (1/m)*gradW1 + lambda*W1;
    grad_bias1 = (1/m)*grad_bias1 + lambda*bias1;
    grad_bias2 = (1/m)*grad_bias2 + lambda*bias2;

    % all the updates

    dg2s = errors;
    g2_2s = sigmoid_2(h2s);
    g1_2s = sigmoid_2(h1s);
    g = M1M2_to_m(gradW1,gradW2,grad_bias1,grad_bias2);
end
