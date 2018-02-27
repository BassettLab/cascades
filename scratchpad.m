% scratchpad.m
% simulation of networks
% Written by Harang Ju. January 29, 2018.

%% Initialize
disp('Initializing...')
p = default_network_parameters;
p.num_nodes = 30;
p.num_nodes_input = 30;
p.num_nodes_output = 30;
p.frac_conn = 2e-1;
p.graph_type = 'WRG';
p.exp_branching = 1;
[A, B, C] = network_create(p);

%% Analysis
disp('Analyzing...')
sig = branching(A);
disp(['avg branching parameter: ' num2str(mean(sig)) '+-' ...
    num2str(std(sig)/p.num_nodes)])
u_t = zeros(p.num_nodes, 1);
u_t(find(B,1), 1) = 1;
Y_t = trigger_avalanche(A, B, u_t, 10);
clf; plot_summary(A, avalanche_size_analytical(A, B, 5),...
    ave_control(A), modal_control(A), Y_t, avalanche_transitions(Y_t, A))

%% Mutual information

max_mi = cell(1,p.num_nodes_input);
max_nodes = cell(1,p.num_nodes_input);
max_time = cell(1,p.num_nodes_input);
probs = [0.5 0.5];
iter = 1e3; dur = 10;
input_nodes = find(B);
for i = 1:length(input_nodes)
    disp(i)
    pattern = {{input_nodes(i)}, {}};
    [Y, pat] = trigger_many_avalanches(A, B, pattern, probs, dur, iter);
    info = mutual_info(Y, pat);
    [max_mi{i}, max_nodes{i}, max_time{i}] = mutual_info_max(info, C);
end
clear probs iter dur input_nodes i pattern Y pat info
% shuffle input output nodes

