function [gx] = sigmoid(x)

gx = 1 ./ (1 + exp(-x));