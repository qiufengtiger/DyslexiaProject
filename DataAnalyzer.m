classdef DataAnalyzer < handle
    properties
        allParticipantData;
        typicalParticipantData;
        atypicalParticipantData;
%         correctPrediction;
%         totalPrediction;

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
        function obj = DataAnalyzer()
            obj.typicalParticipantData = {};
            obj.atypicalParticipantData = {};
            obj.standardMaze8Trial6 = zeros(6, 6);
            obj.standardMaze11Trial6 = zeros(6, 6);
        end
        
        function initializeAnalyzer(obj)
            loadParticipantData(obj);
            sortParticipantGroup(obj);
        end
        
        function loadParticipantData(obj)
            obj.allParticipantData = evalin('base', 'participantData');
        end
        
        function sortParticipantGroup(obj)
            for i = 1 : size(obj.allParticipantData, 2)
                if(get(obj.allParticipantData{i}, 'group') == 1)
                    obj.typicalParticipantData{end + 1} = obj.allParticipantData{i};
                else
                    obj.atypicalParticipantData{end + 1} = obj.allParticipantData{i};
                end
            end
        end
        
        function summaryHeatMap(obj, participantType, mazeIndex)
            % average heat map data
            heatMapData = {zeros(6, 6), zeros(6, 6), zeros(6, 6), zeros(6, 6), zeros(6, 6), zeros(6, 6)};
            heatMapParticipantNum = [0, 0, 0, 0, 0, 0];
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
                    for j = 1 : 6
                        heatMapData{j} = heatMapData{j} + returnData{j};
                    end
                end
            end
            % average
            for i = 1 : size(heatMapData, 2)
                heatMapData{i} = heatMapData{i} / heatMapParticipantNum(i);
            end
            DataAnalyzer.drawHeatMaps(heatMapData); 
        end
        
        function summaryParticipantGroup(obj)
            dataType = DataAnalyzer.DISTANCE;
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
        
        function createBaseLine(obj, mazeIndex)
            baseLineParticipantNum = 20;
            baseLineParticipants = zeros(baseLineParticipantNum, 1);
            randCreatedNum = 0;
            % store baseline data. later will be assigned to properties
            heatMapDataTrial6 = zeros(6, 6); % trial 6 only
            heatMapParticipantNum = 0;
            
            while true
                participantIndex = ceil(rand * size(obj.typicalParticipantData, 2));
                if(~ismember(participantIndex, baseLineParticipants))
                    randCreatedNum = randCreatedNum + 1;
                    baseLineParticipants(randCreatedNum, 1) = participantIndex;
                end
                if(randCreatedNum == baseLineParticipantNum)
                    break; 
                end
            end
            
            for i = 1 : baseLineParticipantNum
                returnData = DataAnalyzer.getHeatMapData(obj.typicalParticipantData{baseLineParticipants(i, 1)}, mazeIndex);
                if(~isempty(returnData))
                    heatMapParticipantNum = heatMapParticipantNum + 1;
                    heatMapDataTrial6 = heatMapDataTrial6 + returnData{6};
                end
            end
            
            % assign to specific properties in the object
            if(mazeIndex == 8)
                obj.standardMaze8Trial6 = heatMapDataTrial6 / heatMapParticipantNum;
            elseif(mazeIndex == 11)
                obj.standardMaze11Trial6 = heatMapDataTrial6 / heatMapParticipantNum;
            end  
            % run correlations on baseline participants
            trialNum = [1, 2, 3, 4, 5, 6];


            returnData = DataAnalyzer.getHeatMapData(obj.typicalParticipantData{baseLineParticipants(1, 1)}, mazeIndex);           
            returnCorr = applyCorrelation(obj, returnData, mazeIndex);
            plot(trialNum, returnCorr, '-o');
            hold on;     
            for i = 2 : baseLineParticipantNum
                returnData = DataAnalyzer.getHeatMapData(obj.typicalParticipantData{baseLineParticipants(i, 1)}, mazeIndex);
                returnCorr = applyCorrelation(obj, returnData, mazeIndex);
                plot(trialNum, returnCorr, '-o');
            end
            hold off;
        end
        
        % get data using DataAnalyzer.getHeatMapData first, then call this
        % method with the data returned
        function returnCorr = applyCorrelation(obj, heatMapData, mazeIndex)
            standard = zeros(6, 6);
            returnCorr = zeros(6, 1);
            if(mazeIndex == 8)
                standard = obj.standardMaze8Trial6;
            elseif(mazeIndex == 11)
                standard = obj.standardMaze11Trial6;
            end
            
            % run through 6 trials
            for i = 1 : size(heatMapData, 2)
                returnCorr(i, 1) = corr2(heatMapData{i}, standard);
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
    
    methods(Static)
        function checkResult = makePrediction()
            
        end
        
        function averageTrials = drawHeatMaps(heatMapData)
            averageTrials = zeros(6, 6);
            for i = 1 : size(heatMapData, 2)
                subplot(3, 3, i);
                title = sprintf("trial %d", i);
                DataAnalyzer.drawSingleHeatMap(heatMapData{i}, [-0.5, 2.5], title);
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
                    returnObj{thisRow.maze_trial}(1, 1) = returnObj{thisRow.maze_trial}(1, 1) + thisRow.A1;
                    returnObj{thisRow.maze_trial}(2, 1) = returnObj{thisRow.maze_trial}(2, 1) + thisRow.A2;
                    returnObj{thisRow.maze_trial}(3, 1) = returnObj{thisRow.maze_trial}(3, 1) + thisRow.A3;
                    returnObj{thisRow.maze_trial}(4, 1) = returnObj{thisRow.maze_trial}(4, 1) + thisRow.A4;
                    returnObj{thisRow.maze_trial}(5, 1) = returnObj{thisRow.maze_trial}(5, 1) + thisRow.A5;
                    returnObj{thisRow.maze_trial}(6, 1) = returnObj{thisRow.maze_trial}(6, 1) + thisRow.A6;
                    
                    returnObj{thisRow.maze_trial}(1, 2) = returnObj{thisRow.maze_trial}(1, 2) + thisRow.B1;
                    returnObj{thisRow.maze_trial}(2, 2) = returnObj{thisRow.maze_trial}(2, 2) + thisRow.B2;
                    returnObj{thisRow.maze_trial}(3, 2) = returnObj{thisRow.maze_trial}(3, 2) + thisRow.B3;
                    returnObj{thisRow.maze_trial}(4, 2) = returnObj{thisRow.maze_trial}(4, 2) + thisRow.B4;
                    returnObj{thisRow.maze_trial}(5, 2) = returnObj{thisRow.maze_trial}(5, 2) + thisRow.B5;
                    returnObj{thisRow.maze_trial}(6, 2) = returnObj{thisRow.maze_trial}(6, 2) + thisRow.B6;
                    
                    returnObj{thisRow.maze_trial}(1, 3) = returnObj{thisRow.maze_trial}(1, 3) + thisRow.C1;
                    returnObj{thisRow.maze_trial}(2, 3) = returnObj{thisRow.maze_trial}(2, 3) + thisRow.C2;
                    returnObj{thisRow.maze_trial}(3, 3) = returnObj{thisRow.maze_trial}(3, 3) + thisRow.C3;
                    returnObj{thisRow.maze_trial}(4, 3) = returnObj{thisRow.maze_trial}(4, 3) + thisRow.C4;
                    returnObj{thisRow.maze_trial}(5, 3) = returnObj{thisRow.maze_trial}(5, 3) + thisRow.C5;
                    returnObj{thisRow.maze_trial}(6, 3) = returnObj{thisRow.maze_trial}(6, 3) + thisRow.C6;
                    
                    returnObj{thisRow.maze_trial}(1, 4) = returnObj{thisRow.maze_trial}(1, 4) + thisRow.D1;
                    returnObj{thisRow.maze_trial}(2, 4) = returnObj{thisRow.maze_trial}(2, 4) + thisRow.D2;
                    returnObj{thisRow.maze_trial}(3, 4) = returnObj{thisRow.maze_trial}(3, 4) + thisRow.D3;
                    returnObj{thisRow.maze_trial}(4, 4) = returnObj{thisRow.maze_trial}(4, 4) + thisRow.D4;
                    returnObj{thisRow.maze_trial}(5, 4) = returnObj{thisRow.maze_trial}(5, 4) + thisRow.D5;
                    returnObj{thisRow.maze_trial}(6, 4) = returnObj{thisRow.maze_trial}(6, 4) + thisRow.D6;
                    
                    returnObj{thisRow.maze_trial}(1, 5) = returnObj{thisRow.maze_trial}(1, 5) + thisRow.E1;
                    returnObj{thisRow.maze_trial}(2, 5) = returnObj{thisRow.maze_trial}(2, 5) + thisRow.E2;
                    returnObj{thisRow.maze_trial}(3, 5) = returnObj{thisRow.maze_trial}(3, 5) + thisRow.E3;
                    returnObj{thisRow.maze_trial}(4, 5) = returnObj{thisRow.maze_trial}(4, 5) + thisRow.E4;
                    returnObj{thisRow.maze_trial}(5, 5) = returnObj{thisRow.maze_trial}(5, 5) + thisRow.E5;
                    returnObj{thisRow.maze_trial}(6, 5) = returnObj{thisRow.maze_trial}(6, 5) + thisRow.E6;
                    
                    returnObj{thisRow.maze_trial}(1, 6) = returnObj{thisRow.maze_trial}(1, 6) + thisRow.F1;
                    returnObj{thisRow.maze_trial}(2, 6) = returnObj{thisRow.maze_trial}(2, 6) + thisRow.F2;
                    returnObj{thisRow.maze_trial}(3, 6) = returnObj{thisRow.maze_trial}(3, 6) + thisRow.F3;
                    returnObj{thisRow.maze_trial}(4, 6) = returnObj{thisRow.maze_trial}(4, 6) + thisRow.F4;
                    returnObj{thisRow.maze_trial}(5, 6) = returnObj{thisRow.maze_trial}(5, 6) + thisRow.F5;
                    returnObj{thisRow.maze_trial}(6, 6) = returnObj{thisRow.maze_trial}(6, 6) + thisRow.F6;
                end
            else
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
        
        % this method is created because matlab automatatically changes the
        % name of variables when reading the table
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
    end
end