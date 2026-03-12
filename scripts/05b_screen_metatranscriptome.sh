#!/bin/bash
#SBATCH --job-name diamond_blastx_metatranscriptome
#SBATCH --nodes 1
#SBATCH --tasks-per-node 1
#SBATCH --cpus-per-task 40
#SBATCH --mem 370gb
#SBATCH --time 70:00:00

# ============================================================
# Step 5b: Screen Metatranscriptomic Reads (diamond blastx)
# Description: Search quality-trimmed metatranscriptomic reads
#              directly against the custom DIAMOND database
#              using blastx (nucleotide vs protein)
# Parameters:  --evalue 1e-5
#              --max-target-seqs 1 (top hit only)
# ============================================================

# ---- USER-DEFINED PATHS (edit before running) ----
MT_READS_DIR="/path/to/MT_trimmed_reads"                      # Quality-trimmed metatranscriptomic reads (.fq)
DIAMOND_DB="/path/to/curated_all_PAH_keygens.dmnd"            # Custom DIAMOND database
OUTPUT_DIR="/path/to/output/dmnd_metatranscriptome"           # Output directory
# --------------------------------------------------

module add diamond/2.0.14

mkdir -p $OUTPUT_DIR

# Screen metatranscriptomic reads using diamond blastx
echo "Running DIAMOND blastx on metatranscriptomic reads..."
for i in `ls $MT_READS_DIR/*.fq | awk -F "/" '{print $NF}' | sed "s/.fq//g"`
do
    diamond blastx \
        -q $MT_READS_DIR/${i}.fq \
        -d $DIAMOND_DB \
        -o $OUTPUT_DIR/dmnd_MT.${i}.tsv \
        --evalue 1e-5 \
        --max-target-seqs 1 \
        --threads 40
done

echo "Metatranscriptomic screening complete."
echo "Results written to: $OUTPUT_DIR"
