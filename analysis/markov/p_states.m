function P = p_states(p1, T, tmax)
%p_states
%
%   Parameters
%       p1: probability of being in initial states
%       T: transition probabilities
%       tmax: how many steps into the future
%
%   Returns
%       P: probability of being in states at time t

Ns = size(T,1);
P = zeros(Ns,tmax);
P(:,1) = p1;
for t = 2 : tmax
    P(:,t) = T * P(:,t-1); %sum(T .* P(:,t-1), 1)';
end

end

