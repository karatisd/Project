%% Group 7
% Dimitrios Ioannidis (10415)
% Dimitrios Karatis (10775)

%% Zitima 1
% Synartisi pou emfanizei to istogramma kai thn PDF
function Group7Exe1Fun1(data, num_bins, x_range, pdf_values, dist_name, TMS_status)
    figure;
    histogram(data, num_bins, 'Normalization', 'pdf', 'FaceColor', [0.7 0.7 0.7]);
    hold on;
    plot(x_range, pdf_values, 'LineWidth', 2);
    xlabel('EDduration (seconds)');
    ylabel('Density');
    title(['EDduration ' TMS_status ' TMS - ' dist_name]);
    legend('Empirical PDF', ['Fitted ' dist_name ' PDF']);
    grid on;
end