classdef Participant
    properties
        name;
        group;
        dataTableMaze1;
        dataTableMaze5;
        dataTableMaze6;
        dataTableMaze8;
        dataTableMaze11;
        dataTableMaze12;
        
        dataTableMaze8HeatMap;
        dataTableMaze11HeatMap;
    end
    methods
        function obj = Participant(name, group)
            obj.name = name;
            obj.group = group;
            obj.dataTableMaze1 = table;
            obj.dataTableMaze5 = table;
            obj.dataTableMaze6 = table;
            obj.dataTableMaze8 = table;
            obj.dataTableMaze11 = table;
            obj.dataTableMaze12 = table;
            obj.dataTableMaze8HeatMap = table;
            obj.dataTableMaze11HeatMap = table;
        end
       
        function obj = addDataTable(obj, dataTable)
            switch(cell2mat(dataTable.Apparatus)) 
            case 'Maze 1'
                obj.dataTableMaze1 = [obj.dataTableMaze1; dataTable];
            case 'Maze 5'
                obj.dataTableMaze5 = [obj.dataTableMaze5; dataTable];
            case 'Maze 6'
                obj.dataTableMaze6 = [obj.dataTableMaze6; dataTable];
            case 'Maze 8'
                obj.dataTableMaze8 = [obj.dataTableMaze8; dataTable];
            case 'Maze 11'
                obj.dataTableMaze11 = [obj.dataTableMaze11; dataTable];
            case 'Maze 12'
                obj.dataTableMaze12 = [obj.dataTableMaze12; dataTable]; 
            otherwise
                warning('Maze num not recognized!')  
            end  
        end
        
        function obj = addHeatMapTable(obj, dataTable, mazeIndex)
            switch(mazeIndex)
                case 8
                    obj.dataTableMaze8HeatMap = [obj.dataTableMaze8HeatMap; dataTable];
                case 11
                    obj.dataTableMaze11HeatMap = [obj.dataTableMaze11HeatMap; dataTable];
            end
        end
        
        function returnObj = get(obj, propertyName)
           switch(propertyName)
               case 'name'
                   returnObj = obj.name;
               case 'group'
                   returnObj = obj.group;
               case 1
                   returnObj = obj.dataTableMaze1;
               case 5
                   returnObj = obj.dataTableMaze5;
               case 6
                   returnObj = obj.dataTableMaze6;
               case 8
                   returnObj = obj.dataTableMaze8;
               case 11
                   returnObj = obj.dataTableMaze11;
               case 12
                   returnObj = obj.dataTableMaze12;
               case 'heatMap8'
                   returnObj = obj.dataTableMaze8HeatMap;
               case 'heatMap11'
                   returnObj = obj.dataTableMaze11HeatMap;
           end
        end
   end
    
end