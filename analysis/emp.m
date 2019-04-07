%% vector autoregression
data_dir = 'beggs data';
files = dir([data_dir '/*.mat']);
bin_size = 2;
ns = cell(1,length(files));
for i = length(files):-1:1
    disp(['Analyzing ' files(i).name '...'])
    load([data_dir '/' files(i).name]);
    ns{i} = net.generate('autoregressive',...
        'v',spike_times_to_bins(data.spikes,bin_size)',...
        'pmin',1,'pmax',4);
    ns{i}.v = [];
    save('emp_net_bs4')
end; clear i data
save('emp_net_bs4')
%% eigenvalues
cv_me = zeros(1,length(ns));
cv_se = zeros(1,length(ns));
for i = 1 : length(ns)
%     l = eig(ns{i}.A(:,:,1));
    l = eig(sum(ns{i}.A,3));
    cv_me(i) = max(l);
    cv_se(i) = sum(abs(l));
end; clear i l
%% cascade distr
durs = cell(1,length(ns));
for i = length(files):-1:1
    disp(['Analyzing ' files(i).name '...'])
    load([data_dir '/' files(i).name]);
    durs{i} = avl_durations_cell(...
        detect_avalanches(...
        spike_times_to_bins(data.spikes,bin_size)));
end; clear i data
%% simulate
av_T = 1e3;
av_K = 1e6;
durs_sim = cell(1,length(ns));
av_ef = zeros(1,length(ns));
for i = 1:length(ns)
    disp(['Simulating topology ' num2str(i) '/' num2str(length(ns))])
    [x0,Px0] = pings_single(size(ns{i}.A,1));
    av = avl_smp_many(x0,Px0,sum(ns{i}.A,3),av_T,av_K);
    durs_sim{i} = avl_durations_cell(av);
    av_mt = (durs_sim{i}==av_T-1);
    av_end = reshape(cell2mat(av(av_mt)),...
        [size(ns{i}.A(:,:,1),1) sum(av_mt) av_T]);
    av_ef(i) = sum(sum(av_end(:,:,end),1)==size(av_end,1))/size(av_end,2);
    clear av av_mt av_end x0 Px0
    save
end; clear i
%% plot summary
%%
clf
subplot(2,2,1)
semilogy(cv_m,pl_d,'k.','MarkerSize',10)
prettify; xlabel('\lambda_1'); ylabel('\tau')
subplot(2,2,2)
semilogy(cv_s,pl_d,'k.','Markersize',10)
prettify; xlabel('\Sigma\lambda'); ylabel('\tau')
subplot(2,2,3)
plot(cv_m,pl_a,'k.','MarkerSize',10)
prettify; xlabel('\lambda_1'); ylabel('\alpha')
subplot(2,2,4)
plot(cv_s,pl_a,'k.','MarkerSize',10)
prettify; xlabel('\Sigma\lambda'); ylabel('\alpha')
clear durs_max
%% power law pdf
eq_c = @(a,l,xm) l.^(1-a) ./ igamma(1-a,l.*xm);
eq_f = @(x,a,l,xm) (x/xm).^-a .* exp(-l.*x);
eq_l = @(x,a,l) eq_c(a,l,1) .* eq_f(x,a,l,1);
%% plot individual
d = durs;
for i = 1:length(d)
    clf
    x = unique(d{i});
    loglog(x,histcounts(d{i},[x max(x)+1])./length(d{i}),'s')
    hold on
    loglog(x,eq_l(x,pl_dp(1,i,1),pl_dp(1,i,2)))
    axis([10^0 10^4 10^-6 10^0])
    prettify
    pause
end
clear eq* d i x


%% paper figures
color = [2 43.9 69]/100;
%% network
cv_m = abs(cv_me);
cv_s = cv_se;
%% sim
ft_pl_a_sim = ft_pl_sim(1,:,1);
ft_pl_t_sim = 1./ft_pl_sim(1,:,2);
durs_sim_max = cellfun(@max,durs_sim);
ft_pl_t_sim(ft_pl_t_sim>durs_sim_max) = ...
    durs_sim_max(ft_pl_t_sim>durs_sim_max);
ft_t_sim = fit(cv_m',log10(ft_pl_t_sim)','poly1');
ft_a_sim = fit(cv_m',ft_pl_a_sim','poly1');
[ce_r_t_sim,ce_p_t_sim] = corr(cv_m',log10(ft_pl_t_sim)');
[ce_r_a_sim,ce_p_a_sim] = corr(cv_m',ft_pl_a_sim');
%% emp
ft_pl_a_emp = ft_pl_emp(1,:,1);
ft_pl_t_emp = 1./ft_pl_emp(1,:,2);
durs_emp_max = cellfun(@max,durs_emp);
ft_pl_t_emp(ft_pl_t_emp>durs_emp_max) = ...
    durs_emp_max(ft_pl_t_emp>durs_emp_max);
ft_t_emp = fit(cv_m',log10(ft_pl_t_emp)','poly1');
ft_a_emp = fit(cv_m',ft_pl_a_emp','poly1');
[ce_r_t_emp,ce_p_t_emp] = corr(cv_m',log10(ft_pl_t_emp)');
[ce_r_a_emp,ce_p_a_emp] = corr(cv_m',ft_pl_a_emp');
%% simulation - tau
% NOTE: Run synth - tau before this section
figure(1)
% clf
% semilogy(cv_m,ft_pl_t_sim,'k.','MarkerSize',10)
semilogy(cv_m,ft_pl_t_sim,'.','MarkerSize',10,'Color',color)
hold on
x = min(cv_m):1e-3:max(cv_m);
[ci,y] = predint(ft_t_sim,x,.95,'functional','off');
ci = 10.^ci;
y = 10.^y;
% plot(x,y,'k')
% patch([x fliplr(x)],[ci(:,1)' fliplr(ci(:,2)')],'black','FaceAlpha',0.15,...
%     'LineStyle','none')
plot(x,y,'Color',color)
patch([x fliplr(x)],[ci(:,1)' fliplr(ci(:,2)')],color,...
    'FaceAlpha',0.1,'LineStyle','none')
prettify
% xlabel('\lambda_1')
% ylabel('\tau')
% axis([.45 1.05 1 1000])
clear x ci y
%% simulation - alpha
% NOTE: Run synth - alpha before this section
figure(2)
% clf
% plot(cv_m,ft_pl_a_sim,'k.','MarkerSize',10)
plot(cv_m,ft_pl_a_sim,'.','MarkerSize',10,'Color',color)
hold on
x = min(cv_m):1e-3:max(cv_m);
[ci,y] = predint(ft_a_sim,x,.95,'functional','off');
ci(ci<=0) = 0;
y(y<=0) = 0;
plot(x,y,'Color',color)
patch([x fliplr(x)],[ci(:,1)' fliplr(ci(:,2)')],color,'FaceAlpha',0.1,...
    'LineStyle','none')
prettify
% xlabel('\lambda_1')
% ylabel('\alpha')
% axis([.45 1.05 .9 1.6])
clear x ci y
%% empirical - tau
figure(3)
clf
semilogy(cv_m,ft_pl_t_emp,'.','MarkerSize',10,'Color',color)
hold on
x = min(cv_m):1e-3:max(cv_m);
[ci,y] = predint(ft_t_emp,x,.95,'functional','on');
ci = 10.^ci;
y = 10.^y;
plot(x,y,'Color',color)
patch([x fliplr(x)],[ci(:,1)' fliplr(ci(:,2)')],...
    color,'FaceAlpha',0.15, 'LineStyle','none')
prettify
% xlabel('\lambda_1')
% ylabel('\tau')
% axis([.45 1.05 1 1000])
clear x %ci y
%% empirical - alpha
figure(4)
clf
plot(cv_m,ft_pl_a_emp,'.','MarkerSize',10,'Color',color)
hold on
x = min(cv_m):1e-3:max(cv_m);
[ci,y] = predint(ft_a_emp,x,.95,'functional','on');
ci(ci<=0) = 0;
y(y<=0) = 0;
plot(x,y,'Color',color)
patch([x fliplr(x)],[ci(:,1)' fliplr(ci(:,2)')],...
    color,'FaceAlpha',0.15,'LineStyle','none')
prettify
% xlabel('\lambda_1')
% ylabel('\alpha')
% axis([.45 1.05 .9 1.6])
clear x ci y

