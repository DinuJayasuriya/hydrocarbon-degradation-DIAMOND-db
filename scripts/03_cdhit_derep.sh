#!/bin/bash
#PBS -N cd_hits
#PBS -l select=1:ncpus=24:mem=125gb:interconnect=fdr,walltime=24:00:00
#PBS -m abe
#PBS -M djayasu@g.clemson.edu
#PBS -k oe

# ============================================================
# Step 3: Dereplication with CD-HIT
# Description: Concatenate all extracted sequences from NCBI-nr
#              and GTDB, then dereplicate at 95% identity
#              to produce a non-redundant reference set
# ============================================================

# ---- USER-DEFINED PATHS (edit before running) ----
EXTRACTED_NR="/path/to/extracted_nr"               # Extracted NCBI-nr sequences (with gene names in headers)
EXTRACTED_GTDB="/path/to/extracted_gtdb"           # Extracted GTDB sequences (with gene names in headers)
CONCAT_FASTA="/path/to/output/concat_all_fasta.faa"  # Combined output fasta
DEREP_OUTPUT="/path/to/output/concat_all_derep"    # CD-HIT output prefix
# --------------------------------------------------

module add cd-hit/4.8.1

# Concatenate all sequences from both databases
echo "Concatenating all extracted sequences..."
cat $EXTRACTED_NR/*.faa $EXTRACTED_GTDB/*.faa > $CONCAT_FASTA
echo "Total sequences before dereplication: $(grep -c '>' $CONCAT_FASTA)"

# Run CD-HIT dereplication at 95% identity
echo "Running CD-HIT dereplication at 95% identity..."
cd-hit \
    -i $CONCAT_FASTA \
    -o $DEREP_OUTPUT \
    -c 0.95 \
    -n 5 \
    -M 800

echo "Dereplication complete."
echo "Unique sequences after dereplication: $(grep -c '>' ${DEREP_OUTPUT})"
echo ""
echo "Expected output: ~9,448 unique non-redundant protein sequences"
echo "Proceed to Step 4 to build the DIAMOND database."
