### On Debian-like operating systems, do:

    sudo apt install r-base

The first time you run the script may return an error about lib/. Run as suod

### Windows and Mac

Download from https://cran.r-project.org/mirrors.html

I haven't tested so IDK, maybe raise an issue if it doesn't work.

### Usage

```./lpSolve_oracle.R -h``` to see the required arguments.

See the commands in [generate_tables.sh](generate_tables.sh) for examples of commands to run.

The easiest way to use this software is to update the foe_*_probability.csv tables and foes/*foes.csv files, and then run ```./generate_tables.sh```

Optional arguments are:

    --minimum_prob = the minimum probability that a creature will appear in the output oracle, if it's present in the csv of enemies
    --rollScale = the absolute maximum valid roll, which should be above 100, so that a character with no experience should never meet Epic foes

### Modify how monsters appear

See the [your truths](your_truths.md) document for more on this.

