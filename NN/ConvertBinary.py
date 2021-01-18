# @Author Feng Qiu
# Everything but gender_dummy and teacher are converted to numbers for NN input

import csv
entryName = []
fileData = []

def parseFile(inputPath):
	global fileData, entryName
	with open(inputPath, 'r') as inputFile:
		reader = csv.reader(inputFile, delimiter = ",", quotechar = '"')
		fileData = [row for row in reader]
	# retrieve column names
	entryName = fileData.pop(0)
		
def convert():
	global filaData
	for row in fileData:
		# known result
		group = row[16]
		# remove not used data
		row.pop(7) # school
		row.pop(6) # teacher
		row.pop(3) # dummy gender
		row.pop(1) # DOB
		row.pop(0) # name

		
		
		
		

		# push the known result to the front
		row.pop(16)
		row.insert(0, group)
		
def writeResult(outputPath):
	with open(outputPath, 'w+') as outputFile:
		writer = csv.writer(outputFile, delimiter = ",")
		writer.writerows(fileData)


if __name__ == '__main__':
	# filename = sys.argv[1]
	inputFile = "../overallData.csv"
	outputFile = "../overallDataConverted.csv"
	parseFile(inputFile)
	convert()
	writeResult(outputFile)