% Used to analyze average / heat map data and make predictions
classdef DataAnalyzer < handle
    properties
        allParticipantData;
        typicalParticipantData;
        atypicalParticipantData;

        standardMaze8Trial6;
        standardMaze11Trial6;
    end
    
    properties(Constant)
        TYPICAL = 1;
        ATYPICAL = 2;
        MAZE_TYPES = [1, 5, 6, 8, 11, 12];
        MAZE_NUM = 6;
        
        DURATION = 1;
        DISTANCE = 2;
        MEAN_SPEED = 3;
        FROZEN_TIME = 4;
        TOTAL_ERROR = 5;
        TEST = 6;
        TRIAL = 7;
    end
    
    methods
        % Constructor
        function obj = DataAnalyzer()
            obj.typicalParticipantData = {};
            obj.atypicalParticipantData = {};
            obj.standardMaze8Trial6 = zeros(6, 6);
            obj.standardMaze11Trial6 = zeros(6, 6);
        end
        
        % Read data in sort participants
        function initializeAnalyzer(obj)
            loadParticipantData(obj);
            sortParticipantGroup(obj);
            
            function loadParticipantData(obj)
                obj.allParticipantData = evalin('base', 'participantData');
            end
            
            function sortParticipantGroup(obj)
                for i = 1 : size(obj.allParticipantData, 2)
                    if(get(obj.allParticipantData{i}, 'group') == DataAnalyzer.TYPICAL)
                        obj.typicalParticipantData{end + 1} = obj.allParticipantData{i};
                    else
                        obj.atypicalParticipantData{end + 1} = obj.allParticipantData{i};
                    end
                end
            end
        end
        
        % Generate heat maps for 6 trials plus average. Only maze 8 and 11
        % have data
        function summaryHeatMap(obj, participantType, mazeIndex)
            % average heat map data
            heatMapData = {zeros(6, 6), zeros(6, 6), zeros(6, 6), zeros(6, 6), zeros(6, 6), zeros(6, 6)};
            heatMapParticipantNum = [0, 0, 0, 0, 0, 0];
            % get data according to participant type
            if(participantType == DataAnalyzer.TYPICAL)
                participant = obj.typicalParticipantData;
            elseif(participantType == DataAnalyzer.ATYPICAL)
                participant = obj.atypicalParticipantData;
            end
            for i = 1 : size(participant, 2)
                thisParticipant = participant{i};
                returnData = DataAnalyzer.getHeatMapData(thisParticipant, mazeIndex);
                if(~isempty(returnData)) % not empty
                    heatMapParticipantNum = heatMapParticipantNum + 1;
                    % trial 1 to trial 6. 
                    for j = 1 : 6
                        % sum each trial to each total data
                        heatMapData{j} = heatMapData{j} + returnData{j};
                    end
                end
            end
            % average each trial
            for i = 1 : size(heatMapData, 2)
                heatMapData{i} = heatMapData{i} / heatMapParticipantNum(i);
            end
            DataAnalyzer.drawHeatMaps(heatMapData, participantType, mazeIndex); 
        end
        
        % Draw line plots showing average data of all mazes. To change data type, modify
        % dataType variable. Available data types are in DataAnalyzer's properties
        function summaryParticipantGroup(obj, dataType)
            %dataType = DataAnalyzer.DURATION;
            typicalMaze1 = averageData(obj, 1, DataAnalyzer.TYPICAL, dataType);
            atypicalMaze1 = averageData(obj, 1, DataAnalyzer.ATYPICAL, dataType);
            typicalMaze5 = averageData(obj, 5, DataAnalyzer.TYPICAL, dataType);
            atypicalMaze5 = averageData(obj, 5, DataAnalyzer.ATYPICAL, dataType);
            typicalMaze6 = averageData(obj, 6, DataAnalyzer.TYPICAL, dataType);
            atypicalMaze6 = averageData(obj, 6, DataAnalyzer.ATYPICAL, dataType);
            typicalMaze8 = averageData(obj, 8, DataAnalyzer.TYPICAL, dataType);
            atypicalMaze8 = averageData(obj, 8, DataAnalyzer.ATYPICAL, dataType);
            typicalMaze11 = averageData(obj, 11, DataAnalyzer.TYPICAL, dataType);
            atypicalMaze11 = averageData(obj, 11, DataAnalyzer.ATYPICAL, dataType);
            typicalMaze12 = averageData(obj, 12, DataAnalyzer.TYPICAL, dataType);
            atypicalMaze12 = averageData(obj, 12, DataAnalyzer.ATYPICAL, dataType);
            printResult();
            
            function printResult()
                figureName = 'summaryParticipantGroup: ';
                figureName = strcat(figureName, DataAnalyzer.dataTypeToString(dataType));
                figure('Name', figureName);
                trialNum = [1, 2, 3, 4, 5, 6];
                subplot(3, 2, 1);
                plot(trialNum, typicalMaze1, '-o');
                hold on;
                plot(trialNum, atypicalMaze1, '-o');
                legend({'typical', 'atypical'});
                title('Maze1')
                hold off;
                
                subplot(3, 2, 2);
                plot(trialNum, typicalMaze5, '-o');
                hold on;
                plot(trialNum, atypicalMaze5, '-o');
                legend({'typical', 'atypical'});
                title('Maze5')
                hold off;
                
                subplot(3, 2, 3);
                plot(trialNum, typicalMaze6, '-o');
                hold on;
                plot(trialNum, atypicalMaze6, '-o');
                legend({'typical', 'atypical'});
                title('Maze6')
                hold off;
                
                subplot(3, 2, 4);
                plot(trialNum, typicalMaze8, '-o');
                hold on;
                plot(trialNum, atypicalMaze8, '-o');
                legend({'typical', 'atypical'});
                title('Maze8')
                hold off;
                
                subplot(3, 2, 5);
                plot(trialNum, typicalMaze11, '-o');
                hold on;
                plot(trialNum, atypicalMaze11, '-o');
                legend({'typical', 'atypical'});
                title('Maze11')
                hold off;
                
                subplot(3, 2, 6);
                plot(trialNum, typicalMaze12, '-o');
                hold on;
                plot(trialNum, atypicalMaze12, '-o');
                legend({'typical', 'atypical'});
                title('Maze12')
                hold off;
            end
        end
        
        % TODO
        function runPredict(obj)
            mazeIndex = 8;
            correctPrediction = 0;
            totalPrediction = 0;
            for i = 1 : size(obj.allParticipantData, 2)
                thisParticipant = obj.allParticipantData{i};
                predictParticipant(obj, thisParticipant, mazeIndex);
            end
             
            function predictParticipant(obj, participant, mazeIndex)
                % prediction
                heatMapData = DataAnalyzer.getHeatMapData(participant, mazeIndex);
                % for now only run prediction at maze 8
                if(mazeIndex == 8 && ~isempty(heatMapData))
                    criterion = DataAnalyzer.makePrediction();
                    if(criterion && get(participant, 'group') == DataAnalyzer.TYPICAL)
                        correctPrediction = correctPrediction + 1;
                    elseif(~criterion && get(participant, 'group') == DataAnalyzer.ATYPICAL)
                        correctPrediction = correctPrediction + 1;
                    end
                    totalPrediction = totalPrediction + 1;
                end
            end
            totalPrediction
            correctPrediction
            correctPrediction / totalPrediction    
        end
        
        % Randomly select certain number of typical participants and draw the 
        % correlation of their each trial to their trial 6. The original
        % version uses the average of trial 6 data as correlation reference
        function createBaseLine(obj, mazeIndex, type, value)
            % #typical participant used
            % the program will throw a warning if it's greater than the
            % total #participant
            baseLineParticipantNum = 47; 
            baseLineParticipants = zeros(baseLineParticipantNum, 1);
            randCreatedNum = 0;
            % store baseline trial 6 data. later will be assigned to properties
            heatMapDataTrial6 = zeros(6, 6); % trial 6 only
            heatMapParticipantNum = 0;
            averageBaseLineCorr = zeros(6, 1);
            
            % where baseline participants are chosen
            if(strcmp(type, 'none'))
                baseLineSource = obj.typicalParticipantData;
            else
                baseLineSource = DataAnalyzer.findInGroup(obj.typicalParticipantData, type, value);
            end   
            % #participant having none empty heat map data
            noneEmptyNum = size(nonzeros(cellfun(@(x) ~isempty(DataAnalyzer.getHeatMapData(x, mazeIndex)), baseLineSource)), 1);
            
            % randomly select participants in typical group
            while true
                % in case that baseline participant num entered exceeds total participant num 
                if(randCreatedNum == noneEmptyNum)
                    warning('baseLineParticipantNum %d exceeds group size %d!\n', baseLineParticipantNum, noneEmptyNum);
                    break;
                end
                participantIndex = ceil(rand * size(baseLineSource, 2));
                % isn't included yet && heat map data not empty
                if(~ismember(participantIndex, baseLineParticipants) && ~isempty(DataAnalyzer.getHeatMapData(baseLineSource{participantIndex}, mazeIndex)))
                    randCreatedNum = randCreatedNum + 1;
                    baseLineParticipants(randCreatedNum, 1) = participantIndex;
                end
                if(randCreatedNum == baseLineParticipantNum)
                    break; 
                end
            end
            
            % calculate average of trial 6 of all selected typical
            % participants for the reference
            for i = 1 : baseLineParticipantNum
                % it can be 0 if baseLineParticipantNum > #participant
                % having none empty heat map data
                if(baseLineParticipants(i, 1) == 0)
                    break;
                end
                if(~isempty(DataAnalyzer.getHeatMapData(baseLineSource{baseLineParticipants(i, 1)}, mazeIndex)))
                    returnData = DataAnalyzer.getHeatMapData(baseLineSource{baseLineParticipants(i, 1)}, mazeIndex);
                    heatMapParticipantNum = heatMapParticipantNum + 1; 
                    heatMapDataTrial6 = heatMapDataTrial6 + returnData{6};
                end
            end   
            % assign to specific properties in the object for plotting
            % atypical group
            if(mazeIndex == 8)
                obj.standardMaze8Trial6 = heatMapDataTrial6 / heatMapParticipantNum;
            elseif(mazeIndex == 11)
                obj.standardMaze11Trial6 = heatMapDataTrial6 / heatMapParticipantNum;
            end  
            
            % run correlations on baseline participants and plot the region
            trialNum = [1, 2, 3, 4, 5, 6];
            figure;
            hold on;     
            for i = 1 : size(baseLineParticipants, 1)
                returnData = DataAnalyzer.getHeatMapData(baseLineSource{baseLineParticipants(i, 1)}, mazeIndex);
                if(~isempty(returnData))
                    returnCorr = applyCorrelation(obj, returnData, mazeIndex);
                    plot(trialNum, returnCorr, '-bo');
                    averageBaseLineCorr = averageBaseLineCorr + returnCorr;
                end
            end
            averageBaseLineCorr = averageBaseLineCorr / heatMapParticipantNum; % divided by actual #participants who have heat map data
            plot(trialNum, averageBaseLineCorr, '-y*');
            hold off;
        end
        
        % Plot correlation of all atypical participants on current figure
        % Run createBaseLine first
        function plotAtypicalCorr(obj, mazeIndex, type, value)
            
            atypicalSource = DataAnalyzer.findInGroup(obj.atypicalParticipantData, type, value);
            
            trialNum = [1, 2, 3, 4, 5, 6];
            hold on;
            for i = 1 : size(atypicalSource, 2)
                returnData = DataAnalyzer.getHeatMapData(atypicalSource{i}, mazeIndex);
                if(~isempty(returnData))
                    returnCorr = applyCorrelation(obj, returnData, mazeIndex);
                    plot(trialNum, returnCorr, '-rx');
                end
                
            end
            hold off;
        end
        
        % Get data using DataAnalyzer.getHeatMapData first, then call this
        % method with the data returned
        function returnCorr = applyCorrelation(obj, heatMapData, mazeIndex)
            standard = zeros(6, 6);
            returnCorr = zeros(6, 1);
            
            % if compare with average, comment out the line after this if else block 
            if(mazeIndex == 8)
                standard = obj.standardMaze8Trial6;
            elseif(mazeIndex == 11)
                standard = obj.standardMaze11Trial6;
            end
            % if compare with this participant's own trial 6
%             standard = heatMapData{6};
%             standard(1 : 6, 1 : 6) = -1;
%             standard = zeros(6, 6);
%             standard(1 : 6, 1 : 6) = 0.3;
%             standard = DataAnalyzer.excludeGrids(standard, {'A1', 'A2', 'A3', 'A4', 'B4', 'C4', 'C3', 'D3', 'E3', 'F3', 'F4', 'F5', 'F6'});

            % run through 6 trials
            for i = 1 : size(heatMapData, 2)
                
%                 heatMapData{i} = DataAnalyzer.excludeGrids(heatMapData{i}, {'A1', 'A2', 'A3', 'A4', 'B4', 'C4', 'C3', 'D3', 'E3', 'F3', 'F4', 'F5', 'F6'});        
                
%                 xcorrResult = normxcorr2(heatMapData{i}, standard);
%                 returnCorr(i, 1) = sum(xcorrResult, 'all');

                returnCorr(i, 1) = 0.5 * ssim(heatMapData{i}, standard) + 0.5;
%                 returnCorr(i, 1) = immse(heatMapData{i}, standard);
%                 [~, returnCorr(i, 1)] = psnr(heatMapData{i}, standard);
            end

        end
        
        function returnData = averageData(obj, mazeIndex, participantType, dataType)
            returnData = zeros(1, DataAnalyzer.MAZE_NUM);
            numData = zeros(1, DataAnalyzer.MAZE_NUM);
            if(participantType == DataAnalyzer.TYPICAL)
                participant = obj.typicalParticipantData;
            else
                participant = obj.atypicalParticipantData;
            end
            
            % loop through all participants
            for i = 1 : size(participant, 2)
                thisParticipant = participant{i};
                dataTable = get(thisParticipant, mazeIndex);
                % loop through all record for a single maze of a
                % participant
                if(~isempty(dataTable))
                    for j = 1 : size(dataTable, 1)
                        thisRow = dataTable(j, :);
                        data = DataAnalyzer.getDataFromRow(thisRow, dataType);
                        trialNum = thisRow.Trial;
                        % some data is not converted to number but cell
                        % array by readtable, so need to check here
                        data = DataAnalyzer.cell2Num(data);
                        trialNum = DataAnalyzer.cell2Num(trialNum);
                        returnData(trialNum) = returnData(trialNum) + data;
                        numData(trialNum) = numData(trialNum) + 1;
                    end
                end
            end
            
            for i = 1 : size(returnData, 2)
                returnData(i) = returnData(i) / numData(i);
            end
        end
        
        function returnObj = get(obj, propertyName)
            switch(propertyName)
                case 'typical'
                    returnObj = obj.typicalParticipantName;
                case 'atypical'
                    returnObj = obj.atypicalParticipantData;
            end
        end    
    end
    
    % tools used 
    methods(Static)
        function returnData = findInGroup(sourceData, type, value)
            returnData = {};
            % find cells
            if(strcmp(type, 'gender'))
                returnData = cellfun(@(x) x(x.gender == value), sourceData, 'UniformOutput', false);
            elseif(strcmp(type, 'school'))
                returnData = cellfun(@(x) x(x.school == value), sourceData, 'UniformOutput', false);
            elseif(strcmp(type, 'age'))
                returnData = cellfun(@(x) x(x.ageGroup == value), sourceData, 'UniformOutput', false);
            end
            % clear empty cells
            returnData(cellfun('isempty', returnData)) = [];
        end
        
        % set pecific grids in heat map to 0
        function executedSingleHeatMap = excludeGrids(singleHeatMapData, grids)
            executedSingleHeatMap = singleHeatMapData;
            for i = 1 : size(grids, 2)
                thisGridY = grids{i}(2);
                switch(grids{i}(1))
                    case 'A'
                        thisGridX = 1;
                    case 'B'
                        thisGridX = 2;
                    case 'C'
                        thisGridX = 3;
                    case 'D'
                        thisGridX = 4;
                    case 'E'
                        thisGridX = 5;
                    case 'F'
                        thisGridX = 6;
                end
                executedSingleHeatMap(str2double(thisGridY), thisGridX) = 0;
            end
        end
   
        function averageTrials = drawHeatMaps(heatMapData, participantType, mazeIndex)
            figureName = 'summaryHeatMap: ';
            figureName = strcat(figureName, DataAnalyzer.participantTypeToString(participantType));
            figureName = strcat(figureName, int2str(mazeIndex));
            figure('Name', figureName);
            averageTrials = zeros(6, 6);
            for i = 1 : size(heatMapData, 2)
                subplot(3, 3, i);
                title = sprintf("trial %d", i);
                
                thisHeatMapData = heatMapData{i};
%                 thisHeatMapData = DataAnalyzer.excludeGrids(thisHeatMapData, {'A1', 'A2', 'A3', 'A4', 'B4', 'C4', 'C3', 'D3', 'E3', 'F3', 'F4', 'F5', 'F6'});
                
                
%                 DataAnalyzer.drawSingleHeatMap(heatMapData{i}, [-0.5, 2.5], title);

                DataAnalyzer.drawSingleHeatMap(thisHeatMapData, [-0.5, 2.5], title);
                
                averageTrials = averageTrials + heatMapData{i};
            end
            averageTrials = averageTrials / size(heatMapData, 2);
            subplot(3, 3, 7);
            DataAnalyzer.drawSingleHeatMap(averageTrials, [-0.5, 1], "average");
        end
        
        function returnHeatMap = drawSingleHeatMap(heatMapDataSingleTrial, limit, title)
            returnHeatMap = heatmap(heatMapDataSingleTrial, 'colorLimits', limit);
            returnHeatMap.XData = ["A", "B", "C", "D", "E", "F"];
            returnHeatMap.YData = ["1", "2", "3", "4", "5", "6"];
            returnHeatMap.XLabel = 'X';
            returnHeatMap.YLabel = 'Y';
            returnHeatMap.Title = title;
        end
        
        % return heat map matrices of all 6 trials given a participant & maze number
        function returnObj = getHeatMapData(participant, mazeIndex)
            if(mazeIndex == 8)
                mazeIndex = 'heatMap8';
            elseif(mazeIndex == 11)
                mazeIndex = 'heatMap11';
            end
            returnObj = {zeros(6, 6), zeros(6, 6), zeros(6, 6), zeros(6, 6), zeros(6, 6), zeros(6, 6)};
            dataTable = get(participant, mazeIndex);
            if(~isempty(dataTable))
                for j = 1 : size(dataTable, 1)
                    thisRow = dataTable(j, :);
                    returnObj{thisRow.maze_trial}(1, 1) = thisRow.A1;
                    returnObj{thisRow.maze_trial}(2, 1) = thisRow.A2;
                    returnObj{thisRow.maze_trial}(3, 1) = thisRow.A3;
                    returnObj{thisRow.maze_trial}(4, 1) = thisRow.A4;
                    returnObj{thisRow.maze_trial}(5, 1) = thisRow.A5;
                    returnObj{thisRow.maze_trial}(6, 1) = thisRow.A6;
                    
                    returnObj{thisRow.maze_trial}(1, 2) = thisRow.B1;
                    returnObj{thisRow.maze_trial}(2, 2) = thisRow.B2;
                    returnObj{thisRow.maze_trial}(3, 2) = thisRow.B3;
                    returnObj{thisRow.maze_trial}(4, 2) = thisRow.B4;
                    returnObj{thisRow.maze_trial}(5, 2) = thisRow.B5;
                    returnObj{thisRow.maze_trial}(6, 2) = thisRow.B6;
                    
                    returnObj{thisRow.maze_trial}(1, 3) = thisRow.C1;
                    returnObj{thisRow.maze_trial}(2, 3) = thisRow.C2;
                    returnObj{thisRow.maze_trial}(3, 3) = thisRow.C3;
                    returnObj{thisRow.maze_trial}(4, 3) = thisRow.C4;
                    returnObj{thisRow.maze_trial}(5, 3) = thisRow.C5;
                    returnObj{thisRow.maze_trial}(6, 3) = thisRow.C6;
                    
                    returnObj{thisRow.maze_trial}(1, 4) = thisRow.D1;
                    returnObj{thisRow.maze_trial}(2, 4) = thisRow.D2;
                    returnObj{thisRow.maze_trial}(3, 4) = thisRow.D3;
                    returnObj{thisRow.maze_trial}(4, 4) = thisRow.D4;
                    returnObj{thisRow.maze_trial}(5, 4) = thisRow.D5;
                    returnObj{thisRow.maze_trial}(6, 4) = thisRow.D6;
                    
                    returnObj{thisRow.maze_trial}(1, 5) = thisRow.E1;
                    returnObj{thisRow.maze_trial}(2, 5) = thisRow.E2;
                    returnObj{thisRow.maze_trial}(3, 5) = thisRow.E3;
                    returnObj{thisRow.maze_trial}(4, 5) = thisRow.E4;
                    returnObj{thisRow.maze_trial}(5, 5) = thisRow.E5;
                    returnObj{thisRow.maze_trial}(6, 5) = thisRow.E6;
                    
                    returnObj{thisRow.maze_trial}(1, 6) = thisRow.F1;
                    returnObj{thisRow.maze_trial}(2, 6) = thisRow.F2;
                    returnObj{thisRow.maze_trial}(3, 6) = thisRow.F3;
                    returnObj{thisRow.maze_trial}(4, 6) = thisRow.F4;
                    returnObj{thisRow.maze_trial}(5, 6) = thisRow.F5;
                    returnObj{thisRow.maze_trial}(6, 6) = thisRow.F6;
                end
            else
                % is empty
                returnObj = dataTable;
            end
        end
        
        function returnObj = cell2Num(input)
            if(~isnumeric(input))
                returnObj = str2double(cell2mat(input));
            else
                returnObj = input;
            end
        end
        
        % This method is created because matlab automatatically changes the
        % name of variables when reading the maze table
        % DataAnalyzer.TEST is used to find variables sensitive to groups
        function returnObj = getDataFromRow(thisRow, dataType)
            switch(dataType)
                case DataAnalyzer.TRIAL
                    returnObj = thisRow.Trial;
                case DataAnalyzer.DURATION
                    returnObj = thisRow.Duration_s_;
                case DataAnalyzer.DISTANCE
                    returnObj = thisRow.Distance;
                case DataAnalyzer.MEAN_SPEED
                    returnObj = thisRow.MeanSpeed;
                case DataAnalyzer.FROZEN_TIME
                    returnObj = thisRow.FrozenTime_s_;
                case DataAnalyzer.TOTAL_ERROR
                    returnObj = thisRow.TotalErrors;
                case DataAnalyzer.TEST
                    returnObj = DataAnalyzer.cell2Num(thisRow.Distance) / DataAnalyzer.cell2Num(thisRow.Duration_s_);
            end
        end
        
        function returnObj = dataTypeToString(dataType)
            switch(dataType)
                case DataAnalyzer.TRIAL
                    returnObj = 'TRIAL';
                case DataAnalyzer.DURATION
                    returnObj = 'DURATION';
                case DataAnalyzer.DISTANCE
                    returnObj = 'DISTANCE';
                case DataAnalyzer.MEAN_SPEED
                    returnObj = 'MEAN_SPEED';
                case DataAnalyzer.FROZEN_TIME
                    returnObj = 'FROZEN_TIME';
                case DataAnalyzer.TOTAL_ERROR
                    returnObj = 'TOTAL_ERROR';
                case DataAnalyzer.TEST
                    returnObj = 'TEST';
            end
        end
        
        function returnObj = participantTypeToString(participantType)
           switch(participantType)
               case DataAnalyzer.TYPICAL
                   returnObj = 'TYPICAL';
               case DataAnalyzer.ATYPICAL
                   returnObj = 'ATYPICAL';
           end
        end
    end
end