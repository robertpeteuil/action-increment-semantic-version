#!/bin/bash -l

params="major minor patch alpha beta rc"
ver="1.2.3 1.2.3-alpha 1.2.3-alpha1 1.2.3-alpha.1 1.2.3-beta 1.2.3-beta1 1.2.3-beta.1 1.2.3-rc 1.2.3-rc1 1.2.3-rc.1"

for v in $ver; do
  for p in $params; do
    echo "--> $v, $p"
    ../entrypoint.sh $v $p
  done
  echo
done
