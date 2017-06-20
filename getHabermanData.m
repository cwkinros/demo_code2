function [inputs,outputs] = getHabermanData()

table = readtable('haberman.txt','ReadVariableNames',false);

% delete age column since it is not full

labels = table2array(table(:,4));


%delete labels
table(:,4) = [];


inputs = table2array(table).';
[~,m] = size(inputs);
outputs = zeros(1,m);


for i = 1:m
    if labels(i) == 2
        outputs(1,i) = 1;
    end
end