## Methodology

- I read the Ironsworn manual and made a note of where each creature lives.

- For each region, made a note of which foes/animals/beasts etc lived there

- Categorised each foe according to its type [Ironlander,Firstborn,Animal,Beast,Horror]

- Ordered all of the foes in each region's table according to their rank

- Defined these probability tables:

Region | Troublesome | Dangerous | Formidable | Extreme | Epic
--- | --- | --- | --- | --- | ---
Global | 0.2 | 0.35 | 0.25 | 0.18 | 0.03
Barrier Islands | 0.2 | 0.35 | 0.25 | 0.18 | 0.03
Ragged Coast | 0.2 | 0.35 | 0.25 | 0.2 | 0
Deep Wilds | 0.2 | 0.35 | 0.25 | 0.2 | 0
Flooded Lands | 0.2 | 0.35 | 0.25 | 0.2
Havens | 0.3 | 0.3 | 0.25 | 0.15 | 0
Hinterlands | 0.15 | 0.25 | 0.3 | 0.3 | 0
Tempest Hills | 0.1 | 0.2 | 0.35 | 0.35 | 0
Veiled Mountains | 0.05 | 0.15 | 0.4 | 0.4 | 0
Shattered Wastes | 0 | 0.1 | 0.3 | 0.4 | 0.2

Region | Ironlander | Firstborn | Animal | Beast | Horror
--- | --- | --- | --- | --- | ---
Barrier Islands | 0.4 | 0.1 | 0.2 | 0.1 | 0.2
Ragged Coast | 0.35 | 0.1 | 0.25 | 0.1 | 0.2
Deep Wilds | 0.2 | 0.35 | 0.25 | 0.1 | 0.1
Flooded Lands | 0.15 | 0.15 | 0.25 | 0.25 | 0.2
Havens | 0.6 | 0.1 | 0.2 | 0.1 | 0.05
Hinterlands | 0.2 | 0.3 | 0.3 | 0.15 | 0.15
Tempest Hills | 0.15 | 0.2 | 0.3 | 0.2 | 0.15
Veiled Mountains | 0.1 | 0.2 | 0.4 | 0.3 | 0
Shattered Wastes | 0.01 | 0.19 | 0.3 | 0.3 | 0.2

- Used Rscript and lpSolveAPI to solve the optimimum probability for encountering each foe. This is an assignment task.

