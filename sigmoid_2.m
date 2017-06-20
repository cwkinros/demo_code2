function [g2x] = sigmoid_2(x)

g2x = sigmoid_1(x).*(1 - 2*sigmoid(x));