function [accuracy] = get_accuracy(inputs,expected_outputs, W1,W2,bias1,bias2)

[~,a] = size(inputs);

h1 = W1*inputs + bias1*ones(1,a);
%disp(h1);
g1 = sigmoid(h1);
%disp(g1);
outputs = sigmoid(W2*g1 + bias2*ones(1,a));

[r,c] = size(outputs);
sum = 0;
%disp(outputs);
for i = 1:c
    max = -1;
    max_idx = -1;
    emax_idx = -1;
    for j = 1:r
        if outputs(j,i) > max
            max = outputs(j,i);
            max_idx = j;
        end
        if expected_outputs(j,i) == 1
            emax_idx = j;
        end  
    end
    if emax_idx == max_idx
        sum = sum + 1;
    end
    %disp('max_idx');
    %disp(max_idx);
    %disp(labels(i));
end

accuracy = sum / c;