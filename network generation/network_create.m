function [A, B, C] = network_create(p)
%create_network Generates network with given parameters
%   p: network parameters, default parameters generated by
%       default_network_parameters()
% returns
%   A: connectivity/weight matrix, [pre- X post-]
%   B: input connectivity/weight vector, [N X 1]
%   C: output connectivity/weight vector, [N X 1]

num_edges_max = p.N * (p.N - 1);
degree_max = num_edges_max / p.N;
num_edges = ceil(p.frac_conn * num_edges_max);
% degree = 2*ceil(p.frac_conn * degree_max);
degree = ceil(p.frac_conn * degree_max);
% wiring
A = network_connect(p.graph_type, p.N, p.frac_conn, num_edges,...
    degree, p.p_rewire);
% weighting
A(A>0) = A(A>0) + 2*p.noise_ampl*rand(size(A(A>0))) - p.noise_ampl;
A = network_weigh(A, p.weighting, p.weighting_params, p.weigh_by_neuron);
if p.add_noise
    A(A>0) = A(A>0) + 2*p.noise_ampl*rand(size(A(A>0))) - p.noise_ampl;
end
A = weights_bound(A, p.weight_min, p.weight_max);
if ~p.allow_autapses
    A = A .* ~diag(ones(p.N,1));
end
if p.critical_branching
    b = branching(A);
    b(b==0) = 1;
    A = A ./ b;
end
if p.critical_convergence
    c = convergence(A)';
    c(c==0) = 1;
    A = A ./ c;
end
% input & output connectivity
idx_io = randperm(p.N, p.N);
idx_i = idx_io(1:p.N_in);
idx_o = idx_io(end+1-p.N_out:end);
B = zeros(p.N, 1); B(idx_i) = 1;
C = zeros(p.N, 1); C(idx_o) = 1;
% display statistics

end
