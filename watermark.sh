#!/bin/bash
set -euo pipefail

# the quality of the rasterization
QUALITY=200

if [ "$#" -ne 2 ]
then
  echo "usage: watermark.sh input.pdf watermark.pdf"
  exit 1
fi

filename=$(basename "$1")
extension=$([[ "$filename" = *.* ]] && echo ".${filename##*.}" || echo '')
filename="${filename%.*}"

outfile="${filename}_watermarked$extension"

tmpfile1=$(tempfile)

# first stamp
# https://superuser.com/questions/280659/how-can-i-apply-a-watermark-on-every-page-of-a-pdf-file   
pdftk "$1" stamp "$2" output "$tmpfile1"

# then rasterize (to prevent removal)
# https://superuser.com/questions/802569/how-to-distill-rasterize-a-pdf-in-linux
convert -limit memory 256MiB -limit map 256MiB -density $QUALITY +antialias "$tmpfile1" "$outfile"

# Faster
# https://unix.stackexchange.com/questions/198712/how-can-i-rasterize-all-of-the-text-in-a-pdf
# devices
# tiffg4 <-- grayscale
# tiff24nc <-- colour
# tiff12nc <-- colour
#gs -sDEVICE=tiff24nc -o "$tmpfile2" "$tmpfile1"
#tiff2pdf -z -f -F -pA4 -o "$tmpfile3" "$tmpfile2"

#gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dBATCH  -dQUIET -sOutputFile="$outfile" "$tmpfile1"

rm "$tmpfile1"

