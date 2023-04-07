#!/usr/bin/env bash
#echo "args number: $#"
#for arg in "$@"; do
#  echo "$arg"
#done

#someVal=${1:-null}
#if [[ $someVal == null ]]; then
#  echo "Looks like NULL!"
#else
#  echo "Well hello there $someVal!"
#fi


isDecompressing=
if [[ $1 == "-d" ]]; then
  isDecompressing=true
else
  isDecompressing=false
fi

inputFile=
outputFile=
if [[ $isDecompressing = true ]]; then
  inputFile=$2
  outputFile=$3
else
  inputFile=$1
  # While compressing, input may be written to file or to command line if no outputFile specified.
  outputFile=${2:-null}
fi


if [[ $isDecompressing = false ]]; then
  # If decompression flag is not specified we compress input file and encode to base64
  zippedInput="${inputFile}.gz"
  # When no options specified gzip reads stdin and spits result to stdout so we use redirection.
  # So we push inputFile to stdin and redirect output to zippedInput. This is done to preserve original inputFile.
  # Otherwise gzip would just remove it afterwards
  (gzip < "$inputFile" > "$zippedInput"
  if [[ $outputFile != null ]]; then
    base64 -i "$zippedInput" -o "$outputFile"
  else
    base64 -i "$zippedInput"
  fi) && rm "$zippedInput"
else
  if [[ $outputFile = null ]] || [[ $inputFile = null ]]; then
    echo "Both input and output files must be specified upon decompressing"
    exit 128
  fi

  archivedKey="keystore.gz"
  (base64 -d < "$inputFile" > $archivedKey
  gzip -d < "$archivedKey" > "$outputFile") && rm "$archivedKey"
fi
