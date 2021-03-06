# @Author Feng Qiu

import sys
import numpy as np
import math
import matplotlib.pyplot as plt

NUM_OUTPUT = 10

def parseData(inputPath):
	labels = [] # true labels from input file
	data = [] # array of np arrays containing pixel values in int
	with open(inputPath, 'r') as inputFile:
		for inputLine in inputFile:
			inputLine = inputLine.split(",")
			labels.append(int(inputLine[0]))
			dataLine = np.zeros(len(inputLine) - 1);
			for index in range(len(inputLine) - 1):
				dataLine[index] = float(inputLine[index + 1])
			data.append(dataLine)
	return labels, data

def sigmoid(input):
	return 1.0 / (1.0 + np.exp(-input))

def initializeWeight(initMethod, numHiddenUnit, inputSize):
	alpha = np.zeros((numHiddenUnit, inputSize + 1))
	beta = np.zeros((NUM_OUTPUT, numHiddenUnit + 1))
	# random
	if(initMethod == "1"):
		alpha = np.random.uniform(low = -0.1, high = 0.1, size = (numHiddenUnit, inputSize + 1))
		beta = np.random.uniform(low = -0.1, high = 0.1, size = (NUM_OUTPUT, numHiddenUnit + 1))
		# still initialize bias to 0
		for i in range(numHiddenUnit):
			alpha[i][0] = 0
		for i in range(NUM_OUTPUT):
			beta[i][0] = 0
	return alpha, beta

def addBiasTerm(input):
	output = np.ones(len(input) + 1)
	output[1:len(input) + 1] = input
	return output

# def calculateWeight(trainLabels, trainData, validationLabels, validationData, initMethod, numHiddenUnit, numEpoch, learningRate):
def calculateWeight(trainLabels, trainData, initMethod, numHiddenUnit, numEpoch, learningRate):
	# trainCrossEntropies = []
	# validationCrossEntropies = []
	featureSize = len(trainData[0])
	alpha, beta = initializeWeight(initMethod, numHiddenUnit, featureSize)
	for epochIndex in range(numEpoch):
		print(epochIndex)
		for inputIndex in range(len(trainLabels)):
			# forward
			x = trainData[inputIndex]
			x = addBiasTerm(x)
			a = np.zeros(numHiddenUnit)
			for i in range(numHiddenUnit):
				a[i] = np.dot(alpha[i], x.transpose())
			z = np.ones(numHiddenUnit + 1)
			sigmoidA = sigmoid(a)
			z[1:len(z)] = sigmoidA
			b = np.zeros(NUM_OUTPUT)
			expB = np.zeros(NUM_OUTPUT)
			for i in range(NUM_OUTPUT):
				b[i] = np.dot(beta[i], z)
				expB[i] = np.exp(b[i])
			sumExpB = sum(expB)
			yhat = np.zeros(NUM_OUTPUT)
			# softmax
			for i in range(NUM_OUTPUT):
				yhat[i] = expB[i] / sumExpB

			# backward
			y = np.zeros(NUM_OUTPUT)
			thisLabel = trainLabels[inputIndex]
			y[thisLabel] = 1; # one-hot
			
			dJ_dyhat = -y / yhat
			dyhat_db = (np.diag(yhat)-np.outer(yhat, yhat.transpose()))
			db_dbeta = z
			dJ_db = np.dot(dJ_dyhat.transpose(), dyhat_db)
			dJ_dbeta = np.outer(dJ_db, z.transpose())

			db_dz = beta
			dz_da = z[1:] * (1 - z[1:])
			da_dalpha = x
			dJ_dz = np.dot(db_dz.transpose(), dJ_db)
			dJ_da = dJ_dz[1:] * dz_da
			dJ_dalpha = np.outer(dJ_da, da_dalpha.transpose())

			alpha = alpha - learningRate * dJ_dalpha
			beta = beta - learningRate * dJ_dbeta
			# print(alpha)
			# print(beta)
		# trainCrossEntropies.append(calculateCrossEntropy(trainLabels, trainData, alpha, beta))
		# validationCrossEntropies.append(calculateCrossEntropy(validationLabels, validationData, alpha, beta))
	# return alpha, beta, trainCrossEntropies, validationCrossEntropies
	return alpha, beta

# # for both final prediction & cross entropy calculation
def predict(alpha, beta, inputLabels, inputData):
	# forward, same as weight calculation
	prediction = []
	yhats = []
	for inputIndex in range(len(inputLabels)):
		x = inputData[inputIndex]
		x = addBiasTerm(x)
		a = np.zeros(numHiddenUnit)
		for i in range(numHiddenUnit):
			a[i] = np.dot(alpha[i], x.transpose())
		z = np.ones(numHiddenUnit + 1)
		sigmoidA = sigmoid(a)
		z[1:len(z)] = sigmoidA
		b = np.zeros(NUM_OUTPUT)
		expB = np.zeros(NUM_OUTPUT)
		for i in range(NUM_OUTPUT):
			b[i] = np.dot(beta[i], z)
			expB[i] = np.exp(b[i])
		sumExpB = sum(expB)
		yhat = np.zeros(NUM_OUTPUT)
		# softmax
		for i in range(NUM_OUTPUT):
			yhat[i] = expB[i] / sumExpB
		prediction.append(np.argmax(yhat))
		yhats.append(yhat)
	return prediction, yhats

# # def calculateMetrics(trueLabels, prediction):


# def calculateCrossEntropy(inputLabels, inputPixelLines, alpha, beta):
# 	sum = 0.0
# 	prediction, yhats = predict(alpha, beta, inputLabels, inputPixelLines)
# 	for index in range(len(inputLabels)):
# 		y = np.zeros(NUM_OUTPUT)
# 		thisLabel = inputLabels[index]
# 		y[thisLabel] = 1; # one-hot
# 		yhat = yhats[index]
# 		sum += np.dot(y, np.log(yhat))
# 	return (-1 * sum / len(inputLabels))

# # calculate and print error rate and cross entropies
# def calculateMetrics(trainLabels, trainResult, validationLabels, validationResult, trainCrossEntropies, validationCrossEntropies, outputPath):
# 	with open(outputPath, 'w') as outputFile:
# 		totalTrainSize = len(trainLabels)
# 		trainMiss = 0.0
# 		for actual, prediction in zip(trainLabels, trainResult):
# 			if(actual != prediction):
# 				trainMiss = trainMiss + 1.0
# 		totalValidationSize = len(validationLabels)
# 		validationMiss = 0.0
# 		for actual, prediction in zip(validationLabels, validationResult):
# 			if(actual != prediction):
# 				validationMiss = validationMiss + 1.0
# 		for epochIndex in range(len(trainCrossEntropies)):
# 			outputFile.write("epoch=%d crossentropy(train): %.11f\n" % (epochIndex, trainCrossEntropies[epochIndex]))
# 			outputFile.write("epoch=%d crossentropy(validation): %.11f\n" % (epochIndex, validationCrossEntropies[epochIndex]))
# 		outputFile.write("error(train): %.6f\n" % (trainMiss / totalTrainSize))
# 		outputFile.write("error(test): %.6f\n" % (validationMiss / totalValidationSize))

# def printPrediction(trainResult, validationResult, trainOutputPath, validationOutputPath):
# 	with open(trainOutputPath, 'w') as trainOutputFile:
# 		for prediction in trainResult:
# 			trainOutputFile.write(str(prediction))
# 			trainOutputFile.write("\n")
# 	with open(validationOutputPath, 'w') as validationOutputFile:
# 		for prediction in validationResult:
# 			validationOutputFile.write(str(prediction))
# 			validationOutputFile.write("\n")

if __name__ == '__main__':
	# trainInput = sys.argv[1]
	# validationInput = sys.argv[2]
	# trainOutput = sys.argv[3]
	# validationOutput = sys.argv[4]
	# metricsOutput = sys.argv[5]
	# numEpoch = int(sys.argv[6])
	# numHiddenUnit = int(sys.argv[7])
	# initMethod = sys.argv[8]
	# learningRate = float(sys.argv[9])

	trainInput = "../overallDataConverted.csv"
	initMethod = 2 # 1 for random, 2 for zeros
	numHiddenUnit = 20
	learningRate = 0.1
	numEpoch = 100

	trainLabels, trainData = parseData(trainInput)
	# validationLabels, validationPixelLines = parseData(validationInput)
	# alpha, beta, trainCrossEntropies, validationCrossEntropies = calculateWeight(trainLabels, trainPixelLines, validationLabels, validationPixelLines, 
	#  initMethod, numHiddenUnit, numEpoch, learningRate)

	alpha, beta = calculateWeight(trainLabels, trainData, initMethod, numHiddenUnit, numEpoch, learningRate)
	trainResult, _ = predict(alpha, beta, trainLabels, trainData)
	print trainLabels
	print trainResult

	# validationResult, _ = predict(alpha, beta, validationLabels, validationPixelLines)
	# calculateMetrics(trainLabels, trainResult, validationLabels, validationResult, trainCrossEntropies, validationCrossEntropies, metricsOutput)
	# printPrediction(trainResult, validationResult, trainOutput, validationOutput)




	





