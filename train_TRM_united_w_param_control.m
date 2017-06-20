function [W1, W2, bias1, bias2, full_error, rolling_t] = train_TRM_united_w_param_control(WS,MS,TRMstep,GD,inputs, outputs, W1, W2, bias1, bias2, n1, maxiter, tofile, file, b_w, b_m_mini, b_m_big, lr, sub_maxit,test_inputs,test_outputs,altern, time_lim)

% determine n0 and n2 values
[n0,m] = size(inputs);
[n2,~] = size(outputs);

% set lambda
lambda =10^(-10);

% initialize intermediate vectors in the network
h1s = zeros(n1,m);
g1s = zeros(n1,m);
h2s = zeros(n2,m);
g2s = zeros(n2,m);

%initialize trust region method hyperparameters
ub = 0.8;
lb = 0.2;
grow = 2.0;
shrink = 0.5;

% compute n (total # parameters)
n = n0*n1 + n1*n2 + n1 + n2;

% initialize gamma (will be re-initialized to lr for stochastic methods)
gamma = 1;

% check if this is a hybrid method (TRM & GD based method)
if TRMstep && GD
    hybrid = true;
    TRMstep = false;
else
    hybrid = false;
end

% check if this uses the traditional trust region size update
if TRMstep
    b_m = b_m_big;
else
    b_m = b_m_mini;
end

% define num to be the number of samples used to estimate the gradient and
% the Hessian (in TRM cases) at each step
if MS == 1
    num = 1;
else if MS == 2
        num = b_m;
    else
        num = m;
    end
end

% sub_tol is the tolerance used for PCG and EIGS matlab methods
sub_tol = 0.001;

% must_converge is kept as false when sub_maxit > 0 which is when we want
% early stopping for PCG and EIGS. Otherwise, these methods must converge
% and are given 1000 initial maxiteration #
must_converge = false;
if sub_maxit == 0
    sub_maxit = 1000;
    must_converge = true;
end

% this is the tolerance for the stopping condition for TRM, TRMWS, BTRM,
% BTRMWS
tol = 10^-8;

% all intialized
rho = 0;
sigma = 0;
step = 0;

% if we want to save results, we print the headers of the file
if tofile
    fprintf(file,'TRM WS=%d, MS=%d, TRMstep=%d: ub=%f, lb=%f, grow=%f,shrink=%f, b_w=%d,b_m=%d, lr=%f, lambda=%e, n=%d, n0=%d, n1=%d, n2=%d, sub_tol=%f, sub_maxit=%d, tol=%e, m=%d , altern=%d \n',WS,MS,TRMstep,ub,lb,grow,shrink,b_w,b_m,lr,lambda,n,n0,n1,n2,sub_tol,sub_maxit,tol,m,altern);
    fprintf(file,'time, iter_t, subset_m_time, g_time, subset_w_time, p1_time, t2, t3, H_time, total error, total gmag, rho, sigma, gamma, step, approx error, approx gmag, train accuracy, test accuracy \n');
end

% the total CPU time elapsed so far 
rolling_t = 0;

% these two conditions means that we are using either STRM, STRMWS, MBTRM
% MBTRM, SGD or MBGD
if MS > 0 && TRMstep == false
    gamma = lr;
end

% this is for stopping condition of STRM, STRMWS, MBTRM
% MBTRM, SGD and MBGD
if MS == 1 || (MS == 2 && TRMstep == false) || GD == true
    is = randperm(m,m);
    if MS == 2
        check_interval = min(m/b_m_mini,b_m_big);
    else
        check_interval = min(m,b_m_big);
    end
    interval_sum = 0;
    nearly_converged = 0;
    last_error_avg = 0;
    current_min = inf;
    since_last_min = 0;
end


full_error = inf;

% neednewh = true when a step is taken and the previous hessian and
% gradient information is no longer the information for the weights
neednewh = true;

% main section
for k = 1:maxiter
    
    %----------subsample training set into input_set and output_set -------
    if MS == 1
        
        % this is not timed and just used for our results (not in
        % the optimization method)
        [g_total,~,~,~,~,~,~,~,full_error] = getG(W1,W2,bias1,bias2,inputs,outputs,lambda,m);
       
        tic
        idx = mod(k,m);
        if idx == 0
            idx = m;
        end
        i = is(idx);
        input_set = inputs(:,i);

        output_set = outputs(:,i);
        subset_m_time = toc;
    else if MS == 2
            
            % this is not timed and just used for our results (not in
            % the optimization method)
            [g_total,~,~,~,~,~,~,~,full_error] = getG(W1,W2,bias1,bias2,inputs,outputs,lambda,m);
          
            tic
            is = randperm(m,b_m);
            input_set = inputs(:,is);
            output_set = outputs(:,is);
            subset_m_time = toc;
        else
            input_set = inputs;
            output_set = outputs;
            subset_m_time = 0;
        end
    end
    %----------------------------------------------------------------------
            
    %-----------------compute gradient ------------------------------------
    if MS ~= 0 || neednewh 
        tic
        [g_full,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,last_error] = getG(W1,W2,bias1,bias2,input_set,output_set,lambda,num);
        g_time = toc;
    else
        g_time = 0;
    end
    %----------------------------------------------------------------------
    
    %---------------------make subsampled gradient-------------------------
    if WS
        tic;
        indices = randperm(n,b_w);
        g = zeros(b_w,1);
        for i=1:b_w
            g(i) = g_full(indices(i));
        end 
        subset_w_time = toc;
    else
        b_w = n;
        g = g_full;
        indices = 0;
        subset_w_time = 0;
    end
    %----------------------------------------------------------------------
    
    %----------------------compute p1--------------------------------------
    if GD
        tic
        p1 = -gamma*g_full;
        p1_time = toc;
        H_time = 0;
    else
        if altern
            
            if MS ~= 0 || WS ~= 0 || neednewh 
                tic
                H = getH(W1, W2, g1s, g1_1s, g2_1s, g2_2s, g1_2s, dg1s, dg2s, input_set, lambda, WS, indices, b_w);
                H_time = toc;
            else
                H_time = 0;
            end
            tic
            [p1, sigma_p1, valid_p1] = getP1_altern(H,g,gamma,n,WS,indices,b_w,sub_tol,sub_maxit,must_converge);
            p1_time = toc;
            
               
        else
            H_time = 0;
            tic
            [p1, sigma_p1, valid_p1] = getP1(g,gamma,W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,input_set,lambda,WS,indices,b_w,sub_tol,sub_maxit,must_converge,shrink);
            p1_time = toc; 
        end
    end
    %----------------------------------------------------------------------

    %---------------------compute p0, decide on p, trust region update-----    
    if TRMstep
        if altern
            if MS ~= 0 || WS ~= 0 || neednewh 
                tic
                [p0, sigma_p0, valid_p0] = getP0_altern(H,n,g,gamma,WS,indices,b_w,sub_tol,sub_maxit,must_converge);
                t2 = toc;
            else
                t2 = 0;
            end
        else          
            tic
            [p0, sigma_p0, valid_p0] = getP0(W1,W2,g1s,g1_1s,g2_1s,g2_2s,g1_2s,dg1s,dg2s,input_set,lambda,g,gamma,WS,indices,b_w,sub_tol,sub_maxit,must_converge);
            t2 = toc;
        end
        
        tic
        step = 2; % 2 indicates no valid step, 1 indicates p1, 0 indicates p0
        if valid_p1 && valid_p0
            if sigma_p1 < sigma_p0
                step = 1;
            else
                step = 0;
            end
        else
            if valid_p1
                step = 1;
            else if valid_p0
                    step = 0;
                end
            end
        end

        if step == 2
            if WS == false    
                if must_converge && sub_maxit < 10000
                    sub_maxit = sub_maxit + 100;
                end
            end
            if must_converge == false
               gamma = gamma*shrink; 
            end
            continue;
        else if step == 1
                p = p1;
                sigma = sigma_p1;
            else
                p = p0;
                sigma = sigma_p0;
            end
        end

        [P1,P2,pb1,pb2] = m_to_M1M2(p,n0,n1,n2);
        next_error = getError(W1 +P1, W2 +P2, bias1 +pb1,bias2 +pb2,input_set,output_set,lambda,num);
        rho = (next_error - last_error) / sigma;         
        if rho == 0
            disp(strcat('RHO IS ZERO and step: ',int2str(step)));
            rho = 1;
        end
        if rho > lb && sigma < 0
            neednewh = true;
            [W1,W2,bias1,bias2] = addP(p,n0,n1,n2,W1,W2,bias1,bias2);
            if rho > ub && gamma*grow < inf
                gamma = max(gamma,sqrt(p'*p)*grow);
            end
        else   
           neednewh = false;
           if gamma*shrink > 10^-20
               gamma = gamma * shrink;
           end
        end
        
        % check if stopping condition has been met
        if ((1/m)*sqrt(g_full'*g_full) < tol)
            break;
        end
        
        t3 = toc;
        
        % if hybrid, set it back to MBGD
        if hybrid
            GD = true;
            TRMstep = false;
            %MS = 2;
            num = b_m;
            neednewh = true;
        end
    %----------------------------------------------------------------------
    
    %--------------------update using p1 and check for stopping criteria---
    else
        % take the step (p1 which is gamma*gradient or p1 from TRM using a
        % stochastic approximation)
        tic
        [W1,W2,bias1,bias2] = addP(p1,n0,n1,n2,W1,W2,bias1,bias2);
        t2 = toc;           
           
        % we only consider converged TRS steps (where valid_p1 == true) for
        % checking progress
        if GD || (GD == false && valid_p1)
            % update schedule
            tic
            
            % interval sum is the sum of errors over an interval
            interval_sum = interval_sum + last_error;
            
            % once the interval is complete we check if there has been
            % progress
            if mod(k,check_interval) == 0
                error_avg = interval_sum / (check_interval*n2);
                interval_sum = 0;
                diff = last_error_avg - error_avg;
                if diff <= 10^-6 && last_error_avg > 0
                    % if no progress has been seen for a while we end
                    if nearly_converged > 2 || since_last_min > 10
                        break;
                    else
                        % if no progress was seen in this last step we
                        % shrink gamma and if it's the hybrid method we run
                        % a step of TRM
                        since_last_min = since_last_min + 1;
                        nearly_converged = nearly_converged + 1;
                        gamma = gamma/2;
                        if hybrid
                            GD = false;
                            TRMstep = true;
                            %MS = 0;
                            num = m;
                        end
                    end
                else
                    nearly_converged = 0;
                end
                
                % this tracks last min -> a secondary measure for stopping
                % (maybe I should add this to the thesis?) to consider the
                % case where the result oscillates for a long time
                if error_avg < current_min
                    current_min = error_avg;
                    since_last_min = 0;
                end
                last_error_avg = error_avg;
            end
            t3 = toc;
        else
            % if valid_p1 == false then the p1 computation did not converge
            % so we increase the sub_maxit (the idea of these are to use
            % the proper p1 step so we require convergence)
            if sub_maxit < 10000
                sub_maxit = sub_maxit + 100;
            end
            continue;
        end
       
    end
    

    % sum up the time taken
    t = subset_m_time + g_time + subset_w_time + p1_time + t2 + t3 + H_time;
    
    % update rolling_t
    rolling_t = rolling_t + t;
    
    % if the user decides to set a time limit check if rolling_t is larger
    if time_lim > 0 && rolling_t > time_lim
        break;
    end
        
    % for display purposes
    if mod(k,5000) == 0;
        disp(k);
    end
    
    % to get the correc values for the print
    if MS == false
        full_error = last_error;
        g_total = g_full;
    end
    
    % get accuracy updates
    if mod(k,10) == 1
        train_accuracy = get_accuracy(inputs,outputs,W1,W2,bias1,bias2);
        test_accuracy = 0;%get_accuracy(test_inputs,test_outputs,W1,W2,bias1,bias2);
        %disp(train_accuracy);
    else
        train_accuracy = 0;
        test_accuracy = 0;
    end
    
    
    % change to TRM for hybrid when appropriate 
    if hybrid 
        if TRMstep
            MS = 0;
            neednewh = true;
        else
            MS = 2;
        end
    end
    
    % print info to file
    if tofile
        fprintf(file,'%d, %d, %d, %d, %d, %d, %d, %d, %d, %e, %e, %e, %f, %e, %d, %f, %e, %f, %f \n', rolling_t, t, subset_m_time, g_time, subset_w_time,p1_time,t2,t3,H_time, full_error, (1/m)*sqrt(g_total.'*g_total), rho, sigma, gamma, step, last_error, (1/m)*sqrt(g_full.'*g_full), train_accuracy, test_accuracy);
    else
        disp(full_error);
    end
end



if k < maxiter
    train_accuracy = get_accuracy(inputs,outputs,W1,W2,bias1,bias2);
    test_accuracy = 0; %get_accuracy(test_inputs,test_outputs,W1,W2,bias1,bias2);
    [g_total,~,~,~,~,~,~,~,full_error] = getG(W1,W2,bias1,bias2,inputs,outputs,lambda,m);
    t = subset_m_time + g_time + subset_w_time + p1_time + t2 + t3;
    rolling_t = rolling_t + t;
    if mod(k,50) == 0;
        disp(k);
    end
    
    if MS == false
        full_error = last_error;
        g_total = g_full;
    end
    
    if tofile
        fprintf(file,'%d, %d, %d, %d, %d, %d, %d, %d, %e, %e, %e, %f, %e, %d, %f, %e, %f, %f  \n', rolling_t, t, subset_m_time, g_time, subset_w_time,p1_time,t2,t3, full_error, (1/m)*sqrt(g_total.'*g_total), rho, sigma, gamma, step, last_error, (1/m)*sqrt(g_full.'*g_full), train_accuracy, test_accuracy);
    else
        disp(full_error);
    end
end