#!/usr/bin/env Rscript

# sudo apt install r-base
#install.packages("argparser")
#install.packages("lpSolveAPI")

library("argparser")
library("lpSolveAPI")

# From randomEnemyEncounter.odt
# Foe | Type | Rank
# --- | --- | ---
# Common folk | Ironlander | Troublesome
# Marsh rat   | Animal | Troublesome
# Raider | Ironlander | Dangerous
# Mystic | Ironlander | Dangerous
# Warrior | Ironlander | Dangerous
# Bonewalker | Horror | Dangerous
# Sodden | Horror | Formidable most common horror
# Haunt | Horror | Formidable
# Tawny Wyvern | Beast | Extreme
# Sea Primordial | Firstborn | Extreme
# Iron Revenant | Horror | Extreme
# Chimera | Horror | Extreme
# Leviathan | Beast | Epic

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
argv = parse_args(parser)
regions = c("Barrier Islands", "Ragged Coast", "Deep Wilds", "Flooded Lands", "Havens", "Hinterlands", "Tempest Hills", "Veiled Mountains", "Shattered Wastes")
if(!is.element(argv$region, regions)) {
    print(parser)
}
region = argv$region
foeData = read.csv(argv$input)
outputFileName = argv$output



foeTypeProbababilities = read.csv("foe_type_probabilities.csv")
foeRankProbababilities = read.csv("foe_rank_probabilities.csv")

foeTypeProbababilitiesForRegion = getProbabilitiesForThisRegion(foeTypeProbababilities, region)
foeRankProbababilitiesForRegion = getProbabilitiesForThisRegion(foeRankProbababilities, region)

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

# All creatures have a minimum 2% chance
add.constraint(lp_model, c(1,0,0,0,0,0,0,0,0,0,0,0,0), ">", 0.02)
add.constraint(lp_model, c(0,1,0,0,0,0,0,0,0,0,0,0,0), ">", 0.02)
add.constraint(lp_model, c(0,0,1,0,0,0,0,0,0,0,0,0,0), ">", 0.02)
add.constraint(lp_model, c(0,0,0,1,0,0,0,0,0,0,0,0,0), ">", 0.02)
add.constraint(lp_model, c(0,0,0,0,1,0,0,0,0,0,0,0,0), ">", 0.02)
add.constraint(lp_model, c(0,0,0,0,0,1,0,0,0,0,0,0,0), ">", 0.02)
add.constraint(lp_model, c(0,0,0,0,0,0,1,0,0,0,0,0,0), ">", 0.02)
add.constraint(lp_model, c(0,0,0,0,0,0,0,1,0,0,0,0,0), ">", 0.02)
add.constraint(lp_model, c(0,0,0,0,0,0,0,0,1,0,0,0,0), ">", 0.02)
add.constraint(lp_model, c(0,0,0,0,0,0,0,0,0,1,0,0,0), ">", 0.02)
add.constraint(lp_model, c(0,0,0,0,0,0,0,0,0,0,1,0,0), ">", 0.02)
add.constraint(lp_model, c(0,0,0,0,0,0,0,0,0,0,0,1,0), ">", 0.02)
add.constraint(lp_model, c(0,0,0,0,0,0,0,0,0,0,0,0,1), ">", 0.02)

solve(lp_model)

probabilities=get.variables(lp_model)
print(probabilities)

tableRange=120
minimumRoll=1
rolls = c()
newTableWithRolls = data.frame()

print("...")
print("probabilities based on ordered list of foes")
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