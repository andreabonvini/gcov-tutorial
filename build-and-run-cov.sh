#!/bin/bash

# Rationale: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

# Set up defaults for CC, CXX, GCOV_PATH
export CC="${CC:-gcc}"
export CXX="${CXX:-g++}"
export GCOV="${GCOV:-gcov}"

# Record the base directory
BASE_DIR=$PWD

# Clean up old build
rm -rf build

# Configure
cmake --preset gcc-coverage

# Build
cmake --build --preset gcc-coverage

# Enter build directory
cd build

# Clean-up counters for any previous run.
lcov --zerocounters --directory .

# Run tests
./tests/RunTests

echo "GCOV: $GCOV"
# Create coverage report by taking into account only the files contained in src/
lcov --capture --directory tests/ -o coverage.info --include "$BASE_DIR/src/*" --gcov-tool "$GCOV"

# Create HTML report in the out/ directory
genhtml coverage.info --output-directory out

# Show coverage report to the terminal
lcov --list coverage.info

# Open HTML
open out/index.html