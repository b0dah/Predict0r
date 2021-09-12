import Cocoa
import CreateML

let dataTable = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/bodah/dev/TweetSentimentModelMaker/twitter-sanders-apple3.csv"))

let (trainingData, testingData) = dataTable.randomSplit(by: 0.8, seed: 1)

let classifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "class")

let evaluationMetrics = classifier.evaluation(on: testingData, textColumn: "text", labelColumn: "class")

let evaluationAccuracy = (1 - evaluationMetrics.classificationError)

let metaData = MLModelMetadata(author: "Evan Bodah", shortDescription: "A model to classify sentiment on tweets", version: "1.0.0")

try classifier.write(to: URL(fileURLWithPath: "/Users/bodah/dev/TweetSentimentModelMaker/TweetSentimentalClassifier.mlmodel"))

try classifier.prediction(from: "Just baught a new iPhone from @Apple!")
