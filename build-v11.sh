#!/usr/bin/env bash

set -euo pipefail

BASE_IMAGE="${BASE_IMAGE:-docker-mirror.sh.synyi.com/openeuler/openeuler:24.03-lts-sp2}"

for arch in amd64 arm64; do
  docker buildx build \
    --progress=plain \
    --platform="linux/${arch}" \
    --load \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    -f kylin_v11.sys.Dockerfile \
    -t "kylin:v11-sp3-${arch}" \
    .
done
