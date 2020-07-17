#!/bin/bash

echo "Executing: scons target=steehl app=cam toolchain=msvc"
scons target=steehl app=cam toolchain=msvc
echo "Executing: scons target=steehl app=cam toolchain=iar"
scons target=steehl app=cam toolchain=iar
echo "Executing: scons target=steehl app=cam toolchain=armgcc mode=release"
scons target=steehl app=cam toolchain=iar mode=release
