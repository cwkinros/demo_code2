function [inputs,outputs] = getDermData()

table = readtable('dermatology.txt','ReadVariableNames',false);

% delete age column since it is not full
table(:,34)=[];

labels = table2array(table(:,34));


%delete labels
table(:,34) = [];


inputs = table2array(table).';
[~,m] = size(inputs);
outputs = zeros(6,m);


for i = 1:m
    outputs(labels(i),i) = 1;
end