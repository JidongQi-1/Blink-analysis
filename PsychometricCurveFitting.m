function PsychometricCurveFitting(trials)

	target = 0.75;
	SFs = unique([trials.gaborSpFreq]);
	nSFs = size(SFs,2);
	for(iSF = nSFs:-1:1)
		trials_{iSF} = trials([trials.gaborSpFreq] == SFs(iSF));
        numTrials = length(trials_{iSF});
        if numTrials > 3000
           trials_{iSF} = trials_{iSF}(end-2999:end);  % Keep only the last 3000 trials
        end
	end
	trials = trials_;

	figure('color', 'w'); pause(0.1); jf = get(handle(gcf),'javaframe'); jf.setMaximized(1); pause(0.5);
	nCols = 4;
	nRows = 2;

	colors = {[0.6,0.6,0.6], [0,0,0]};
	hAligns = { 'left', 'right' };	
	%names = {'No-Stimulus Blink', 'Stimulus Blink'};

    %colors = {[0.4, 0.6, 0.8],[1, 0.4, 0.4]};  
	names = {'No-Stimulus Blink', 'Stimulus Blink'};

    meanThresh = zeros(nSFs, 2);
    pValues = NaN(nSFs, 1);
    meanSen = zeros(nSFs, 2);
    onesemThresh = zeros(nSFs, 2);
    stdThresh = zeros(nSFs, 2);
    std2con = NaN(nSFs, 1);
    
    hWaitbar = waitbar(0, 'Processing bootstrap iterations...');


	for (iSF = nSFs:-1:1 )
		if( isempty(trials{iSF}) )
			h(iSF) = [];
			continue;
		end

		subplot(nRows,nCols,iSF); hold on; h = [];

		trials_ = {trials{iSF}([trials{iSF}.tBlinkBeepOn] < [trials{iSF}.tRampOn]), trials{iSF}([trials{iSF}.tBlinkBeepOn] > [trials{iSF}.tRampOn])};

        %edited
       
        %maxContrast = max([trials{iSF}.gaborAmp]/128);
        maxContrast = 2;

        lowerBound = 1e-4; % 


        minContrast = min([trials{iSF}.gaborAmp]/128);


        if minContrast <= 0
            minPositiveValue = min([trials{iSF}.gaborAmp]/128);
            minContrast = max(minPositiveValue, eps);  
        end

        minContrast = max(minContrast, lowerBound);
        bins = logspace(log10(minContrast), log10(maxContrast), 10); 
        nBins = length(bins) - 1;



        %rangeContrast = maxContrast - minContrast;
        %binSize = rangeContrast / 10;
        %bins = minContrast:binSize:maxContrast;
        %nBins = length(bins) - 1;
        arrayfun(@(x) xline(x, 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'LineStyle', '-', 'Alpha', 0.1), bins);

       

		for k = 1:2
            contrasts = [trials_{k}.gaborAmp] / 128;

            
            if SFs(iSF) == 2
                [~, sortedIdx] = sort(contrasts);  
                trials_{k}(sortedIdx(1:30)) = [];  
                contrasts(sortedIdx(1:30)) = [];   
            end



            if SFs(iSF) == 2
                excludeMask = contrasts >= 10^-2 & contrasts <= 10^-1;  
                trials_{k}(excludeMask) = [];  
                contrasts(excludeMask) = [];  
            end

            trials_{k}(contrasts <= 0) = [];
            contrasts(contrasts <= 0) = [];
            crctRate(k).rates = zeros(1, nBins);
            crctRate(k).contrasts = zeros(1, nBins);
            crctRate(k).nRates = nBins;



            if k == 1
                markerStyle = 'o';  % Stimulus Blink
                markerFaceColor = 'none';
            else

                markerStyle = 's';  % No-Stimulus Blink
                markerFaceColor = [0,0,0];
                
            end


            lastLabelPos = NaN; 
            labelOffset = 0.05; 

            for iBin = 1:nBins
                binMask = contrasts >= bins(iBin) & contrasts < bins(iBin + 1);
                numPointsInBin = sum(binMask);


                if any(binMask)

                    rate = sum([trials_{k}(binMask).trialType] == 'c') / numPointsInBin;
                    contrast = mean(contrasts(binMask));
                    crctRate(k).rates(iBin) = rate;
                    crctRate(k).contrasts(iBin) = contrast;

                    
                   

                    yPos = rate;
                    if ~isnan(lastLabelPos) && abs(lastLabelPos - yPos) < labelOffset
                        yPos = lastLabelPos + labelOffset; 
                    end
                    lastLabelPos = yPos; 

                    text(crctRate(k).contrasts(iBin), crctRate(k).rates(iBin),yPos, sprintf('%d trials', numPointsInBin), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Color', colors{k});
                else
                    crctRate(k).rates(iBin) = NaN;
                    crctRate(k).contrasts(iBin) = mean([bins(iBin), bins(iBin + 1)]);
                    
                end
            end
            

			h(k) = plot( crctRate(k).contrasts(1:crctRate(k).nRates), crctRate(k).rates(1:crctRate(k).nRates), markerStyle, 'LineStyle', 'none', 'LineWidth', 2, 'color', colors{k},'MarkerSize', 7, 'MarkerFaceColor', markerFaceColor,'DisplayName', names{k} );

            

			[~, ~, nThresh(k,:), nPar, g(k), chisq(k)] = psyfit( contrasts, [trials_{k}.trialType] == 'c', 'Thresh', target, 'Chance', 0.5, 'Log', 'Extra', 'PlotOff', 'Boots',1000, 'disttype', 'normal' );

              




			goodIdx(k,:) = ~isoutlier(nThresh(k,:)) & ~isoutlier(nPar(1,:)) & ~isoutlier(nPar(2,:));
			par(2) = mean(nPar(2,goodIdx(k,:)));
			par(1) = mean(nPar(1,goodIdx(k,:)));
			semPar(2) = std(nPar(2,goodIdx(k,:))) / sqrt(sum(goodIdx(k,:)));
			semPar(1) = std(nPar(1,goodIdx(k,:))) / sqrt(sum(goodIdx(k,:)));
			thresh = mean(nThresh(k,goodIdx(k,:)));
            meanThresh(iSF, k) = mean(nThresh(k,goodIdx(k,:)));
            meanSen(iSF, k) = mean(1./nThresh(k,goodIdx(k,:)));

            onesemThresh (iSF, k) = std(1./nThresh(k,goodIdx(k,:))) / sqrt(sum(goodIdx(k,:))); 
            stdThresh (iSF, k) = std(1./nThresh(k,goodIdx(k,:)));

            if k == 2  
                condition1 = 1 ./ nThresh(1, goodIdx(1,:));
                condition2 = 1 ./ nThresh(2, goodIdx(2,:));
                mean1 = mean(condition1);
                mean2 = mean(condition2);
                std1 = std(condition1);
                std2 = std(condition2);
                n1 = length(condition1);
                n2 = length(condition2);
                Z = (mean1 - mean2) / sqrt((std1^2*(n1-1) + std2^2*(n2-1)) / (n1+n2-1));
                std2con(iSF) = sqrt((std1^2*(n1-1) + std2^2*(n2-1)) / (n1+n2-1));
                pValue = 2 * (1 - normcdf(abs(Z)));  
                pValues(iSF) = pValue;
            end

			semThresh = std(nThresh(k,goodIdx(k,:))) / sqrt(sum(goodIdx(k,:)));
			x = linspace(0, max(crctRate(k).contrasts) * 1.1, 10000);
            %x = logspace(log10(min(crctRate(k).contrasts)), log10(max(crctRate(k).contrasts) * 1.1), 10000);
			y = psyfun( x, par(1), par(2), 0.5, 0, false, true, 'normal' );
			yLow = psyfun( x, par(1) - semPar(1), par(2) - semPar(2), 0.5, 0, false, true, 'normal' );
			yUp = psyfun( x, par(1) + semPar(1), par(2) + semPar(2), 0.5, 0, false, true, 'normal' );

			plot( x, y, '-', 'LineWidth',2, 'color', colors{k}, 'DisplayName', sprintf( 'n=%d', size(trials_{k},2) ) );

			set( fill( [x(2:end) x(end:-1:2)], [yLow(2:end) yUp(end:-1:2)], colors{k} ), 'LineStyle', 'none', 'FaceAlpha', 1);
			%plot( [1, 1] * thresh, [0, target], '--', 'color', colors{k} );
			%set( fill( [-1, 1, 1, -1]*semThresh + thresh, [0, 0, target, target], colors{k} ), 'LineStyle', 'none', 'FaceAlpha',1 );


		end
		if(iSF > nSFs - nCols)
            xlabel('Contrast', 'FontSize', 12);
        end
		ylabel('Correct rate', 'FontSize', 12);
        %title(sprintf('%g CPD', SFs(iSF)));
		set(gca, 'XScale', 'log');


        xticks([0.01, 0.1, 1]);  


        xticklabels({ '10^{-2}', '10^{-1}', '10^{0}'});


        ylabel('Correct rate');
        %title (sprintf('%g CPD', SFs(iSF)));

        
        set( gca, 'XLim', [min([trials{iSF}.gaborAmp]/128)/1.1,1], 'YLim', [0 1], 'XScale', 'log', 'ygrid', 'on', 'FontSize', 18, 'linewidth', 0.5 );
        pos = get(gca, 'position');
        set(gca, 'position', [pos(1) pos(2)-0.005 pos(3) pos(4)+0.01]);
		x = double(get(gca, 'XLim'));

    end

    close(hWaitbar);
    assignin('base', 'pValues', pValues);
    assignin('base', 'std2con', std2con);
    assignin('base', 'meanThresh', meanSen);
    assignin('base', 'SEMthresh', onesemThresh);
    assignin('base', 'stdthresh', stdThresh);


end