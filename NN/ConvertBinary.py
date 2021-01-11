# @Author Feng Qiu
# Everything but gender_dummy and teacher are converted to numbers for NN input

import csv

def parseFile(inputPath):
	with open(inputPath) as inputFile:
		reader = csv.reader(inputFile, delimiter = ",", quotechar = '"')
		fileData = [row for row in reader]
	print(fileData[0])



if __name__ == '__main__':
	# filename = sys.argv[1]
	filename = "../overallData.csv"