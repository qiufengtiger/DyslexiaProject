% Collect data from csv files
classdef DataCollector < handle
    properties
        allParticipantName;
        allParticipantData;
        fileNameArray;   
    end
    methods
        % Constructor
        % File names are stored in parameters.m
        function obj = DataCollector
            obj.allParticipantName = {};
            obj.fileNameArray = evalin('base', 'fileNameArray');
        end
        
        function readData(obj)
            arraySize = size(obj.fileNameArray);
            for i = 1 : arraySize
                fileName = obj.fileNameArray(i);
                readFile(obj, fileName);
            end
        end
        
        % Read files and store in base workspace
        function readFile(obj, fileName)
            filePath = sprintf('./data/%s.csv', fileName);
            fileTable = readtable(filePath);
            fileName = strrep(fileName, '-', '_');
            varName = sprintf('dataTable_%s', fileName);
            assignin('base', varName, fileTable);
            
            for i = 1 : size(fileTable)
                thisRow = fileTable(i, :);
                % instantiate this participant
                if(~any(ismember(obj.allParticipantName, thisRow.Participant)))
                    obj.allParticipantName{end + 1} = cell2mat(thisRow.Participant);
                    thisParticipant = Participant(cell2mat(thisRow.Participant), thisRow.Group);
                    obj.allParticipantData{end + 1} = thisParticipant;
                end
                % load data and save to this participant
                for j = 1 : size(obj.allParticipantData, 2)
                    if(strcmp(get(obj.allParticipantData{j}, 'name'), cell2mat(thisRow.Participant)))
                        obj.allParticipantData{j} = addDataTable(obj.allParticipantData{j}, thisRow);
                    end
                end
            end
        end
        
        % Read heat map data and store in base workspace & corresponding
        % participants
        function readFileHeatMap(obj, fileName, mazeIndex)
            filePath = sprintf('./data/%s.csv', fileName);
            fileTable = readtable(filePath);
            fileName = strrep(fileName, '-', '_');
            varName = sprintf('HM_%s', fileName);
            assignin('base', varName, fileTable);
            
            for i = 1 : size(fileTable)
                thisRow = fileTable(i, :);
                for j = 1 : size(obj.allParticipantData, 2)
                    if(strcmp(get(obj.allParticipantData{j}, 'name'),  cell2mat(thisRow.ID)))
                        obj.allParticipantData{j} = addHeatMapTable(obj.allParticipantData{j}, thisRow, mazeIndex);
                    end
                end
            end
        end
        
        
        % The reason why it does not generate each participant using this
        % overall data file is that the maze data tables used above contain
        % more participant, even though some data of these extra
        % participants are missing
        function readFileOverallData(obj, fileName)
            filePath = sprintf('./data/%s.csv', fileName);
            fileTable = readtable(filePath);
%             fileName = strrep(fileName, '-', '_');
%             varName = sprintf('%s', fileName);
            assignin('base', 'overallData', fileTable);
            for i = 1 : size(fileTable)
                thisRow = fileTable(i, :);
                for j = 1 : size(obj.allParticipantData, 2)
                    if(strcmp(get(obj.allParticipantData{j}, 'name'),  cell2mat(thisRow.Participant_ID)))
                        % gender
                        obj.allParticipantData{j}.gender = thisRow.Gender;
                        % school
                        if(strcmp(thisRow.school, 'Desert'))
                            obj.allParticipantData{j}.school = Participant.DESERT;
                        elseif(strcmp(thisRow.school, 'Riverst'))
                            obj.allParticipantData{j}.school = Participant.RIVERST;
                        end
                        % ageGroup
                        if(thisRow.age < 10)
                            obj.allParticipantData{j}.ageGroup = Participant.AGE_GROUP1;
                        else
                            obj.allParticipantData{j}.ageGroup = Participant.AGE_GROUP2;
                        end
                        break;
                    end     
                end 
            end
            
        end
        
        function returnObj = get(obj, propertyName)
            switch(propertyName)
                case 'name'
                    returnObj = obj.allParticipantName;
                case 'data'
                    returnObj = obj.allParticipantData;
            end
        end
    end
end