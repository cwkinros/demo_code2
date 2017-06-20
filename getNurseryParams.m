function [inputs,outputs] = getNurseryParams()

table = readtable('Nursery.txt','ReadVariableNames',0);
[m,n0_plus1] = size(table);
n0 = n0_plus1 - 1;
inputs = ones(n0,m);
outputs = zeros(5,m);
for i = 1:m
    inputs(1,i) = parents(table.Var1(i));
    inputs(2,i) = has_nurs(table.Var2(i));
    inputs(3,i) = form(table.Var3(i));
    inputs(4,i) = children(table.Var4(i));
    inputs(5,i) = housing(table.Var5(i));
    inputs(6,i) = finance(table.Var6(i));
    inputs(7,i) = social(table.Var7(i));
    inputs(8,i) = health(table.Var8(i));
    outputs(class(table.Var9(i)),i) = 1;
end





function [val] = parents(str)

if strcmp(str,'usual')
    val = 0;
else if strcmp(str,'pretentious')
        val = 1;
    else
        val = 2;
    end
end

function [val] = has_nurs(str)

if strcmp(str,'proper')
    val = 0;
    return;
end
if strcmp(str,'less_proper')
    val = 1;
    return;
end
if strcmp(str,'improper') 
    val = 2;
    return;
end
if strcmp(str,'critical') 
    val = 3;
    return;
end
if strcmp(str,'very_crit')
    val = 4;
    return;
end

function [val] = form(str)

if strcmp(str,'complete') || strcmp(str,'completed')
    val = 0;
else if strcmp(str,'incomplete')
        val = 1;
    else
        val = 2;
    end
end

function [val] = children(str)

if strcmp(str,'1');
    val = 0;
else if strcmp(str,'2');
        val = 1;
    else if strcmp(str,'3');
            val = 2;
        else
            val = 3;
        end
    end
end

function [val] = housing(str)

if strcmp(str,'convenient')
    val=0;
else if strcmp(str,'less_conv')
        val = 1;
    else
        val = 2;
    end
end

function [val] = finance(str)

if strcmp(str,'convenient')
    val = 0;
else
    val = 1;
end

function [val] = social(str)

if strcmp(str,'nonprob')
    val = 0;
else if strcmp(str,'slightly_prob')
        val = 1;
    else
        val = 2;
    end
end

function [val] = health(str)

if strcmp(str,'recommended')
    val = 0;
else if strcmp(str,'not_recom')
        val = 1;
    else
        val = 2;
    end
end

function [val] = class(str)

if strcmp(str,'not_recom')
    val = 1;
else if strcmp(str,'priority')
        val = 2;
    else if strcmp(str,'spec_priority')
            val = 3;
        else if strcmp(str,'very_recom')
                val = 4;
            else 
                val = 5;
            end
        end
    end
end




