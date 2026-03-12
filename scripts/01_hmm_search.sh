#!/bin/bash
#PBS -N hmm_search
#PBS -l select=1:ncpus=16:mem=124gb:interconnect=fdr,walltime=24:00:00
#PBS -m abe
#PBS -M djayasu@g.clemson.edu
#PBS -k oe

# ============================================================
# Step 1: HMM Search
# Description: Search CANT-HYD HMMs against NCBI-nr and GTDB
#              using trusted cutoff scores to identify
#              hydrocarbon degradation gene hits
# ============================================================

# ---- USER-DEFINED PATHS (edit before running) ----
CANTHYD_HMM_DIR="/path/to/CANT-HYD/hmms"          # Directory containing 37 CANT-HYD .hmm files
NCBI_NR_DB="/path/to/All_nr_proteins_bac.ar.faa"  # NCBI-nr protein database
GTDB_DB="/path/to/rep_prot_bac.ar_ALL.fa"         # GTDB protein database
OUTPUT_NR="/path/to/output/Fullhits_nr"            # Output directory for NCBI-nr hits
OUTPUT_GTDB="/path/to/output/hits_gtdb"            # Output directory for GTDB hits
# --------------------------------------------------

module add hmmer/3.x   # Replace with your available version

mkdir -p $OUTPUT_NR $OUTPUT_GTDB

# Search against NCBI-nr
echo "Searching CANT-HYD HMMs against NCBI-nr..."
for hmm in $CANTHYD_HMM_DIR/*.hmm
do
    gene=$(basename $hmm .hmm)
    hmmsearch --cut_tc \
              --tblout $OUTPUT_NR/${gene}_nr_hits.txt \
              $hmm $NCBI_NR_DB
done

# Search against GTDB
echo "Searching CANT-HYD HMMs against GTDB..."
for hmm in $CANTHYD_HMM_DIR/*.hmm
do
    gene=$(basename $hmm .hmm)
    hmmsearch --cut_tc \
              --tblout $OUTPUT_GTDB/${gene}_gtdb_hits.txt \
              $hmm $GTDB_DB
done

echo "HMM search complete."
echo "Hit lists written to: $OUTPUT_NR and $OUTPUT_GTDB"
