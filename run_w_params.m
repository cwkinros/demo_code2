function [] = run_w_params(dataset,tests,maxiter,sub_maxiter, altern)
% this function gets the hyperparameters chosen through the hyperparameter
% experiment procedure

[sgd_lr,sgd_lr_mb,lr,lr_mb,b_m_mini,b_m_mini_MBGD,b_m_big,b_w] = getParams(dataset);

% you can change the time limit as you wish or set it to 0 in order to have
% no time limit
time_lim = 60*30;

% here is where we run the test
run_test(dataset,sgd_lr,sgd_lr_mb,lr,lr_mb,b_w,b_m_mini,b_m_mini_MBGD,b_m_big,tests,false,0,0,maxiter,10,sub_maxiter, altern, time_lim);

function [sgd_lr,sgd_lr_mb,lr,lr_mb,b_m_mini,b_m_mini_MBGD,b_m_big,b_w] = getParams(dataset)
% this function collects the hyperparamters from a text file that was
% produced after hyperparameter testing
params = readtable(strcat('results/',dataset,'params_results.txt'));
sgd_lr = params.sgdlr;
sgd_lr_mb = params.sgdlrmb;
lr = params.lr;
lr_mb = params.lrmb;
b_w = params.bw;
b_m_mini = params.bmmini;
b_m_mini_MBGD = params.bmmini_MBGD;
b_m_big = params.bmbig;