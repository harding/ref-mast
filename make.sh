#!/bin/bash -eu

mkdir -p output
cd output

for f in ../graphviz/*.dot
do
  dot -Tpng -o $( basename $f ).png $f
done

gnuplot ../gnuplot/size.plot
