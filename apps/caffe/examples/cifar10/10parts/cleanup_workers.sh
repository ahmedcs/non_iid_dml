#!/usr/bin/env sh

pdsh -R ssh -w ^examples/cifar10/10parts/machinefile "pkill caffe_geeps"
