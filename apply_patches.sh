#!/bin/bash

pushd v8
git apply --ignore-space-change --ignore-whitespace --cached ../v8.patch
git checkout -- .

popd
