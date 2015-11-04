#!/bin/tcsh

##
## USAGE: chipseq-peakdiff.tcsh OUTPUT-DIR PARAMETER-SCRIPT X-FILES Y-FILES
##

# shell settings (must be included in all scripts)
source ./code/code.main/custom-tcshrc

# process command-line inputs
if ($#argv != 4) then
  grep '^##' $0
  exit
endif

set out = $1
set param_script = $2
set xfiles = ($3)
set yfiles = ($4)

# create matrix
set mat = $out/matrix.tsv
scripts-multi-paste $xfiles $yfiles >! $mat
set nref = $#xfiles

# set parameters
source $param_script
scripts-send2err "-- Parameters: "
scripts-send2err "- tool = $tool"
scripts-send2err "- diff params = $diff_params"
scripts-send2err "- annotation params = $annot_params"

# run easydiff
scripts-easydiff.r -v -o $out --nref=$nref $diff_params $mat

# merge overlapping diff-peaks
cat $out/diff.gain | sed 's/:/\t/' | sed 's/-/\t/' | scripts-sortbed | genomic_regions link --label-func max | cut -f-4 >! $out/diff.gain.bed
cat $out/diff.loss | sed 's/:/\t/' | sed 's/-/\t/' | scripts-sortbed | genomic_regions link --label-func min | cut -f-4 >! $out/diff.loss.bed

# annotate diff-peaks
( \
 echo "LOG-FOLD-CHANGE\tDIFF-PEAK-LOCUS\tREGION\tGENE-SYMBOL\tDISTANCE"; \
 cat $out/diff.gain.bed $out/diff.loss.bed | genomic_overlaps $annot_params | cut -f1-3,4,7 | sed 's/:[^:]\+|/\t/' | sort -u \
) >! $out/peakdiff.annotated.tsv
