#!/bin/bash
## Download GENCODE human references and build the Salmon and HISAT2 indexes
## used in the RNA-seq module.
##
## Usage:  bash practice-data/get_references.sh [outdir] [full|chr22] [threads]
##   full  : whole genome + all transcripts (what a real analysis uses).
##           Needs ~16 GB RAM, ~30 GB disk, and 1-3 hours.
##   chr22 : chromosome 22 only (a laptop-friendly toy). Minutes, ~4 GB RAM.
##           Only ~2-3 % of reads come from chr22, so mapping rates will be low:
##           that is expected, not an error.
##
## Needs the rnaseq-tools conda environment (salmon, hisat2, seqkit, curl, pigz):
##   conda activate rnaseq-tools

set -euo pipefail
OUT=${1:-references}
MODE=${2:-full}
T=${3:-4}
REL=49
B=https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_${REL}
GTF=gencode.v${REL}.primary_assembly.annotation.gtf
TX=gencode.v${REL}.transcripts.fa
GENOME=GRCh38.primary_assembly.genome.fa

mkdir -p "$OUT" && cd "$OUT"

## 1. Download (skips files already present)
for f in $GTF.gz $TX.gz $GENOME.gz; do
  [ -s "$f" ] || { echo "downloading $f"; curl -L -C - -o "$f" "$B/$f"; }
done

if [ "$MODE" = "chr22" ]; then
  echo "== chr22 mode"
  gzip -dc $GTF.gz | awk '$1 == "chr22" || /^#/' > chr22.gtf
  ## transcript IDs on chr22, then the matching transcript sequences
  grep -o 'transcript_id "[^"]*"' chr22.gtf | cut -d'"' -f2 | sort -u > chr22_tx_ids.txt
  seqkit grep --id-regexp '^([^|]+)\|' -f chr22_tx_ids.txt $TX.gz -o chr22_transcripts.fa.gz
  seqkit grep -p chr22 $GENOME.gz -o chr22.fa
  GTF_USE=chr22.gtf; TX_USE=chr22_transcripts.fa.gz; GENOME_USE=chr22.fa
else
  echo "== full mode"
  [ -s $GTF ] || gzip -dc $GTF.gz > $GTF
  [ -s $GENOME ] || gzip -dc $GENOME.gz > $GENOME
  GTF_USE=$GTF; TX_USE=$TX.gz; GENOME_USE=$GENOME
fi

## 2. Salmon index. --gencode trims GENCODE's "ENST...|ENSG...|..." headers to the
##    transcript ID, so names match the GTF's transcript_id (needed by tximport).
[ -d salmon_index_$MODE ] || salmon index -t $TX_USE -i salmon_index_$MODE --gencode -p $T

## 3. HISAT2 index (the prefix is hisat2_index_<mode>/genome)
mkdir -p hisat2_index_$MODE
[ -s hisat2_index_$MODE/genome.1.ht2 ] || hisat2-build -p $T $GENOME_USE hisat2_index_$MODE/genome

## 4. Report the paths to use
cat <<MSG

Done. Paths for config/RNAconfig.yaml (or for the hands-on commands):
  salmon: '$PWD/salmon_index_$MODE'
  hisat2: '$PWD/hisat2_index_$MODE/genome'
  gtf:    '$PWD/$GTF_USE'
MSG
