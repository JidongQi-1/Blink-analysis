
figure;

spatialFrequency = [0.25; 0.5; 1; 2; 4; 8; 16; 32];  
lastIndex = find(spatialFrequency == 16);

scatter(spatialFrequency, meanThresh(:, 1), 50, 's', 'MarkerFaceColor', [0.6, 0.6, 0.6], 'MarkerEdgeColor', [0.6, 0.6, 0.6]);
hold on;
scatter(spatialFrequency, meanThresh(:, 2), 50, 's', 'MarkerFaceColor', [0, 0, 0], 'MarkerEdgeColor', [0, 0, 0]);
plot(spatialFrequency(1:lastIndex), meanThresh(1:lastIndex, 1), 'Color', [0.6, 0.6, 0.6], 'LineWidth', 1);
plot(spatialFrequency(1:lastIndex), meanThresh(1:lastIndex, 2), 'Color', [0, 0, 0], 'LineWidth', 1);

errorbarObj1 = errorbar(spatialFrequency, meanThresh(:, 1), ...
    stdthresh(:, 1), stdthresh(:, 1), ...  
    'Color', [0.6, 0.6, 0.6], 'LineStyle', 'none');
errorbarObj1.HandleVisibility = 'off';

errorbarObj2 = errorbar(spatialFrequency, meanThresh(:, 2), ...
    stdthresh(:, 2), stdthresh(:, 2), ...  
    'Color', [0, 0, 0], 'LineStyle', 'none');
errorbarObj2.HandleVisibility = 'off';


pValues = evalin('base', 'pValues'); 
nPoints = min(length(spatialFrequency), length(pValues));  

for i = 1:nPoints
    if pValues(i) == 0
        pText = sprintf('p = approx 0'); 
    else
        pText = sprintf('p = %.5f', pValues(i));  
    end
  
    yPosition = meanThresh(i, 1);  
    offset = yPosition * 0.2;  
    %text(spatialFrequency(i), yPosition - offset, pText, ...
         %'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 10, 'Color', 'black');
end

xlabel('Spatial Frequency（CPD）', 'FontSize', 12);  % Adjust font size for X-axis label
ylabel('Sensitivity (1/(75% accuracy contrast threshold))', 'FontSize', 12);

set(gca, 'XScale', 'log', 'YScale', 'log');

yMin = 0;
yMax = 1700;
ylim([0,3000]);
xMin = min(spatialFrequency) * 0.6;
xMax = max(spatialFrequency) * 1.3;
xlim([xMin, xMax]);

ax = gca;
ax.XTick = [0.25, 0.5, 1, 2, 4, 8, 16, 32];  
ax.YTick = [0,100,500,1000,1500,2000,3000]; 

grid off;

legend({'No-Stim. blink', 'Stim. blink'}, ...
    'Box', 'off', 'Location', 'northeast', 'FontSize', 12, 'Orientation', 'vertical');


hold off;
