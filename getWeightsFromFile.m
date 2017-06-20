function [W1,W2,bias1,bias2] = getWeightsFromFile(filename,n0,n1,n2)

ws = readtable(filename,'ReadVariableNames',false);

[W1,W2,bias1,bias2] = m_to_M1M2(ws.Var1,n0,n1,n2);