function [inputs,outputs] = getIrisData()

table = readtable('Iris.txt','ReadVariableNames',false);

labels = table.Var5;

table(:,5) = [];


inputs = table2array(table).';
[~,m] = size(inputs);
outputs = zeros(3,m);


for i = 1:m
    if strcmp(labels(i),'Iris-setosa')
        outputs(1,i) = 1;
    else if strcmp(labels(i),'Iris-versicolor')
            outputs(2,i) = 1;
        else if strcmp(labels(i),'Iris-virginica')
                outputs(3,i) = 1;
            else
                disp('problem - not a known class');
            end
        end
    end
end
    

