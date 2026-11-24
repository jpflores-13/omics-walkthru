#!/bin/bash
## Download a small practice RNA-seq dataset: the first N read pairs of four
## airway runs (GEO GSE52778; human airway smooth muscle, two donors,
## untreated vs dexamethasone), streamed from ENA. No SRA Toolkit needed.
##
## Usage:  bash practice-data/get_practice_data.sh [outdir] [read_pairs]
##         defaults: outdir = practice_data, read_pairs = 500000
##
## Writes  <outdir>/<donor>_<treatment>_R1_001.fastq.gz and _R2_001.fastq.gz
##         <outdir>/RNAsamplesheet.txt   (a bagPipes-style samplesheet)
## Needs   curl, gzip  (standard on macOS and Linux)

set -euo pipefail
OUT=${1:-practice_data}
N=${2:-500000}
LINES=$(( N * 4 ))
mkdir -p "$OUT"
ABS=$(cd "$OUT" && pwd)

ENA=https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR103
## run        donor    treatment
RUNS="SRR1039508 N61311 untrt
SRR1039509 N61311 dex
SRR1039512 N052611 untrt
SRR1039513 N052611 dex"

printf "Project\tCell_Type\tDonor\tTreatment\tBio_Rep\tRead1\tRead2\tSequencing_Directory\n" > "$OUT/RNAsamplesheet.txt"

echo "$RUNS" | while read -r run donor trt; do
  name=${donor}_${trt}
  sub=00${run: -1}                       # ENA folder: last digit of the run, zero-padded
  for r in 1 2; do
    f="$OUT/${name}_R${r}_001.fastq.gz"
    if [ -s "$f" ]; then echo "have $f"; continue; fi
    echo "fetching first $N reads of ${run}_${r} -> $f"
    ## stream, decompress, keep the first N reads, recompress; head stops the download early
    ( curl -sL "$ENA/$sub/$run/${run}_${r}.fastq.gz" | gzip -dc | head -n "$LINES" | gzip > "$f" ) || true
  done
  printf "airway\tASM\t%s\t%s\t1\t%s_R1_001.fastq.gz\t%s_R2_001.fastq.gz\t%s/\n" \
    "$donor" "$trt" "$name" "$name" "$ABS" >> "$OUT/RNAsamplesheet.txt"
done

echo
echo "Read counts:"
for f in "$OUT"/*.fastq.gz; do
  echo -e "  $(basename "$f")\t$(( $(gzip -dc "$f" | wc -l) / 4 ))"
done
echo "Samplesheet: $OUT/RNAsamplesheet.txt"
