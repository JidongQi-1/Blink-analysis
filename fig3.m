meanThresh = evalin('base', 'meanThresh');  
std2con = evalin('base', 'std2con');  
pValues = evalin('base', 'pValues');  

spatialFrequencies = [0.25, 0.5, 1, 2, 4, 8, 16];  

sensitivityGain = zeros(1, length(spatialFrequencies));
gainError = zeros(1, length(spatialFrequencies));

for i = 1:length(spatialFrequencies)
    condition1_value = meanThresh(i, 1);  
    condition2_value = meanThresh(i, 2);  

    sensitivityGain(i) = ((condition2_value - condition1_value) / condition1_value) * 100;

    gainError(i) = (std2con(i) / condition1_value) * 100;  
end

figure;

scatterHandle = scatter(spatialFrequencies, sensitivityGain, 50, ...
    's', 'MarkerFaceColor', [0, 0, 0], 'MarkerEdgeColor', [0, 0, 0]); 
hold on;

scatterHandle.MarkerEdgeAlpha = 1;  
scatterHandle.MarkerFaceAlpha = 1;  

errorbarHandle = errorbar(spatialFrequencies, sensitivityGain, gainError, gainError, ...
    'LineStyle', 'none', 'LineWidth', 0.5, 'Color', [0, 0, 0]);  

lineHandle = plot(spatialFrequencies, sensitivityGain, 'Color', [0,0,0], ...
    'LineWidth', 0.5);  

lineHandle.Color = [0,0,0, 0.2];  

xlabel('Spatial Frequency (CPD)');
ylabel('Sensitivity Gain (%)');

set(gca, 'XScale', 'log', 'YScale', 'linear');

ax = gca;
ax.XTick = [0.25, 0.5, 1, 2, 4, 8, 16];  
ax.YTick = [-50,0,100,200,300,400,500];  

ylim([-50, 500]); 
xlim([0.15, 32]); 

set(gca, 'FontSize', 12);

for i = 1:length(spatialFrequencies)
    xPosition = spatialFrequencies(i) * 1.1;  
    yPosition = sensitivityGain(i);  

    if pValues(i) < 0.001
        pValueText = 'p = approx. 0';  
    else
        pValueText = sprintf('p = %.3f', pValues(i));  
    end

    text(xPosition, yPosition, pValueText, ...
         'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
         'FontSize', 10, 'Color', 'black');
end

yline(0, 'Color', 'k', 'LineWidth', 1, 'LineStyle', ':');

hold off;
