#!/bin/bash
set -v
scons -uj8 target=steehl app=cam toolchain=msvc
scons -uj8 target=steehl app=cam toolchain=iar
# echo "Executing: scons target=steehl app=cam toolchain=armgcc mode=release"
# scons target=steehl app=cam toolchain=iar mode=release
