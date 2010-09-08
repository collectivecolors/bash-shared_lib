#!/bin/bash
#-------------------------------------------------------------------------------
#
# init.sh
#
#-------------------------------------------------------------------------------
# Properties


HELP="
The init.sh command initializes shared library scripts for use by other scripts.

WARNING: This script has only been tested with 10.04 LTS.

--------------------------------------------------------------------------------

 Developed by Adrian Webb of http://collectivecolors.com
 Licensed under GPL v2

 See the project page at:  http://github.com/collectivecolors/bash-shared_lib
 Report issues here:       http://github.com/collectivecolors/bash-shared_lib/issues
 
--------------------------------------------------------------------------------
"

USAGE="
usage: init.sh [ -h | --help ]                  # Show usage information
               -----------------------------------------------------------------
               [ -f | --force ]                 # Force overwrite of existing script library destination.
"


#-------------------------------------------------------------------------------
# Variables


# Command directory.  Can't use get_command_location() yet, as it's not loaded.
CMD_NAME=`basename $0`
INIT_DIR=`which $CMD_NAME`

if [ ! "$INIT_DIR" ]
then
    CMD_NAME=`readlink -f $0`

    cd `dirname $CMD_NAME`
    INIT_DIR=`pwd`

else
    INIT_DIR=`readlink -f $INIT_DIR`
    INIT_DIR=`dirname $INIT_DIR`
fi

# Configuration and utility scripts.
source "$INIT_DIR/common_utils.pub.sh" || exit 1

# echo "$COMMON_DIR"
# echo "$SHARED_LIB_DIR"
# echo "$SHARED_LIB_BIN"
# echo "$SCRIPT_EXT"
# echo "$PUBLIC_EXT"


#-------------------------------------------------------------------------------
# Parameters


# Default parameters.
PARAMS=`normalize_params "$@"`
HELP_WANTED=''
FORCE_WANTED=''

# Parse any options and flags.
parse_flag '-h|--help' HELP_WANTED
parse_flag '-f|--force' FORCE_WANTED

# Reassign parameters.
set -- $PARAMS

# Standard help message.
if [ "$HELP_WANTED" ]
then
    echo "$HELP"
    echo "$USAGE"
    exit 0	
fi 


#-------------------------------------------------------------------------------
# Start

echo "Initializing shared library."
transfer_directory "$INIT_DIR" "$SHARED_PROJ_DIR" || exit $((1 + $?))
init_script_package --sudo "$FORCE_WANTED" "$INIT_DIR" "$SHARED_LIB_DIR" || exit $((4 + $?))

echo "Successfully initialized shared library."
