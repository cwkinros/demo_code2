function [inputs,outputs] = getMNISTdata()

file = fopen('mnist_inputs.txt','r');
st = '';
for i = 1:99
    st = strcat(st,'%f ,');
end
st = strcat(st,'%f \n');


inputs = fscanf(file,st,[100,60000]);
fclose(file);

file = fopen('mnist_outputs.txt','r');
outputs = fscanf(file,'%f, %f, %f, %f, %f, %f, %f, %f, %f, %f \n',[10,60000]);
fclose(file);
