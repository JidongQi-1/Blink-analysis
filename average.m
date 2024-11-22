xValues = [0.25, 0.5, 1, 2, 4, 8, 16, 32];  
figure;

y1 = ((matrix(:, 5) - matrix(:, 1)) ./ matrix(:, 1))*100;
plot1 = plot(xValues, y1, 'r', 'LineWidth', 0.7, 'Color', [1, 0, 0, 0.3]);  
hold on;

y2 = ((matrix(:, 6) - matrix(:, 2)) ./ matrix(:, 2))*100;
plot2 = plot(xValues, y2, 'g', 'LineWidth', 0.7, 'Color', [0, 1, 0, 0.3]);  

y3 = ((matrix(:, 7) - matrix(:, 3)) ./ matrix(:, 3))*100;
plot3 = plot(xValues, y3, 'b', 'LineWidth', 0.7, 'Color', [0, 0, 1, 0.3]);  

y4 = ((matrix(:, 8) - matrix(:, 4)) ./ matrix(:, 4))*100;
errors = (matrix(:, 12) ./ matrix(:, 4)) * 100;
errorBarHandle = errorbar(xValues, y4, errors, 'ko-', 'LineWidth', 1, 'MarkerFaceColor', 'k');

xMin = min(xValues) * 0.8;
xMax = 16;
xlim([xMin, xMax]); 
ylim([-50, 400]); 
xlabel('Spatial Frequency (CPD)'); 
ylabel('Sensitivity Gain (%)');  

yline(0, 'Color', 'k', 'LineWidth', 1, 'LineStyle', ':');
set(gca, 'XScale', 'log', 'YScale', 'linear');
ax = gca;
ax.XTick = [0.25, 0.5, 1, 2, 4, 8, 16];  
ax.YTick = [-50, 0, 100, 200, 300, 400, 500];  
set(gca, 'FontSize', 12);
legend([plot1, plot2, plot3, errorBarHandle], {'A107', 'A180', 'A181', 'Average sensitivity'}, 'Location', 'Best', 'Box', 'off');
set(gca, 'Box', 'off');

hold off;
