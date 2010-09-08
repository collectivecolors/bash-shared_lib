#!/bin/bash
#
# common_properties
#
# WARNING:  This script should be placed in /usr/local/bin and made executable.
#           >>> IT IS USED BY OTHER SCRIPTS WHO EXPECT IT TO BE AT A SEARCHABLE LOCATION <<<
#


#-------------------------------------------------------------------------------
# Shared properties


GITHUB_ACCT='collectivecolors'

PROJ_DIR="$HOME/Projects"
SCRIPT_PROJ_DIR="$PROJ_DIR/scripts"


COMMON_LIB_DIR=/usr/local/lib
COMMON_BIN_DIR=/usr/local/bin

SHARED_LIB_NAME="shared-lib"
SHARED_LIB_DIR="$COMMON_LIB_DIR/$SHARED_LIB_NAME"
SHARED_LIB_BIN="$COMMON_BIN_DIR"

SHARED_PROJ_DIR="$SCRIPT_PROJ_DIR/$SHARED_LIB_NAME"

SCRIPT_EXT="sh"
PUBLIC_EXT="pub.$SCRIPT_EXT"


if [[ "$PATH" != "\*$COMMON_BIN_DIR\*" ]]
then
    export PATH="$PATH:$COMMON_BIN_DIR"  # Make sure user common bin directory is searchable.
fi
