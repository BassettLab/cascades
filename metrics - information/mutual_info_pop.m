function mi_pop = mutual_info_pop(Y,pat)
%mutual_info_pop(Y) returns mutual info of the whole network at time t
%   Y: avalanches, [neurons by duration by iterations]
%   pat: patterns, [iterations by 1]
%returns
%   mi: [1 by duration]

code = pop_code(Y,1:size(Y,1));
mi_pop = zeros(1,size(Y,2));
for i = 1 : size(Y,2)
    mi_pop(i) = mi(pat,code(i,:)');
end; clear i

end

