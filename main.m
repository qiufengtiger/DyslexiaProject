% Author Feng Qiu qiuf@lafayette.edu
% To get the latest version, go to https://github.com/qiufengtiger/DyslexiaProject

clear all;
% group
% 1 typical
% 2 atypical

% Disable warnings
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames'); % some variable names in the csv file are not supported
warning('off', 'MATLAB:textscan:AllNatSuggestFormat'); % variable names above will be changed automatically
warning('off', 'MATLAB:textscan:UnableToGuessFormat'); % some time / date values cannot be read. does not matter since they are not used in data analysis

% load file names
Parameters;

dc = DataCollector;
readData(dc);

readFileHeatMap(dc, 'Combined_Maze_8_data_UPDATED_participants_removed_PE', 8);
readFileHeatMap(dc, 'Combined_Maze_11_data_UPDATED_PE', 11);
readFileOverallData(dc, 'VirtualMazeData__8to12_slope.05.27.2015');

participantName = get(dc, 'name');
participantData = get(dc, 'data');

%% Run main and data should be collected and saved to workspace
% After that, run following commands to start data analysis
%% Start
% da = DataAnalyzer;
% initializeAnalyzer(da);
%% Create heat map. Pick correct inputs
% summaryHeatMap(da, DataAnalyzer.TYPICAL / DataAnalyzer.ATYPICAL, 8 / 11);
%% Plot average data. Data type can be changed in the function
% summaryParticipantGroup(da);
%% Plot correlation on heat map data to each participant's trial 6 to check their improvment
% createBaseLine(da, 8 / 11, type, value);
% plotAtypicalCorr(da, 8 / 11, type, value);
% type: gender, school, age
%% For more info, check README file