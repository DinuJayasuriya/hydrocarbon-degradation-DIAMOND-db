#!/bin/bash
#PBS -N extract_fasta
#PBS -l select=1:ncpus=16:mem=124gb:interconnect=fdr,walltime=24:00:00
#PBS -m abe
#PBS -M djayasu@g.clemson.edu
#PBS -k oe

# ============================================================
# Step 2: Extract Sequences Using seqtk
# Description: Extract fasta sequences from NCBI-nr and GTDB
#              based on HMM hit lists from Step 1
# ============================================================

# ---- USER-DEFINED PATHS (edit before running) ----
NCBI_NR_DB="/path/to/All_nr_proteins_bac.ar.faa"  # NCBI-nr protein database
GTDB_DB="/path/to/rep_prot_bac.ar_ALL.fa"         # GTDB protein database
HITS_NR="/path/to/Fullhits_nr"                     # Directory with NCBI-nr hit .txt files
HITS_GTDB="/path/to/hits_gtdb"                     # Directory with GTDB hit .txt files
OUTPUT_NR="/path/to/output/extracted_nr"           # Output extracted NCBI-nr sequences
OUTPUT_GTDB="/path/to/output/extracted_gtdb"       # Output extracted GTDB sequences
# --------------------------------------------------

module add seqtk/1.3-r106

mkdir -p $OUTPUT_NR $OUTPUT_GTDB

# Extract sequences from NCBI-nr
echo "Extracting sequences from NCBI-nr..."
for i in $HITS_NR/*.txt
do
    base=$(basename $i .txt)
    seqtk subseq $NCBI_NR_DB $i > $OUTPUT_NR/fasta.${base}.nr.faa
done

# Extract sequences from GTDB
echo "Extracting sequences from GTDB..."
for i in $HITS_GTDB/*.txt
do
    base=$(basename $i .txt)
    seqtk subseq $GTDB_DB $i > $OUTPUT_GTDB/fasta.${base}.gtdb.faa
done

echo "Sequence extraction complete."
echo ""
echo "IMPORTANT: Before proceeding to Step 3, append gene names"
echo "to the fasta headers of all extracted sequences."
echo "Example header format: >geneName__originalSequenceID"
