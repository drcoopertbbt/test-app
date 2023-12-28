#!/usr/bin/env bash

IMAGE=quay.io/marzquay/todo-list:latest

podman build -t ${IMAGE} .

podman push ${IMAGE}