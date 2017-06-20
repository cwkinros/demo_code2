function [p0, sigma, valid] = getP0_altern(H,n,g, gamma, WS, indices, b, tol, maxit, must_converge)

% valid refers to a P0 solution where it reached convergence AND it's
% magnitude < gamma

%[p0,flag] = minres(@(v)Hv(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda),-g,0.01,10*n);
%[p0,flag] = cgs(@(v)Hv(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda),-g,0.000001,100000*n);
%[p0, flag] = pcg(@(v)Hv(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda),-g,0.001,10*n);
%[p0, flag] = lsqr(@(v,word)Hv(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda),-g,0.01,10*n);


if WS  
    [p0, flag] = pcg(H,-g,tol,maxit);

%    if type == 1
%        [p0, flag] = pcg(@(v)Hv_WS(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda,indices,b),-g,tol,maxit);
%    else if type == 2
%            [p0, flag] = cgs(@(v)Hv_WS(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda,indices,b),-g,tol,maxit);
%        else if type == 3
%                [p0, flag] = minres(@(v)Hv_WS(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda,indices,b),-g,tol,maxit);   
%            else
%                [p0, flag] = lsqr(@(v,word)Hv_WS(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda,indices,b),-g,tol,maxit);
%            end
%        end
%    end
    
else
    [p0, flag] = pcg(H,-g,tol,maxit);
%    if type == 1        
%        [p0, flag] = pcg(@(v)Hv(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda),-g,tol,maxit);
%    else if type == 2
%            [p0, flag] = cgs(@(v)Hv(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda),-g,tol,maxit);
%        else if type == 3
%                [p0, flag] = minres(@(v)Hv(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda),-g,tol,maxit);
%            else if type == 4
%                    [p0, flag] = lsqr(@(v,word)Hv(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda),-g,tol,maxit);
%                else if type == 5
%                    [p0, flag] = bicgstab(@(v)Hv(v,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,inputs, lambda),-g,tol,maxit);
%                    end
%                end
%            end
%        end
%    end
end
if must_converge == false;
    flag = 0;
end
if sqrt(p0.'*p0) == 0
    flag = 1;
end
%disp(strcat('flag: ',int2str(flag)));
valid = false;
sigma = 0;

if flag == 0
    if sqrt(p0.'*p0) < gamma
        valid = true;
        if WS
            full_p0 = zeros(n,1);
            for i = 1:b
                full_p0(indices(i)) = p0(i);
            end
            sigma = g.'*p0 + 0.5*p0.'*H*p0;
            p0 = full_p0;
        else
            sigma = g.'*p0 + 0.5*p0.'*H*p0;
        end
    end
end
        