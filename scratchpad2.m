

%% network
p = default_network_parameters;
p.N = 100;
p.N_in = p.N;
p.graph_type = 'wattsstrogatz';
p.frac_conn = 0.1;
p.p_rewire = 0.1;
p.weighting = 'bimodalgaussian';
p.weighting_params = [0.03 0.8 0.9 0.1 0.05 0.01];
p.critical_branching = true;
p.add_noise = false;
p.allow_autapses = false;
p.weigh_by_neuron = true;
[A, B] = network_create(p);
%% 
figure(1)
imagesc(A); prettify; colorbar
%% 
dur = 1e3; iter = 1e4;
%% generate patterns, 1
pats = cell(1,p.N);
for i = 1 : p.N
    x = zeros(p.N,1);
    x(i) = 1;
    pats{i} = x;
end; clear i x
%% generate patterns, 2
% input_activity = 0.1;
% pat_num = 100;
% pats = cell(1,pat_num);
% for i = 1 : pat_num
%     pats{i} = double(rand(p.N,1) < input_activity);
% end; clear i
%% simulation
probs = ones(1,length(pats)) / length(pats);
tic
[Y,pat] = trigger_many_avalanches(A,B,pats,probs,dur,iter);
toc; beep
%% calculate duration
duration = avl_durations_cell(Y);
dur_mean = zeros(1,length(pats));
for i = 1 : length(pats)
    dur_mean(i) = mean(duration(pat==i));
end; clear i
dur_med = zeros(1,length(pats));
for i = 1 : length(pats)
    dur_med(i) = median(duration(pat==i));
end; clear i
%% calculate predictor
T = 100;
H = zeros(length(pats),T);
for i = 1 : length(pats)
    H(i,:) = avl_predictor(A,pats{i},T);
end; clear i
H_m = mean(H.*(1:T),2);
H_m(isnan(H_m)) = 0;
%% plot individual durations
scatter(H_m,dur_mean,'.k')
prettify
xlabel('T_{IF}'); ylabel('mean duration')
%% plot durations by spike counts
[uniq_counts, ~, ic] = unique(spike_counts);
colors = linspecer(length(uniq_counts));
clf; hold on
for i = 1 : length(uniq_counts)
    scatter(H_m(ic==i), dur_mean(ic==i), 100, colors(i,:), '.')
end
hold off
prettify
xlabel('T_{IF}'); ylabel('mean duration')
legs = cell(1,length(uniq_counts));
for i = 1 : length(uniq_counts)
    legs{i} = num2str(uniq_counts(i));
end
legend(legs)
%% fit
f = polyfit(H_m,dur_mean',1);
hold on
x = min(H_m) : 1e-2 : max(H_m);
plot(x,polyval(f,x))
hold off
%% pearson correlation
[r,pval] = corr(H_m,dur_mean')
%% spike count per pattern
spike_counts = sum(cell2mat(pats),1);

%% calculate alphas
alphas = zeros(1,p.N);
xmins = zeros(1,p.N);
for i = 1 : p.N
%     [alphas(i), xmins(i)] = plfit(duration(pat==i),'xmin',1);
    [alphas(i), xmins(i)] = plfit(duration(pat==i));
end
clear i

%% show alphas 
for i = 1 : p.N
    plplot(duration(pat==i), xmins(i), alphas(i));
    prettify; axis([1 1e3 1e-3 1])
    name = ['neuron ' num2str(i) ', alpha = ' num2str(alphas(i))];
    title(name)
    saveas(gcf,[name '.png'])
%     pause
end
clear i

%% modal controllability
mc = control_modal(A);
histogram(mc,30)
prettify
%% finite impulse response
fir = finite_impulse_responses(A,100);
histogram(fir,30)
prettify


%% alphas vs. measures
clf; hold on
scatter(H_m,alphas,'.')
scatter(mc,alphas,'.')
scatter(fir,alphas,'.')
scatter(prob_tot,alphas,'.')
legend({'T_{IF}','modal','finite impulse','strongest path'})
xlabel('metric values');ylabel('\alpha')
hold off
prettify

%%
figure(1)
scatter(mc,alphas,'.'); prettify
xlabel('modal controllability'); ylabel('\alpha')
figure(2)
scatter(fir,alphas,'.'); prettify
xlabel('finite impulse response'); ylabel('\alpha')
% corr(fir,alphas')
figure(3)
scatter(H_m,alphas,'.'); prettify
xlabel('T_{IF}'); ylabel('\alpha')
figure(4)
scatter(prob_tot,alphas,'.'); prettify
xlabel('path strength (AND prob)'); ylabel('\alpha')







