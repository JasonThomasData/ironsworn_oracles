#!/usr/bin/env Rscript

# sudo apt install r-base

packages = c("argparser", "lpSolveAPI")

for(package in packages) {
    if (!require(package, character.only = TRUE)) {
      install.packages(package, dependencies = TRUE)
    }
    library(package, character.only = TRUE)
}

getCoefficientsForValueInColumn = function(foeData, nominatedValue, columnName) {
    coefficients = c() 
    values = foeData[, columnName]
    for (value in values) {
        if(value == nominatedValue) {
            coefficients = append(coefficients, 1)
        } else {
            coefficients = append(coefficients, 0)
        }
    }
    (coefficients)
}

getProbabilitiesForThisRegion = function(probabilities, region) {
    (probabilities[probabilities$Region==region,])
}

removeFoesIfProbabilityIsTooLow = function(probabilityTable, foeData, toRemoveFromFoeData, minProb) {
    for(probabilityColumnName in colnames(probabilityTable)) {
        rowData = probabilityTable[,probabilityColumnName]
        if(!is.numeric(rowData)) {
            next
        }
        probability = rowData
        if(probability < minProb || probability == 0) {
            foeData = foeData[foeData[,toRemoveFromFoeData] != probabilityColumnName,]
        }
    }
    (foeData)
}

addTypeConstraints = function(lpModel, foeData, foeTypeProbababilitiesForRegion) {
    ironlanderCoefficients = getCoefficientsForValueInColumn(foeData, "Ironlander", "Type") 
    firstbornCoefficients = getCoefficientsForValueInColumn(foeData, "Firstborn", "Type") 
    animalCoefficients = getCoefficientsForValueInColumn(foeData, "Animal", "Type") 
    beastCoefficients = getCoefficientsForValueInColumn(foeData, "Beast", "Type")
    horrorCoefficients = getCoefficientsForValueInColumn(foeData, "Horror", "Type")
    add.constraint(lpModel, ironlanderCoefficients, "<=", foeTypeProbababilitiesForRegion[, "Ironlander"])
    add.constraint(lpModel, firstbornCoefficients, "<=", foeTypeProbababilitiesForRegion[, "Firstborn"])
    add.constraint(lpModel, animalCoefficients, "<=", foeTypeProbababilitiesForRegion[, "Animal"])
    add.constraint(lpModel, beastCoefficients, "<=", foeTypeProbababilitiesForRegion[, "Beast"])
    add.constraint(lpModel, horrorCoefficients, "<=", foeTypeProbababilitiesForRegion[, "Horror"])
}

addRankConstraints = function(lpModel, foeData, foeRankProbababilitiesForRegion) {
    troublesomeCoefficients = getCoefficientsForValueInColumn(foeData, "Troublesome", "Rank") 
    dangerousCoefficients = getCoefficientsForValueInColumn(foeData, "Dangerous", "Rank") 
    formidableCoefficients = getCoefficientsForValueInColumn(foeData, "Formidable", "Rank") 
    extremeCoefficients = getCoefficientsForValueInColumn(foeData, "Extreme", "Rank")
    epicCoefficients = getCoefficientsForValueInColumn(foeData, "Epic", "Rank")
    add.constraint(lpModel, troublesomeCoefficients, "<=", foeRankProbababilitiesForRegion[, "Troublesome"])
    add.constraint(lpModel, dangerousCoefficients, "<=", foeRankProbababilitiesForRegion[, "Dangerous"])
    add.constraint(lpModel, formidableCoefficients, "<=", foeRankProbababilitiesForRegion[, "Formidable"])
    add.constraint(lpModel, extremeCoefficients, "<=", foeRankProbababilitiesForRegion[, "Extreme"])
    add.constraint(lpModel, epicCoefficients, "<=", foeRankProbababilitiesForRegion[, "Epic"])
}


updateFoeDataWithDiceRolls = function(probabilities, rollScale) {
    minimumRoll=1
    rolls = c()
    for(probability in probabilities) {
        roll=probability*rollScale
        roundedRoll=floor(roll)
        maxRoll=minimumRoll+roundedRoll
        rollRangeForFoe=sprintf("%i-%i", minimumRoll, maxRoll)
        minimumRoll=maxRoll+1
        rolls = append(rolls, rollRangeForFoe)
    }
    foeData$Rolls <- rolls
    foeData = foeData[,c(4,1,2,3)]
    (foeData)
}

addConstraintForMinimumFoeProbability = function(lpModel, numberOfFoes, minProb) {
    for(i in 1:numberOfFoes) {
        constraintDummy = rep(0, numberOfFoes)
        constraintDummy[i] = 1
        add.constraint(lpModel, constraintDummy, ">=", minProb)
    }
}

addConstraintForMaximumFoeProbability = function(lpModel, numberOfFoes, maxProb) {
    for(i in 1:numberOfFoes) {
        constraintDummy = rep(0, numberOfFoes)
        constraintDummy[i] = 1
        add.constraint(lpModel, constraintDummy, "<=", maxProb)
    }
}

getTerminalArgs = function() {
    parser = arg_parser("Generate enemy encounter oracles for Ironsworn by region")
    parser = add_argument(parser, "--region", help="The region to generate the encounter table for", type="character")
    parser = add_argument(parser, "--input", help="The file for foes found within the region", type="character")
    parser = add_argument(parser, "--output", help="The same file, with dice rolls prepended", type="character")
    parser = add_argument(parser, "--minProb", help="The minimum probability that a creature will appear in the output oracle, if it's present in the csv of enemies. Valid between 0,1", default=0.02)
    parser = add_argument(parser, "--maxProb", help="The maximum probability that a creature will appear in the output oracle, if it's present in the csv of enemies. Valid between 0,1", default=0.1)
    parser = add_argument(parser, "--rollScale", help="The absolute maximum valid roll, which should be above 100, so that a character with no experience should never meet Epic foes.", default=120)
    argv = parse_args(parser)
    regions = c("Barrier Islands", "Ragged Coast", "Deep Wilds", "Flooded Lands", "Havens", "Hinterlands", "Tempest Hills", "Veiled Mountains", "Shattered Wastes")
    if(!is.element(argv$region, regions)) {
        print(parser)
        return (1)
    }
    if(argv$minProb < 0 || argv$minProb > 1) {
        print(parser)
        return (1)
    }
    if(argv$maxProb < 0 || argv$maxProb > 1) {
        print(parser)
        return (1)
    }
    if(argv$rollScale < 100) {
        print(parser)
        return (1)
    }
    (argv)
}

padProbabilities = function(probabilities, totalProbabilities) {
    desiredTotalProbabilities = 1.0
    paddedProbabilities = c()
    probabilityGap = desiredTotalProbabilities - totalProbabilities
    for(probability in probabilities) {
        paddedProbability = probability + (probability * probabilityGap)
        paddedProbabilities = append(paddedProbabilities, paddedProbability)
    }
    (paddedProbabilities)
}

argv = getTerminalArgs()
region = argv$region
minProb = argv$minProb
maxProb = argv$maxProb
rollScale = argv$rollScale
outputFileName = argv$output

foeData = read.csv(argv$input)
writeLines("Using foe data for this region:")
print(foeData)

foeTypeProbababilities = read.csv("foe_type_probabilities.csv")
foeRankProbababilities = read.csv("foe_rank_probabilities.csv")

foeTypeProbababilitiesForRegion = getProbabilitiesForThisRegion(foeTypeProbababilities, region)
writeLines("Using foe types:")
print(foeTypeProbababilitiesForRegion)
foeRankProbababilitiesForRegion = getProbabilitiesForThisRegion(foeRankProbababilities, region)
writeLines("Using foe ranks:")
print(foeRankProbababilitiesForRegion)

foeData = removeFoesIfProbabilityIsTooLow(foeTypeProbababilitiesForRegion, foeData, "Type", minProb)
foeData = removeFoesIfProbabilityIsTooLow(foeRankProbababilitiesForRegion, foeData, "Rank", minProb)

numberOfFoes = length(foeData[,"Foe"])

lpModel = make.lp(0, numberOfFoes)
lp.control(lpModel, sense="max")
objectiveCoefficients = rep(1, numberOfFoes) #One for each foe
set.objfn(lpModel, objectiveCoefficients)

addTypeConstraints(lpModel, foeData, foeTypeProbababilitiesForRegion)
addRankConstraints(lpModel, foeData, foeRankProbababilitiesForRegion)

addConstraintForMinimumFoeProbability(lpModel, numberOfFoes, minProb)
addConstraintForMaximumFoeProbability(lpModel, numberOfFoes, maxProb)

solve(lpModel)

probabilities=get.variables(lpModel)
writeLines("Probabilities based on ordered list of foes:")
print(probabilities)
totalProbabilities = sum(probabilities)
if(totalProbabilities != 1) {
    writeLines("These probabilities do not equal 1. This could be optimised further by changing the probability tables and foes list")
    probabilities = padProbabilities(probabilities, totalProbabilities)
    writeLines(sprintf("Probabilities adjusted to equal: %f", sum(probabilities)))
    writeLines("Probabilities since being adjusted:")
    print(probabilities)
}

foeData = updateFoeDataWithDiceRolls(probabilities, rollScale)

write.csv(foeData, outputFileName, row.names=FALSE)

writeLines("Result:")
print(foeData)
writeLines(sprintf("File saved at %s", outputFileName))
