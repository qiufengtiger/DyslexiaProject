# DyslexiaProject
This program is created for Dyslexia Project in Lafayette College in Summer 2019.

The program is used to predict typical and atypical participant based on their proformance in running the maze. It plots data trendlines and corrlations that helps to find the criterion.

## How to use
### Add data files
First create a folder called 'data' in the root directory. It will contain all the csv data file. 
If reading a maze-specific data file, add it to `fileNameArray` in Parameters.m with only the file name (remove expansion .csv). Otherwise, use corresponding readFileXXX method in `main.m`. 

e.g.
```
fileNameArray = ["2013-05-28_MAZE1",  "2013-05-28_MAZE5"];
readFileHeatMap(dc, 'Combined_Maze_11_data_UPDATED_PE', 11);
readFileOverallData(dc, 'VirtualMazeData__8to12_slope.05.27.2015');
```

### Start the program
To collect data and save them to Matlab workspace, run:
```
main
```` 
It will read all the data files, initialize a DataCollector and save all the data to workspace. 
What you are looking for is a cell array called `participantData`, where all the data are sorted by participant ID. 

### Start DataAnalyzer
All the analyzing functions are in class DataAnalyzer. To run `DataAnalyzer`:
```
da = DataAnalyzer;
initializeAnalyzer(da);
```
`da` will be the object name of the DataAnalyzer. It is a handle class so no need to do `da = initializeAnalyzer(da);`. 
`initializeAnalyzer(da)` will read data from base workspace and store in `DataAnalyzer`.

### Run correlation
Run correlation on heatmaps will compare the heatmap data to a certain reference. To run correlation on typical participants:
```
createBaseLine(da, mazeIndex, type, value);
```
`mazeIndex` can either be 8 or 11, because only these 2 mazes have heatmap data. `type` can be 'school', 'age' or 'gender', so the correlation analysis will only run on specified group.

To check or change how data are read from overallData file and stored in each participant, 
go to function `readFileOverallData` in class `DataCollector`.

To check or change all `type` & `value` pairs, go to `properties` in class `Participant`.

To check or change how data are filtered according to `type` & `value`, go to function `findInGroup` in class `DataAnalyzer`.

To check or change the reference of the correlation, go to variable `standard` in function `applyCorrelation` in class `DataAnalyzer`. 

e.g.

```
createBaseLine(da, 8, 'none', 0);
createBaseLine(da, 8, 'age', Participant.AGE_GROUP1);
createBaseLine(da, 11, 'gender', Participant.MALE);
```

### Draw heatmaps
The program can also draw average heatmaps of all 6 trials of a specific maze.
To plot heatmaps, run:
```
summaryHeatMap(da, participantType, mazeIndex);
```
`participantType` can either be `DataAnalyzer.TYPICAL` or `DataAnalyzer.ATYPICAL`.

`mazeIndex` can either be `8` or `11`.

It will plot heatmaps of the average of each trial along with the average of all 6 trials.

e.g.
```
summaryHeatMap(da, DataAnalyzer.TYPICAL, 8);
```

### Plot average data
To plot average data trendlines of all mazes:
```
summaryParticipantGroup(da, dataType);
```

It will plot the specified data of typical vs. atypical.

Available `dataType`:

```
DataAnalyzer.DURATION
DataAnalyzer.DISTANCE
DataAnalyzer.MEAN_SPEED
DataAnalyzer.FROZEN_TIME
DataAnalyzer.TOTAL_ERROR
```

## Author
* Feng Qiu - [qiufengtiger](https://github.com/qiufengtiger)

(Feel free to contact me if you have questions! Also I will add you to the collaborator if you wish to have full access to this git to continue this research and update this program!)
