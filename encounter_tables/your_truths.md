Note: the probabilities in [foe type probabilities](foe_type_probabilities.csv) and [foe_rank_probabilities](foe_rank_probabilities.csv) should be at least the value of the --minProb argument, which is 0.02 by default.

### I want a low fantasy game with only animals and humans 

In the [foe type probabilities](foe_type_probabilities.csv) table, set humans and animals to add up to 1, for each region. Reduce everything else to 0.

### I think there should be more humans in the Havens

Change the [foe type probabilities](foe_type_probabilities.csv) table. Each region (row) should add up to 1.

### I want to see more/fewer enemies of a certain rank in a certain region

Change the [foe_rank_probabilities](foe_rank_probabilities.csv) table. Each region (row) should add up to 1.

### I want to change the foes that appear in a particular region

Change the relevant \*\_foes.csv table for that region. Take care that easy enemies should appear higher and within ranks/types, common enemies appear higher.

