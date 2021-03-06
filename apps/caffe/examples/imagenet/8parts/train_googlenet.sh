#!/usr/bin/env sh

pdsh -R ssh -w ^examples/imagenet/8parts/machinefile "pkill caffe_geeps"

LOG=output.txt
OUTDIR=

if [ "$#" -eq 1 ]; then
  mkdir $1
  pwd > $1/pwd
  git status > $1/git-status
  git diff > $1/git-diff
  SED_STR='s#snapshot_prefix: "[a-zA-Z0-9/_.]*"#snapshot_prefix: "'"${1}"'/googlenet_snapshot"#g'
  sed -i ''"${SED_STR}"'' ./examples/imagenet/8parts/googlenet_solver.prototxt.template 
  cp examples/imagenet/8parts/train_googlenet.sh $1/.
  cp examples/imagenet/8parts/googlenet_train_val.prototxt.template $1/.
  cp examples/imagenet/8parts/googlenet_solver.prototxt.template $1/.
  cp examples/imagenet/8parts/machinefile $1/.
  cp examples/imagenet/8parts/ps_config_googlenet $1/.
  LOG=$1/output.txt
  OUTDIR=$1
fi

python scripts/duplicate.py examples/imagenet/8parts/googlenet_train_val.prototxt 8
python scripts/duplicate.py examples/imagenet/8parts/googlenet_solver.prototxt 8

pdsh -R ssh -w ^examples/imagenet/8parts/machinefile "cd $(pwd) && ./build/tools/caffe_geeps train --solver=examples/imagenet/8parts/googlenet_solver.prototxt --ps_config=examples/imagenet/8parts/ps_config_googlenet --machinefile=examples/imagenet/8parts/machinefile --worker_id=%n --outdir=${OUTDIR}" 2>&1 | tee ${LOG}

