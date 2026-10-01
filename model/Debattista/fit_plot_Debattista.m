% fit and plot Debattista et al.



T = readtable('dataset.csv');

budgets = [6.912, 13.824, 27.648, 55.296, 82.994, 110.592, 221.184];
for iB=1:length(budgets)
    T.budget(abs(budgets(iB) - T.budget) < 3) = budgets(iB);
end

% add a 0, 0 point many many times...
T2 = T;
T2.budget(:) = 0;
T2.resolution(:) = 0;
T = [T; T2(1:2:end,:)];

budgets = 0:250;
params = polyfit(T.budget, T.resolution, 3);

pred = params(1) * budgets.^ 3 + params(2) * budgets.^ 2 + params(3) * budgets + params(4);

clf;
plot(T.budget, T.resolution, '.', 'Color', 'blue'); hold on;
plot(budgets, pred, 'Color', 'red');
hold off;
fprintf(1, 'Curve params: %g, %g, %g, %g\n', params(1), params(2), params(3), params(4));

grid on;
xlabel('Budget (Mpixels/s)');
ylabel('Resolution as a multiple of R');

