#!/bin/bash
#
# validators.sh
#

#-------------------------------------------------------------------------------
# Shared functions


#-------------------------------------------------------------------------------
# Validate a string. (Must be non empty.)
#
# USAGE:> validate_string $STR
#
function validate_string()
{
    if [ ! "$1" ]
    then
        return 1
    else
        return 0
    fi  
}


#-------------------------------------------------------------------------------
# Validate an existing directory.
#
# USAGE:> validate_directory $DIR
#
function validate_directory()
{
    if [ ! "$1" ] || [ ! -d "$1" ]
    then
        return 1
    else
        return 0
    fi	
}
