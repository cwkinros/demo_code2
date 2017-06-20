function [p1,sigma, converged] = getP1(g,gamma,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs,lambda,WS,indices,b,tol,maxiter,must_converge,shrink)

options.maxit = maxiter;
options.isreal = 1;
options.issym = 0;
options.tol = tol;

[n1,n0] = size(W1);
[n2,~] = size(W2);

n = n2*(n1 + 1) + n1*(n0 + 1);
converged = true;
if gamma == 0
    disp('WHATT');
end
incomplete = true;
while incomplete
    try
        if WS
            %M1 = [zeros(b), eye(b); eye(b), zeros(b)];
            M1 = sparse(2*b);
            M1(b+1:2*b,1:b) = speye(b);
            M1(1:b,b+1:2*b) = speye(b);
            [v,~,flag] = eigs(@(x)M0x_WS(x,g,gamma,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, indices,lambda),2*b,-M1,1,'lr',options);
        else
            %M1 = [zeros(n), eye(n); eye(n), zeros(n)];
            M1 = sparse(2*n);
            M1(n+1:2*n,1:n) = speye(n);
            M1(1:n,n+1:2*n) = speye(n);
            [v,~,flag] = eigs(@(x)M0x(x,g,gamma,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs,lambda),2*n,-M1,1,'lr',options);
        end
        v = real(v);
        if flag > 0
            if must_converge       
                converged = false;
            end
        end
        incomplete = false;
    catch
        gamma = gamma*shrink;
    end
end

if converged
    if WS
        small_p = -sign(g.'*v(b+1:2*b))*gamma*v(1:b)/sqrt(v(1:b).'*v(1:b));
        %small_p = - (gamma^2)*v(1:b) / (g.'*v(b+1:2*b));
        p1 = zeros(n,1);
        for i = 1:b
            p1(indices(i)) = small_p(i);
        end 
        sigma = g.'*small_p + 0.5*small_p.'*Hv_WS(small_p,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs,lambda,indices,b);
        
    else
        p1 = -sign(g.'*v(n+1:2*n))*gamma*v(1:n)/sqrt(v(1:n).'*v(1:n));
        %p1 = - (gamma^2)*v(1:n) / (g.'*v(n+1:2*n));
        sigma = g.'*p1 + 0.5*p1.'*Hv(p1,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs,lambda);
    end
else
    p1 = zeros(n,1);
    sigma = 0;
end

if converged == false
    disp('we got a problem');
end
        