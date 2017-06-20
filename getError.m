function [error] = getError(W1,W2,bias1,bias2,inputs,outputs,lambda,m)

 
h1s_temp = W1*inputs + bias1*ones(1,m);
g1s_temp = sigmoid(h1s_temp);

h2s_temp = W2*g1s_temp + bias2*ones(1,m);
g2s_temp = sigmoid(h2s_temp);


errors = (g2s_temp - outputs);
error = (1/m)*0.5*sum(sum(errors.*errors))+ 0.5*lambda*(sum(sum(W1.*W1)) + sum(sum(W2.*W2)) + sum(bias1.*bias1) + sum(bias2.*bias2));
