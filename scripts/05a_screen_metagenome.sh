#!/bin/bash
#PBS -N diamond_blastp_metagenome
#PBS -l select=1:ncpus=24:mem=125gb:interconnect=fdr,walltime=24:00:00
#PBS -m abe
#PBS -M djayasu@g.clemson.edu
#PBS -k oe

# ============================================================
# Step 5a: Screen Metagenomic ORFs (diamond blastp)
# Description: Filter contigs to >=500 bp, predict ORFs using
#              Prodigal, then search predicted protein sequences
#              against the custom DIAMOND database using blastp
# Parameters:  --id 70 (percent identity)
#              --query-cover 70 (query coverage)
#              -k 1 (top hit only)
# ============================================================

# ---- USER-DEFINED PATHS (edit before running) ----
ASSEMBLY_DIR="/path/to/assemblies"                             # Raw assembly .fa files
FILTERED_DIR="/path/to/filtered_500bp"                        # Output for filtered contigs
ORF_DIR="/path/to/orf_predictions"                            # Output for Prodigal ORFs
DIAMOND_DB="/path/to/curated_all_PAH_keygens.dmnd"            # Custom DIAMOND database
OUTPUT_DIR="/path/to/output/dmnd_metagenome"                  # Output directory
# --------------------------------------------------

module add bbmap
module add prodigal
module add diamond/2.0.14

mkdir -p $FILTERED_DIR $ORF_DIR $OUTPUT_DIR

# Step 5a-1: Filter contigs to minimum 500 bp
echo "Filtering contigs to >=500 bp..."
for i in `ls $ASSEMBLY_DIR/*.fa | awk -F "/" '{print $NF}' | sed "s/.fa//g"`
do
    reformat.sh \
        in=$ASSEMBLY_DIR/${i}.fa \
        out=$FILTERED_DIR/500_${i}.fa \
        minlength=500
done

# Step 5a-2: Predict ORFs using Prodigal in metagenomic mode
echo "Predicting ORFs with Prodigal..."
for i in `ls $FILTERED_DIR/*.fa | awk -F "/" '{print $NF}' | sed "s/.fa//g"`
do
    prodigal \
        -i $FILTERED_DIR/${i}.fa \
        -o $ORF_DIR/${i}.genes \
        -a $ORF_DIR/${i}.orf.faa \
        -p meta
done

# Step 5a-3: Screen ORFs against custom DIAMOND database
echo "Running DIAMOND blastp..."
for i in `ls $ORF_DIR/*.faa | awk -F "/" '{print $NF}' | sed "s/.faa//g"`
do
    diamond blastp \
        -q $ORF_DIR/${i}.faa \
        -d $DIAMOND_DB \
        -p 24 \
        --id 70 \
        --query-cover 70 \
        -k 1 \
        -o $OUTPUT_DIR/dmnd_metagenome.${i}.tsv
done

echo "Metagenomic screening complete."
echo "Results written to: $OUTPUT_DIR"
