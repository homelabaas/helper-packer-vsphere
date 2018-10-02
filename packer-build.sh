#!/bin/bash

# Will replace $VARIABLE in the file with environment variable settings
expandVars() {
  local txtToEval=$* txtToEvalEscaped
  (( $# == 0 )) && IFS= read -r -d '' txtToEval
  IFS= read -r -d '' txtToEvalEscaped < <(printf %s "$txtToEval" | tr '`([' '\1\2\3')
  eval printf %s "\"${txtToEvalEscaped//\"/\\\"}\"" | tr '\1\2\3' '`(['
}

# Sync all files into /root folder from $BUCKET/$BUILDFOLDER/
/bin/sync-minio.sh

echo ''

if test -n "$(find /root -maxdepth 1 -name '*.template' -print)"
then
  for filename in /root/*.template; do
    newfilename="${filename%.*}"
    cat $filename | expandVars > $newfilename
    echo "Expanding variables from $filename to $newfilename"
  done
fi

echo "/bin/packer -machine-readable build /root/$PACKERJSONFILE"

/bin/packer -machine-readable build /root/$PACKERJSONFILE
