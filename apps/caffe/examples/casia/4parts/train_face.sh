#!/usr/bin/env sh

pdsh -R ssh -w ^examples/imagenet/4parts/machinefile "pkill caffe_geeps"

LOG=output.txt
OUTDIR=

if [ "$#" -eq 1 ]; then
  mkdir $1
  pwd > $1/pwd
  git status > $1/git-status
  git diff > $1/git-diff
  SED_STR='s#snapshot_prefix: "[a-zA-Z0-9/_.]*"#snapshot_prefix: "'"${1}"'/face_snapshot"#g'
  sed -i ''"${SED_STR}"'' ./examples/casia/4parts/face_solver.prototxt.template 
  cp examples/casia/4parts/train_face.sh $1/.
  cp examples/casia/4parts/face_train_test.prototxt.template $1/.
  cp examples/casia/4parts/face_solver.prototxt.template $1/.
  cp examples/casia/4parts/machinefile $1/.
  cp examples/casia/4parts/ps_config_face $1/.
  LOG=$1/output.txt
  OUTDIR=$1
fi

rm ${LOG}

python scripts/duplicate.py examples/casia/4parts/face_train_test.prototxt 4
python scripts/duplicate.py examples/casia/4parts/face_solver.prototxt 4

pdsh -R ssh -w ^examples/casia/4parts/machinefile "cd $(pwd) && ./build/tools/caffe_geeps train --solver=examples/casia/4parts/face_solver.prototxt --ps_config=examples/casia/4parts/ps_config_face --machinefile=examples/casia/4parts/machinefile --worker_id=%n --outdir=${OUTDIR}" 2>&1 | tee ${LOG}

