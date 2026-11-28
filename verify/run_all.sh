#!/bin/bash
# Runs every R chunk (including eval = FALSE ones) of each tutorial with the real packages.
mkdir -p verify/out
status=0
for f in clt estimation_sampling hypothesis_testing ppa autocorrelation regression continuous_surfaces describing_data tmap describing_spatial_data probability; do
  python3 verify/extract.py $f.qmd verify/out/$f.R
  Rscript -e "pdf('verify/out/$f.pdf', width = 9, height = 6); source('verify/out/$f.R', echo = FALSE, print.eval = TRUE); dev.off()" > verify/out/$f.log 2>&1
  code=$?; echo "$f exit $code"; grep -i -B2 -A3 "warn|deprecat|\[v3|\[tm_|\[plot mode]|\[view mode]" verify/out/$f.log | head -60; [ $code -ne 0 ] && { status=1; tail -20 verify/out/$f.log; }
done
exit $status
