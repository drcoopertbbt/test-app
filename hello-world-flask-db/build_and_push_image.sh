#!/usr/bin/env bash

IMAGE=quay.io/repository/marzquay/todo-list

podman build -t ${IMAGE} .

podman push ${IMAGE}