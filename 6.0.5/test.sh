#!/bin/bash

# Copyright © 2021-2026 Pittsburgh Supercomputing Center.
# All Rights Reserved.

set -uo pipefail

VERSION=6.0.5
PACKAGE=gnuplot
IMAGE=singularity-$PACKAGE-$VERSION.sif

FAILED=0

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1"; FAILED=$((FAILED + 1)); }

if ! command -v singularity > /dev/null 2>&1; then
	echo "singularity not found in PATH"
	exit 1
fi

if [ ! -f "$IMAGE" ]; then
	echo "$IMAGE not found. Run ./build.sh first."
	exit 1
fi

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

# Test 1: gnuplot runs and reports the expected version
OUTPUT=$(singularity exec "$IMAGE" gnuplot --version 2>&1)
if echo "$OUTPUT" | grep -q "gnuplot ${VERSION%.*} patchlevel ${VERSION##*.}"; then
	pass "version: $OUTPUT"
else
	fail "expected gnuplot $VERSION, got: $OUTPUT"
fi

# Test 2: help flag works
if singularity exec "$IMAGE" gnuplot -h > /dev/null 2>&1; then
	pass "gnuplot -h"
else
	fail "gnuplot -h"
fi

# Test 3: evaluate an expression
OUTPUT=$(singularity exec "$IMAGE" gnuplot -e 'print 2**10' 2>&1)
if [ "$OUTPUT" == "1024" ]; then
	pass "expression evaluation"
else
	fail "expected 1024, got: $OUTPUT"
fi

# Test 4: render a plot to a file with the dumb (ASCII) terminal
singularity exec -B "$WORKDIR" "$IMAGE" gnuplot -e \
	"set terminal dumb; set output '$WORKDIR/plot.txt'; plot sin(x)" > /dev/null 2>&1
if [ -s "$WORKDIR/plot.txt" ]; then
	pass "plot rendered to dumb terminal"
else
	fail "plot rendered to dumb terminal"
fi

# Test 5: plot data from a file
printf "1 1\n2 4\n3 9\n4 16\n" > "$WORKDIR/data.dat"
singularity exec -B "$WORKDIR" "$IMAGE" gnuplot -e \
	"set terminal dumb; set output '$WORKDIR/data.txt'; plot '$WORKDIR/data.dat' with linespoints" > /dev/null 2>&1
if [ -s "$WORKDIR/data.txt" ]; then
	pass "plot from data file"
else
	fail "plot from data file"
fi

# Test 6: an invalid command should fail
if singularity exec "$IMAGE" gnuplot -e 'this_is_not_a_command' > /dev/null 2>&1; then
	fail "invalid command did not return an error"
else
	pass "invalid command returns an error"
fi

if [ $FAILED -eq 0 ]; then
	echo "All tests passed."
	exit 0
else
	echo "$FAILED test(s) failed."
	exit 1
fi
