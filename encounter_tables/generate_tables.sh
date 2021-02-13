#!/usr/bin/env bash

./lpSolve_oracle.R --input foes/barrier_islands_foes.csv --region "Barrier Islands" --output oracles/barrier_islands_oracle.csv --rollScale 115
./lpSolve_oracle.R --input foes/ragged_coast_foes.csv --region "Ragged Coast" --output oracles/ragged_coast_oracle.csv --rollScale 118
./lpSolve_oracle.R --input foes/deep_wilds_foes.csv --region "Deep Wilds" --output oracles/deep_wilds_oracle.csv --rollScale 130
./lpSolve_oracle.R --input foes/flooded_lands_foes.csv --region "Flooded Lands" --output oracles/flooded_lands_oracle.csv 
./lpSolve_oracle.R --input foes/havens_foes.csv --region "Havens" --output oracles/havens_oracle.csv --minProb 0.01 --rollScale 105
./lpSolve_oracle.R --input foes/hinterlands_foes.csv --region "Hinterlands" --output oracles/hinterlands_oracle.csv --rollScale 105
./lpSolve_oracle.R --input foes/tempest_hills_foes.csv --region "Tempest Hills" --output oracles/tempest_hills_oracle.csv --rollScale 117
./lpSolve_oracle.R --input foes/veiled_mountains_foes.csv --region "Veiled Mountains" --output oracles/vieled_mountains_oracle.csv --rollScale 125
./lpSolve_oracle.R --input foes/shattered_wastes_foes.csv --region "Shattered Wastes" --output oracles/shattered_wastes_oracle.csv
