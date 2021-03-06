#!/bin/tcsh
source ./code/code.main/custom-tcshrc     # shell settings

##
## USAGE: run-compare-boundaries.tcsh [--dry-run]
##

#% This step performs pair-wise comparison of domain boundaries in pairs of samples.
#% TABLES: 
#% FIGURES:

if ($#argv > 1) then
  grep '^##' $0 | scripts-send2err
  exit
endif

set opt = "$1"

# setup
set op = compare-boundaries
set inpdirs = "inpdirs/*"
set filter = "*.res_40kb"                  # work only with 40kb resolution
set results = results
scripts-create-path $results/
scripts-send2err "=== Operation = $op ============="
set resources = 1
set cmd = "./code/code.main/scripts-qsub-wrapper $resources ./code/hicseq-$op.tcsh"

# generate run script
Rscript ./code/code.main/pipeline-master-explorer.r -v -F "$filter" "$cmd" $results/$op "params/params.*.tcsh" "$inpdirs" "genome" "sample" 2

# run and wait until done!
if ("$opt" != "--dry-run") scripts-submit-jobs ./$results/.db/run



