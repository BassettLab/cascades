function [X, order] = avalanche_smp_many(x0s,probs,A,T,K)
%
%
%   x0s: input patterns
%   probs: probabilty of patterns
%   A: weight matrix, pre-post
%   T: max duration
%   K: number of trials

X = cell(1,K);
prob_cumsum = cumsum(probs);
order = zeros(1,K);

for k = 1 : K
    pat = sum(int8(prob_cumsum < rand)) + 1;
    order(k) = pat;
    x0 = x0s{pat};
    X{k} = avalanche_smp(x0,A,T);
end

end

