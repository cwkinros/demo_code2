%demo

% the main function is train_TRM_united_w_param_control which takes many
% inputs. you can either run that directly or run "run_w_params" which
% automates some of the process for you

%-------------------------------------example # 1 -------------------------
disp('example # 1');
maxiter = 100;
sub_maxiter = 0; % default will be 1000 that will be used for PCG and EIGS
altern = true; % compute the full Hessian (false means we do not)
run_w_params('Derm','MBTRM',maxiter,sub_maxiter,altern); % options are TRM, TRM_WS, TRM_MBGD, BTRM, BTRM_WS, MBTRM, MBTRM_WS, STRM, STRM_WS, MBGD, SGD

%--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%-------------------------------------example # 2 -------------------------
disp('example # 2');
% running train_TRM_unite_w_param_control directly on simple problem
WS = false; % will there be weight subsampling?
MS = 2; % MS = 0 (no stochastic training sampling), 1 (single training sample used for stochastic approximation), 2 (batch used)
TRMstep = true; % whether or not the traditional TRM update scheme will be used
GD = false; % are we using a gradient method or gradient & hessian method? False means compute p1, true means compute -gamma*gradient at step
inputs = 1; % very simple imput
outputs = 1; % simple output
W1 = [1;1]; % initial weight values
W2 = [1,1];
bias1 = 1;
bias2 = 1;
n1 = 2; % size of hidden layer
maxiter = 1000; % max # iterations
tofile = false; % so that you can see the results printed
file = 0; % no need for a text file if you are not printing to one
b_w = 0; % we are not using WS so this is not used
b_m_mini = 1; % mini-batch size
b_m_big = 1; % batch size for BTRM, BTRMWS
lr = 1; % set an initial gamma value here
sub_maxit = 100; % max iteration number will be set to 1000 by default for EIGS
altern = false; % altern = true: compute the full hessian, altern = false, never compute the full hessian
time_lim = 0; % we are not setting a time limit

[W1, W2, bias1, bias2, full_error, rolling_t] = train_TRM_united_w_param_control(WS,MS,TRMstep,GD,inputs, outputs, W1, W2, bias1, bias2, n1, maxiter, tofile, file, b_w, b_m_mini, b_m_big, lr, sub_maxit,[],[],altern, time_lim);

disp(strcat('process took ',num2str(0),' secs'));

%--------------------------------------------------------------------------------------------------------------------------------------------------------------------------