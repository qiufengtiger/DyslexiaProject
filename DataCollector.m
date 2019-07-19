classdef DataCollector < handle
    properties
        allParticipantName;
        allParticipantData;
        fileNameArray;
        
    end
    methods
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
        
        function readFile(obj, fileName)
            filePath = sprintf('./data/%s.csv', fileName);
            fileTable = readtable(filePath);
            fileName = strrep(fileName, '-', '_');
            varName = sprintf('dataTable_%s', fileName);
            assignin('base', varName, fileTable);
            
            %             % update participant list
            %             currentParticipantList = unique(fileTable.Participant);
            %             obj.allParticipantList = unique(cat(1, currentParticipantList, obj.allParticipantList));
            %
            for i = 1 : size(fileTable)
                thisRow = fileTable(i, :);
                % instantiate this participant
                if(~any(ismember(obj.allParticipantName, thisRow.Participant)))
                    obj.allParticipantName{end + 1} = cell2mat(thisRow.Participant);
                    thisParticipant = Participant(cell2mat(thisRow.Participant), thisRow.Group);
                    obj.allParticipantData{end + 1} = thisParticipant;
                end
                for j = 1 : size(obj.allParticipantData, 2)
                    if(strcmp(get(obj.allParticipantData{j}, 'name'), cell2mat(thisRow.Participant)))
                        obj.allParticipantData{j} = addDataTable(obj.allParticipantData{j}, thisRow);
                    end
                end
            end
        end
        
        
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
        
        function returnObj = get(obj, propertyName)
            switch(propertyName)
                case 'name'
                    returnObj = obj.allParticipantName;
                case 'data'
                    returnObj = obj.allParticipantData;
            end
        end
        
        function print(obj)
            fileTable = evalin('base', 'fileTable');
            c = cell2mat(fileTable{1, 'Participant'})
        end
    end
end