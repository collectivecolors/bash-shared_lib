#!/bin/bash
#
# common_properties
#

#-------------------------------------------------------------------------------
# Shared properties


PROJ_DIR="$HOME/dl"
SCRIPT_PROJ_DIR="$PROJ_DIR/scripts"

if [ ! -d "$SCRIPT_PROJ_DIR" ]
then
	mkdir -p "$SCRIPT_PROJ_DIR"
fi

COMMON_LIB_DIR="$HOME/lib"

if [ ! -d "$COMMON_LIB_DIR" ]
then
    mkdir -p "$COMMON_LIB_DIR"
fi

COMMON_BIN_DIR="$HOME/bin"

if [ ! -d "$COMMON_BIN_DIR" ]
then
    mkdir -p "$COMMON_BIN_DIR"
fi


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
