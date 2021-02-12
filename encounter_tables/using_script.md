### On Debian-like operating systems, do:

    sudo apt install r-base

The first time you run the script may return an error about lib/. Run as suod

### Windows and Mac

I haven't tested on Mac and Windows, so install ```Rscript``` on your computer before running the script.

### Usage

```./lpSolve_oracle.R -h``` to see the required arguments.

EG:

    ./lpSolve_oracle.R --input barrier_islands_foes.csv --region "Barrier Islands" --output barrier_islands_oracle.csv

Optional arguments are:
    
    --minimum_prob = the minimum probability that a creature will appear in the output oracle, if it's present in the csv of enemies. Defailt is 0.02
    --rollScale = the absolute maximum valid roll, which should be above 100, so that a character with no experience should never meet Epic foes

### Modify how monsters appear

See the [your truths](your_truths.md) document for more on this.

