#!/usr/bin/gnuplot

## Reset linetypes
set for [i=1:5] linetype i dt i

## Some line colors from Gnuplotting website
set style line 1 lt 1 lc rgb '#0072bd' lw 2 # blue
set style line 2 lt 1 lc rgb '#d95319' lw 2 # orange
set style line 3 lt 1 lc rgb '#edb120' lw 2 # yellow
set style line 4 lt 1 lc rgb '#7e2f8e' lw 2 # purple
set style line 5 lt 1 lc rgb '#77ac30' lw 2 # green
set style line 6 lt 1 lc rgb '#4dbeee' lw 2 # light-blue
set style line 7 lt 1 lc rgb '#a2142f' lw 2 # red

## For dashed lines
set style line 15 lc rgb '#77ac30' lw 2 lt 2 # green
set style line 16 lc rgb '#4dbeee' lw 2 lt 2 # light-blue

## For two subscripts, the script is 115 bytes:
## OP_IF OP_PUSH33 <a_pubkey> OP_CHECKSIG
## OP_ELSE <4 bytes> OP_CSV OP_DROP OP_2 OP_PUSH33 <b_pubkey> OP_PUSH33
##    <c_pubkey> OP_2 OP_CHECKMULTISIG OP_ENDIF
raw_base_bytes = 115

## For each additional subscript, the additional data is 79 bytes:
## OP_IF <4 bytes> OP_CSV OP_DROP OP_2 OP_PUSH33 <d_pubkey>
## OP_PUSH33 <e_pubkey> OP_2 OP_CHECKMULTISIG OP_ENDIF
raw_additional_bytes = 79

## First two subscripts are already counted.
raw_size(subscripts) = raw_base_bytes + raw_additional_bytes * (subscripts - 2)

## For a more-than-fair comparison between non-MAST and MAST, we'll use the larger of the two
## branches, the one with two pubkeys and the CSV timestamp, a total of 77 bytes
## <4 bytes> OP_CSV OP_DROP OP_2 OP_PUSH33 <d_pubkey>
## OP_PUSH33 <e_pubkey> OP_2 OP_CHECKMULTISIG
#
## At a minimum, we need to provide the merkle root, 33 bytes
## including a push. Let's assume Maaku's scheme, so 1 byte for MBV and 
## maybe some extra bytes to circumvent the cleanstack rule, which we'll call 4 bytes
used_encumbrance_bytes = 77 + 33 + 1 + 4

## To use a merkle branch, we need 32 bytes per hash plus a one-bit flag
## to indicate right or left branch
mast_size(subscripts) = used_encumbrance_bytes + ceil(log(subscripts)) * 32.125


############################################
## FIRST PLOT: linear bytesize/subscripts ##
############################################
set terminal pngcairo size 800,300 font "Sans,12"
set output "encumbrance-data1.png"

set xlabel "Number of sub-scripts"
set ylabel "Spending script size (bytes)"
unset key
set grid
set yrange [90:17000]

set label 1 "Without MAST" at 60,5700 rotate by 12 tc ls 1
set label 2 "With MAST" at 60,1000 tc ls 2

plot [2:150] raw_size(x) ls 1, mast_size(x) ls 2

unset label 1 ; unset label 2

##########################################
## SECOND PLOT: log bytesize/subscripts ##
##########################################
set terminal pngcairo size 800,300 font "Sans,12"
set output "encumbrance-data2.png"

set label 1 "Without MAST" at 22,4700 tc ls 1
set label 2 "With MAST" at 22,350 tc ls 2

set ylabel "Byte size (log scale)"
set logscale y
replot

##############################################################
## THIRD PLOT: log bytesize/subscripts for unbalanced trees ##
##############################################################
set terminal pngcairo size 800,300 font "Sans,12"
set output "encumbrance-data3.png"

set label 3 "Best case (always \\~100 bytes)" at 22,135 tc ls 3
set label 4 "Worst case" at 80,400 tc ls 4

## Alice spend is always at depth=1, so subscripts always equivilent to 2.
## Also, we assumed CSV&&Bob+Charlie spend when calculating byte sizes,
## so subtract diff in bytes
#
## Other spends are always one level deeper, so subscripts equivilent to 2x
plot [2:150] raw_size(x) ls 1 \
  , mast_size(x) ls 2 \
  , mast_size(2)-46 ls 3 \
  , mast_size(2*x) ls 4

unset label 3 ; unset label 4

######################################################################
## FOURTH PLOT: log bytesize/subscripts with P2SH and segwit limits ##
######################################################################
set terminal pngcairo size 800,300 font "Sans,12"
set output "encumbrance-data4.png"

set arrow 1 from 2,10000 to 150,10000 nohead ls 15
set arrow 2 from 2,520 to 150,520 nohead ls 16

set label "Bare \\& Segwit Limit" at 22,13000 tc ls 15
set label "P2SH Limit" at 22,700 tc ls 16

plot [2:150] raw_size(x) ls 1, mast_size(x) ls 2
