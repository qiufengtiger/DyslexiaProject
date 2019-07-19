clear aclear all;
% group
% 1 typical
% 2 atypical
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
warning('off', 'MATLAB:textscan:UnableToGuessFormat');
warning('off', 'MATLAB:textscan:AllNatSuggestFormat');

Parameters;

dc = DataCollector;
% da = DataAnalyzer;
readData(dc);



% loadParticipantData(da);
% sortParticipantGroup(da);

readFileHeatMap(dc, 'Combined_Maze_8_data_UPDATED_participants_removed_PE', 8);
readFileHeatMap(dc, 'Combined_Maze_11_data_UPDATED_PE', 11);

participantName = get(dc, 'name');
participantData = get(dc, 'data');


% print(dc);