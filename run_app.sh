#!/bin/sh
SCRIPT="$0"
# Resolve the chain of symlinks leading to this script
while [ -L "$SCRIPT" ] ; do
    LINK=$(readlink "$SCRIPT")
    case "$LINK" in
        /*) SCRIPT="$LINK" ;;
        *) SCRIPT="$(dirname "$SCRIPT")/$LINK" ;;
    esac
done
# The directory containing this shell script - an absolute path
ROOT=$(cd "$(dirname "$SCRIPT")"; pwd)
# Install all required R packages and start the app
Rscript --vanilla "$ROOT/R/install_packages.R"
Rscript --vanilla "$ROOT/R/app.R" "$ROOT"
