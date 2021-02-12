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

getProbabilitiesForThisRegion = function(probababilities, region) {
    (probababilities[probababilities$Region==region,])
}

parser = arg_parser("Generate enemy encounter oracles for Ironsworn by region")
parser = add_argument(parser, "--region", help="The region to generate the encounter table for", type="character")
parser = add_argument(parser, "--input", help="The file for foes found within the region", type="character")
parser = add_argument(parser, "--output", help="The same file, with dice rolls prepended", type="character")
parser = add_argument(parser, "--minProb", help="The minimum probability that a creature will appear in the output oracle, if it's present in the csv of enemies. Valid between 0,1", default=0.02)
parser = add_argument(parser, "--rollScale", help="The absolute maximum valid roll, which should be above 100, so that a character with no experience should never meet Epic foes.", default=120)
argv = parse_args(parser)
regions = c("Barrier Islands", "Ragged Coast", "Deep Wilds", "Flooded Lands", "Havens", "Hinterlands", "Tempest Hills", "Veiled Mountains", "Shattered Wastes")
if(!is.element(argv$region, regions)) {
    print(parser)
    return (1)
}
region = argv$region
if(argv$minProb < 0 || argv$minProb > 1) {
    print(parser)
    return (1)
}
minProb = argv$minProb
if(argv$rollScale < 100) {
    print(parser)
    return (1)
}
foeData = read.csv(argv$input)
outputFileName = argv$output

writeLines("Using foe data for this region:")
print(foeData)

foeTypeProbababilities = read.csv("foe_type_probabilities.csv")
foeRankProbababilities = read.csv("foe_rank_probabilities.csv")

foeTypeProbababilitiesForRegion = getProbabilitiesForThisRegion(foeTypeProbababilities, region)
foeRankProbababilitiesForRegion = getProbabilitiesForThisRegion(foeRankProbababilities, region)

writeLines("Using foe types:")
print(foeTypeProbababilitiesForRegion)
writeLines("Using foe ranks:")
print(foeRankProbababilitiesForRegion)

numberOfFoes = length(foeData[,"Foe"])
objective_coefficients = rep(1, numberOfFoes) #One for each foe
lp_model = make.lp(0, numberOfFoes)
lp.control(lp_model, sense="max")
set.objfn(lp_model, objective_coefficients)

ironlanderCoefficients = getCoefficientsForValueInColumn(foeData, "Ironlander", "Type") 
firstbornCoefficients = getCoefficientsForValueInColumn(foeData, "Firstborn", "Type") 
animalCoefficients = getCoefficientsForValueInColumn(foeData, "Animal", "Type") 
beastCoefficients = getCoefficientsForValueInColumn(foeData, "Beast", "Type")
horrorCoefficients = getCoefficientsForValueInColumn(foeData, "Horror", "Type")
add.constraint(lp_model, ironlanderCoefficients, "<=", foeTypeProbababilitiesForRegion[, "Ironlander"])
add.constraint(lp_model, firstbornCoefficients, "<=", foeTypeProbababilitiesForRegion[, "Firstborn"])
add.constraint(lp_model, animalCoefficients, "<=", foeTypeProbababilitiesForRegion[, "Animal"])
add.constraint(lp_model, beastCoefficients, "<=", foeTypeProbababilitiesForRegion[, "Beast"])
add.constraint(lp_model, horrorCoefficients, "<=", foeTypeProbababilitiesForRegion[, "Horror"])

troublesomeCoefficients = getCoefficientsForValueInColumn(foeData, "Troublesome", "Rank") 
dangerousCoefficients = getCoefficientsForValueInColumn(foeData, "Dangerous", "Rank") 
formidableCoefficients = getCoefficientsForValueInColumn(foeData, "Formidable", "Rank") 
extremeCoefficients = getCoefficientsForValueInColumn(foeData, "Extreme", "Rank")
epicCoefficients = getCoefficientsForValueInColumn(foeData, "Epic", "Rank")
add.constraint(lp_model, troublesomeCoefficients, "<=", foeRankProbababilitiesForRegion[, "Troublesome"])
add.constraint(lp_model, dangerousCoefficients, "<=", foeRankProbababilitiesForRegion[, "Dangerous"])
add.constraint(lp_model, formidableCoefficients, "<=", foeRankProbababilitiesForRegion[, "Formidable"])
add.constraint(lp_model, extremeCoefficients, "<=", foeRankProbababilitiesForRegion[, "Extreme"])
add.constraint(lp_model, epicCoefficients, "<=", foeRankProbababilitiesForRegion[, "Epic"])

for(i in 1:numberOfFoes) {
    constraint_dummy = rep(0, numberOfFoes)
    constraint_dummy[i] = 1
    add.constraint(lp_model, constraint_dummy, ">", minProb)
}

solve(lp_model)

probabilities=get.variables(lp_model)
writeLines("probabilities based on ordered list of foes")
print(probabilities)

tableRange=120
minimumRoll=1
rolls = c()
newTableWithRolls = data.frame()

for(probability in probabilities) {
    roll=probability*tableRange
    roundedRoll=round(roll, digits=0)
    maxRoll=minimumRoll+roundedRoll
    rollRangeForFoe=sprintf("%i-%i", minimumRoll, maxRoll)
    minimumRoll=maxRoll+1
    rolls = append(rolls, rollRangeForFoe)
}
foeData$Rolls <- rolls

foeData = foeData[,c(4,1,2,3)]
write.csv(foeData, outputFileName, row.names=F)

writeLines("Result:")
print(foeData)
writeLines(sprintf("File saved at %s", outputFileName))
