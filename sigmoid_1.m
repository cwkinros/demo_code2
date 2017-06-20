function [g1x] = sigmoid_1(x)

g1x = sigmoid(x).*(1 - sigmoid(x));