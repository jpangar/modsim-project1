function [S, I, R, W] = simulate_sir(s_0, i_0, r_0, beta, gamma, num_steps)
% Simulate a SIR model
%
% Usage
%   [S, I, R, W] = fcn_simulate(s_0, i_0, r_0, beta, gamma, num_steps)
%
% Arguments
%   s_0 = initial number of susceptible individuals
%   i_0 = initial number of infected individuals
%   r_0 = initial number of recovered individuals
%
%   beta = infection rate parameter
%   gamma = recovery rate paramter
%
%   num_steps = number of simulation steps to simulate
%
% Returns
%   S = simulation history of susceptible individuals; vector
%   I = simulation history of infected individuals; vector
%   R = simulation history of recovered individuals; vector
%   W = simulation week; vector

% Setup
S = zeros(1, num_steps); S(1) = s_0;
I = zeros(1, num_steps); I(1) = i_0;
R = zeros(1, num_steps); R(1) = r_0;
W = 1 : num_steps;

% Run simulation
for step = 1 : (num_steps - 1)
    [S(step+1), I(step+1), R(step+1)] = action_sir(S(step), I(step), R(step), beta, gamma);
end

end