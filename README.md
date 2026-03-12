# Hydrocarbon Degradation DIAMOND Database

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A custom DIAMOND protein database for detecting aerobic and anaerobic hydrocarbon degradation genes in metagenomic and metatranscriptomic datasets. This pipeline was developed for genome-resolved analysis of hydrocarbon degradation potential in the Chesapeake and Delaware Bays.

---

## Overview

This pipeline constructs a curated, non-redundant protein reference database by:
1. Searching the **CANT-HYD HMM database** (37 key hydrocarbon degradation genes) against NCBI-nr and GTDB
2. Extracting matching sequences using **seqtk**
3. Dereplicating sequences using **CD-HIT** at 95% identity
4. Compiling the final database using **DIAMOND makedb**

The resulting database contains **9,448 unique protein sequences** representing 37 genes associated with aerobic and anaerobic degradation of aliphatic and aromatic hydrocarbons.

---

## Pipeline Overview

```
CANT-HYD HMMs (37 genes)
        │
        ▼
   hmmsearch (trusted cutoffs)
        │
   ┌────┴────┐
   ▼         ▼
NCBI-nr    GTDB-Tk
   │         │
   └────┬────┘
        ▼
  seqtk subseq
  (extract hit sequences)
        │
        ▼
  Add gene names to headers
        │
        ▼
  Concatenate all sequences
        │
        ▼
  CD-HIT v4.8.1 (95% identity)
        │
        ▼
  diamond makedb
        │
        ▼
  Custom DIAMOND database
  (9,448 unique sequences)
        │
   ┌────┴────┐
   ▼         ▼
blastp      blastx
(Metagenome (Metatranscriptome
   ORFs)       reads)
```

---

## Dependencies

| Tool | Version | Purpose |
|------|---------|---------|
| [HMMER](http://hmmer.org/) | 3.x | HMM search against protein databases |
| [seqtk](https://github.com/lh3/seqtk) | 1.3-r106 | Sequence extraction |
| [CD-HIT](https://sites.google.com/view/cd-hit) | 4.8.1 | Sequence dereplication |
| [DIAMOND](https://github.com/bbuchfink/diamond) | 2.0.14 | Database creation and sequence search |
| [Prodigal](https://github.com/hyattpd/Prodigal) | 2.x | ORF prediction (metagenome) |
| [BBMap](https://sourceforge.net/projects/bbmap/) | - | Contig length filtering |

---

## Database Sources

| Database | Description | Reference |
|----------|-------------|-----------|
| [CANT-HYD](https://github.com/dgittins/CANT-HYD-HydrocarbonBiodegradation) | 37 HMMs for hydrocarbon degradation genes | Khot et al., 2022 |
| [NCBI-nr](https://www.ncbi.nlm.nih.gov/) | Non-redundant protein database | NCBI |
| [GTDB-Tk](https://gtdb.ecogenomic.org/) | Genome Taxonomy Database | Parks et al., 2022 |

---

## Step-by-Step Usage

### Step 1: HMM Search Against NCBI-nr and GTDB

Search the CANT-HYD HMMs against both databases using trusted cutoff scores:

```bash
bash scripts/01_hmm_search.sh
```

This produces hit list `.txt` files for each of the 37 genes from both databases.

---

### Step 2: Extract Sequences Using seqtk

Extract the actual fasta sequences corresponding to the HMM hits:

```bash
bash scripts/02_extract_sequences.sh
```

> **Important:** After extraction, manually append gene names to the fasta headers of all retrieved sequences before proceeding. This is critical for downstream functional annotation.

Example header format:
```
>geneName__originalSequenceID
```

---

### Step 3: Concatenate and Dereplicate with CD-HIT

Concatenate all extracted sequences and dereplicate at 95% identity:

```bash
bash scripts/03_cdhit_derep.sh
```

Expected output: **9,448 unique non-redundant protein sequences**

---

### Step 4: Build DIAMOND Database

Compile the dereplicated sequences into a DIAMOND-formatted database:

```bash
bash scripts/04_build_diamond_db.sh
```

---

### Step 5a: Screen Metagenomic ORFs (blastp)

Filter contigs to ≥500 bp, predict ORFs with Prodigal, and search using diamond blastp:

```bash
bash scripts/05a_screen_metagenome.sh
```

Parameters:
- Minimum percent identity: **70%**
- Query coverage: **70%**
- Top hit only: **-k 1**

---

### Step 5b: Screen Metatranscriptomic Reads (blastx)

Search quality-trimmed reads directly against the database using diamond blastx:

```bash
bash scripts/05b_screen_metatranscriptome.sh
```

Parameters:
- E-value threshold: **1e-5**
- Top hit only: **--max-target-seqs 1**

---

## Output Format

DIAMOND output files are in tabular format (`.tsv`) with the following fields:
```
qseqid  sseqid  pident  length  mismatch  gapopen  qstart  qend  sstart  send  evalue  bitscore
```

---

## Citation

If you use this database or pipeline, please cite:

- **This study:** Jayasuriya et al. (in preparation). Genome-resolved hydrocarbon degradation potential in the Chesapeake and Delaware Bays.
- **CANT-HYD:** Khot, V., et al. (2022). CANT-HYD: A Curated Database of Phylogeny-Derived HMMs for Annotation of Marker Genes Involved in Hydrocarbon Degradation. *Frontiers in Microbiology*, 12, 764058. https://doi.org/10.3389/fmicb.2021.764058
- **DIAMOND:** Buchfink, B., Xie, C., & Huson, D. H. (2015). Fast and sensitive protein alignment using DIAMOND. *Nature Methods*, 12(1), 59–60.
- **CD-HIT:** Fu, L., et al. (2012). CD-HIT: accelerated for clustering the next-generation sequencing data. *Bioinformatics*, 28(23), 3150–3152.

---

## Contact

**Dinu Jayasuriya**
Campbell Lab, Clemson University
djayasu@g.clemson.edu
