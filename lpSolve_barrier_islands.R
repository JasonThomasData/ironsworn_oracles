#!/usr/bin/env Rscript

# sudo apt install r-base
#install.packages("lpSolveAPI")

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

objective_coefficients = c(1,1,1,1,1,1,1,1,1,1,1,1,1) #One for each foe
lp_model = make.lp(0,13)
lp.control(lp_model, sense="max")
set.objfn(lp_model, objective_coefficients)

# Region          | Ironlander | Firstborn | Animal | Beast | Horror
# Barrier Islands | 0.4        | 0.1       | 0.2    | 0.1   | 0.2
add.constraint(lp_model, c(1,0,1,1,1,0,0,0,0,0,0,0,0), "<=", 0.4)
add.constraint(lp_model, c(0,0,0,0,0,0,0,0,0,1,0,0,0), "<=", 0.1)
add.constraint(lp_model, c(0,1,0,0,0,0,0,0,0,0,0,0,0), "<=", 0.2)
add.constraint(lp_model, c(0,0,0,0,0,0,0,0,1,0,0,0,1), "<=", 0.1)
add.constraint(lp_model, c(0,0,0,0,0,1,1,1,0,0,1,1,0), "<=", 0.2)

# Region          | Troublesome | Dangerous | Formidable | Extreme | Epic
# Barrier Islands | 0.2         | 0.35      | 0.25       | 0.18    | 0.03
add.constraint(lp_model, c(1,1,0,0,0,0,0,0,0,0,0,0,0), "<=", 0.2)
add.constraint(lp_model, c(0,0,1,1,1,1,0,0,0,0,0,0,0), "<=", 0.35)
add.constraint(lp_model, c(0,0,0,0,0,0,1,1,0,0,0,0,0), "<=", 0.25)
add.constraint(lp_model, c(0,0,0,0,0,0,0,0,1,1,1,1,0), "<=", 0.18)
add.constraint(lp_model, c(0,0,0,0,0,0,0,0,0,0,0,0,1), "<=", 0.03)

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

print("...")
print("probabilities based on ordered list of foes")
for(probability in probabilities) {
    roll=probability*tableRange
    roundedRoll=round(roll, digits=0)
    maxRoll=minimumRoll+roundedRoll
    print(sprintf("%i-%i", minimumRoll, maxRoll))
    minimumRoll=maxRoll+1
}

