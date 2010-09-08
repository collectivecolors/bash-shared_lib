#!/bin/bash
#
# common_utils
#
# WARNING:  This script should be placed in /usr/local/bin and made executable.
#           >>> IT IS USED BY OTHER SCRIPTS WHO EXPECT IT TO BE AT A SEARCHABLE LOCATION <<<
#


#-------------------------------------------------------------------------------
# Shared functions


#-------------------------------------------------------------------------------
# Get the directory of the command passed via the first parameter.
#
# USAGE:> SCRIPT_DIR=`get_command_location $0`
#
function get_command_location()
{
    local CMD_NAME=`basename $1`
    local SCRIPT_DIR=`which $CMD_NAME`

    if [ ! "$SCRIPT_DIR" ]
    then
        CMD_NAME=`readlink -f $1`

        cd `dirname $CMD_NAME`
        SCRIPT_DIR=`pwd`

    else
        SCRIPT_DIR=`readlink -f $SCRIPT_DIR`
        SCRIPT_DIR=`dirname $SCRIPT_DIR`
    fi
    
    # Return the final directory found. 
    echo "$SCRIPT_DIR"
    return 0
}
 

#-------------------------------------------------------------------------------
# Initialization


# Load common properties
if [ `which common_properties` ]
then
	echo "Common properties found."
	source common_properties
	COMMON_DIR="$SHARED_LIB_DIR"
else
    echo "Common properties not found.  Using package defaults."
    COMMON_DIR=`get_command_location $0`
    source "$COMMON_DIR/common_properties.pub.sh"
fi


#-------------------------------------------------------------------------------


# Load command utilities.  This should always be loaded first.
COMMON_COMMAND="$COMMON_DIR/command.sh"

if [ -f "$COMMON_COMMAND" ]
then
	echo "Command utilities found: $COMMON_COMMAND."
    source "$COMMON_COMMAND"
fi

# Load file system utilities.
COMMON_FILESYSTEM="$COMMON_DIR/filesystem.sh"

if [ -f "$COMMON_FILESYSTEM" ]
then
	echo "Filesystem utilities found: $COMMON_FILESYSTEM."
    source "$COMMON_FILESYSTEM"
fi

# Load script utilities.
COMMON_SCRIPT="$COMMON_DIR/script.sh"

if [ -f "$COMMON_SCRIPT" ]
then
	echo "Script utilities found: $COMMON_SCRIPT."
    source "$COMMON_SCRIPT"
fi


#-------------------------------------------------------------------------------


# Load any validators used in parse_option() calls.
COMMON_VALIDATORS="$COMMON_DIR/validators.sh"

if [ -f "$COMMON_VALIDATORS" ]
then
	echo "Validators found: $COMMON_VALIDATORS."
    source "$COMMON_VALIDATORS"
fi
