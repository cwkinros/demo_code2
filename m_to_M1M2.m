function [M1,M2,bias1,bias2] = m_to_M1M2(m,n0,n1,n2)
i = 1;
M1 = reshape(m(i:(i-1) + n0*n1),n1,n0);
i = i + n0*n1;
bias1 = m(i:(i-1) + n1);
i = i + n1;
M2 = reshape(m(i:(i-1) + n1*n2),n2,n1);
i = i + n1*n2;
bias2 = m(i:(i-1) + n2);

return;

r1 = n1;
c1 = n0;

r2 = n2;
c2 = n1;



[n,~] = size(m);
if n == n1*n0 + n2*n1
    hasbias = false;
else
    hasbias = true;
end

M1 = zeros(r1,c1);
M2 = zeros(r2,c2);
if hasbias
    bias1 = zeros(r1,1);
    bias2 = zeros(r2,1);
else
    bias1 = NaN;
    bias2 = NaN;
end

count = 1;
for i = 1:r1
    for j = 1:c1
        M1(i,j) = m(count);
        count = count + 1;
    end
    if hasbias
        bias1(i) = m(count);
        count = count + 1;
    end
end

for i = 1:r2
    for j = 1:c2
        M2(i,j) = m(count);
        count = count + 1;
    end
    if hasbias
        bias2(i) = m(count);
        count = count + 1;
    end
end