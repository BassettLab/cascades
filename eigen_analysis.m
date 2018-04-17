
% given A

%% create subnetwork
deg = outdegree(A) + indegree(A);
A_conn = A(deg>0,deg>0);
g=graph_from_matrix(A_conn);
%% eigen analysis
[v,u] = eig(A_conn);
u = diag(u);
[~,idx] = sort(u);
%% max eigenvector components
eigenmags = zeros(size(A_conn,1),1);
for i = idx'
    eigenmags = max(eigenmags, abs(v(:,i)));
end
%% plot graphs
figure(1)
subplot(2,1,1)
plot(g,'NodeCData',eigenmags,...
    'MarkerSize',5,...
    'LineWidth',2*g.Edges.Weight/max(g.Edges.Weight))
colorbar; set(gca,'visible','off'); axis square
subplot(2,1,2)
plot(g,'NodeCData',modal_control(A_conn),...
    'MarkerSize',5,...
    'LineWidth',2*g.Edges.Weight/max(g.Edges.Weight))
colorbar; set(gca,'visible','off'); axis square
%% using eigenvectors as stimuli
dur=20; iter=1e3;
idx_idx = length(u);
num_other = 5; scale = 2; noise_scale = 2;
pats = cell(1,1+num_other);
pats{1} = round(scale * v(:,idx(idx_idx)));
if find(pats{1}<0); pats{1} = -1 * pats{1}; end
pats{1}(pats{1}<0) = 0;
idxs = randperm(length(u),num_other);
probs = zeros(1,1+num_other);
probs(1) = .5;
probs(2:end) = probs(1) / num_other;
for i = 1 : num_other
    pats{i+1} = pats{1} +...
        (rand(size(pats{1}))<0.01) * -1 * noise_scale + ...
        (rand(size(pats{1}))<0.01) * noise_scale;
    if find(pats{i+1}<0); pats{i+1} = -1 * pats{i+1}; end
    pats{i+1}(pats{i+1}<0) = 0;
end; clear i
%%
clf; hold on
for i = 1 : length(pats)
    bar(pats{i})
end; clear i; hold off
%% trigger avalanches
tic
[Y,pat] = trigger_many_avalanches(A_conn,ones(size(A_conn,1),1),...
    pats, probs, dur, iter);
toc
%% duration as function of eigenvalues
durs = avalanche_durations(Y);
histogram(durs,20); axis square; prettify
%% mutual information as function of eigenvectors
p = pat'; p(p~=1) = 2;
mi_pop = mutual_info_pop(Y,p);
plot(mi_pop, 'LineWidth', 2)
hold on; scatter(1,h(p),'filled','r'); hold off
prettify; axis square; xlabel('t'); ylabel('MI')
axis([0 dur+1 0 ceil(h(p))])

%% random stimuli
dur=10; iter=2e2;
num_other = 10; scale = 5; noise_scale = scale;
pats = cell(1,1+num_other);
pats{1} = double(rand(length(u),1) < .001);
if find(pats{1}<0); pats{1} = -1 * pats{1}; end
pats{1}(pats{1}<0) = 0;
idxs = randperm(length(u),num_other);
probs = zeros(1,1+num_other);
probs(1) = .5;
probs(2:end) = probs(1) / num_other;
for i = 1 : num_other
    %     pats{i+1} = pats{1} + noise_scale * ones(size(pats{1})) ...
    %         - 2 * noise_scale * ones(size(pats{1})) .* ...
    %         (rand(size(pats{1})) < 0.5);
    pats{i+1} = pats{1} +...
        (rand(size(pats{1}))<0.01) * -1 * noise_scale + ...
        (rand(size(pats{1}))<0.01) * noise_scale;
    if find(pats{i+1}<0); pats{i+1} = -1 * pats{i+1}; end
    pats{i+1}(pats{i+1}<0) = 0;
end; clear i
%% trigger avalanches
tic
[Y,pat] = trigger_many_avalanches(A_conn,ones(size(A_conn,1),1),...
    pats, probs, dur, iter);
toc
%% duration a.f.o eigenvalues
durs = avalanche_durations(Y);
histogram(durs,20); axis square; prettify
%% mutual information a.f.o. eigenvalues
p = pat'; p(p~=1) = 2;
mi_pop = mutual_info_pop(Y,p);
plot(mi_pop, 'LineWidth', 2)
hold on; scatter(1,h(p),'filled','r'); hold off
prettify; axis square; xlabel('t'); ylabel('MI')
axis([0 dur+1 0 ceil(h(p))])
%%
one = find(p==2)';
for i = one
    plot_avalanche(Y(:,:,i),avalanche_transitions(Y(:,:,i),A_conn),true)
    pause
end
%% plot average activity
errorbar(1:dur, mean(mean(Y,1),3), mean(var(Y,0,1),3), 'LineWidth',2)
prettify; axis square; %axis([0 6 0 0.05])

%%
clf; hold on
[~,idx] = sort(u);
for i = idx(end-8:end-6)'
    bar(v(:,i))
end; hold off
axis square; prettify
%%
idx(end-10:end)'
u(idx(end-10:end))'

%%


%%
x0=-1*v(:,88); x=[];
for i=1:10; x=[x A_conn^i*x0]; end;
plot(x','LineWidth',2); prettify; axis square

%%
dur=20; iter=300;
pat_size = 2;
idx = {{n(randperm(length(n),pat_size))},...
    {n(randperm(length(n),pat_size))},...
    {n(randperm(length(n),pat_size))},...
    {n(randperm(length(n),pat_size))}...
    };
pats = {-1*v(:,idx(end-1)),};
[Yp,pat] = trigger_many_avalanches(A_conn,ones(size(A_conn,1),1),...
    pats, ones(1,length(pats))/length(pats),dur,iter);


%% WRG
params = default_network_parameters;
A = network_create(params);
[v,d] = eig(A);
d = diag(d);
%% eigenvalues
bar(d); prettify
%% dominant eigenvector
bar(v(:,1)); prettify
%%
pats = cell(1,params.num_nodes);
for i = 1 : params.num_nodes
    pats{i} = v(:,i);
    if ~isreal(d(i))
        if i < params.num_nodes &&...
                abs(d(i)) == abs(d(i+1))
            pats{i} = v(:,i) + v(:,i+1);
        elseif abs(d(i)) == abs(d(i-1))
            pats{i} = v(:,i) + v(:,i-1);
        end
    end
    if find(pats{i}<0); pats{i} = -1 * pats{i}; end
    pats{i}(pats{i}<0) = 0;
    pats{i} = abs(pats{i});
end; clear i
%%
clf; hold on
for i = 1 : length(pats)
    bar(pats{i})
    if ~isreal(pats{i})
        disp('not real')
    end
    if min(pats{i}) < 0
        disp('negative')
    end
end; clear i; hold off
%%
dur=5; iter=3e3;
% mi_pops = zeros();
for i = 1 %: length(diag(d))
    probs = 0.5*ones(1,params.num_nodes)/(params.num_nodes-1);
    probs(i) = 0.5;
    tic
    [Y,pat] = trigger_many_avalanches(A, ones(params.num_nodes,1), pats,...
        probs, dur, iter);
    toc
    p = pat'; p(p~=1) = 2;
    mi_pop = mutual_info_pop(Y,p);
end; clear i
%%
plot(mi_pop, 'LineWidth', 2)
hold on; scatter(1,h(p),'filled','r'); hold off
prettify; axis square; xlabel('t'); ylabel('MI')
axis([0 dur+1 0 ceil(h(p))])







