#!/bin/tcsh
source ./code/code.main/custom-tcshrc      # customize shell environment

##
## USAGE: run-matrix-estimated.tcsh [--dry-run]
##

#% This step uses fused lasso to estimate Hi-C contact matrices.
#% TABLES: 
#% FIGURES: 

# process command-line inputs
if ($#argv > 1) then
  grep '^##' $0 | scripts-send2err
  exit
endif

set opt = "$1"

# setup
set op = matrix-estimated
set inpdirs = "inpdirs/*"
set results = results
scripts-create-path $results/
scripts-send2err "=== Operation = $op ============="
set resources = 1
set cmd = "./code/code.main/scripts-qsub-wrapper $resources ./code/hicseq-$op.tcsh"

# generate run script
Rscript ./code/code.main/pipeline-master-explorer.r -v --exclude-branch='/matrix-filtered.[^/]+rotate45' --exclude-outdir="fused2d.*res_10kb" "$cmd" $results/$op "params/params.*.tcsh" "$inpdirs" "" "sample" 1

# run and wait until done!
set max_jobs = 5
if ("$opt" != "--dry-run") scripts-submit-jobs ./$results/.db/run $max_jobs



