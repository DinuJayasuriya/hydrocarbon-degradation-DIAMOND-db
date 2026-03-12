#!/bin/bash
#PBS -N diamond_makedb
#PBS -l select=1:ncpus=16:mem=124gb:interconnect=fdr,walltime=24:00:00
#PBS -m abe
#PBS -M djayasu@g.clemson.edu
#PBS -k oe

# ============================================================
# Step 4: Build DIAMOND Database
# Description: Compile dereplicated sequences into a
#              DIAMOND-formatted protein database
# ============================================================

# ---- USER-DEFINED PATHS (edit before running) ----
DEREP_FASTA="/path/to/concat_all_derep"                        # CD-HIT output from Step 3
DB_OUTPUT="/path/to/output/curated_all_PAH_keygens"            # Output database prefix
# --------------------------------------------------

module add diamond/2.0.14

echo "Building DIAMOND database..."
diamond makedb \
    --in ${DEREP_FASTA} \
    -d ${DB_OUTPUT}

echo "DIAMOND database built successfully."
echo "Database file: ${DB_OUTPUT}.dmnd"
echo ""
echo "This database contains 9,448 unique protein sequences"
echo "representing 37 hydrocarbon degradation genes."
echo "Proceed to Step 5a (metagenome) or 5b (metatranscriptome) for screening."
