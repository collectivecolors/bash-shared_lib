#!/bin/bash
#
# filesystem.sh
#

#-------------------------------------------------------------------------------
# Shared functions


#-------------------------------------------------------------------------------
# Transfer one directory to another. (NON DESTRUCTIVE)
#
# USAGE:> transfer_directory [ --sudo ][ --force ] $ORIGIN_DIR $DEST_DIR
#
function transfer_directory()
{
    local PARAMS=`normalize_params "$@"`
    local SUDO_ENABLED=''
    local FORCE_OVERWRITE=''
        
    parse_flag '-s|--sudo' SUDO_ENABLED || return 1
    parse_flag '-f|--force' FORCE_OVERWRITE || return 2
    set -- $PARAMS
    
    local ORIGIN_DIR="$1"
    local DEST_DIR="$2"
    
    # echo "PARAMS = $@"
    # echo "ORIGIN_DIR = $ORIGIN_DIR"
    # echo "DEST_DIR = $DEST_DIR"
    # echo "SUDO_ENABLED = $SUDO_ENABLED"
            
    if [ "$ORIGIN_DIR" != "$DEST_DIR" ]
    then
        if [ "$FORCE_OVERWRITE" -o ! -d "$DEST_DIR" ]
        then
            echo "Transfering $ORIGIN_DIR to $DEST_DIR."
            
            if [ "$SUDO_ENABLED" ]
            then
            	# echo "SUDO enabled."
                if [ "$FORCE_OVERWRITE" ]
                then
                	echo "Removing existing directory: $DEST_DIR (as admin)."
                	sudo rm -Rf "$DEST_DIR"
                fi
                echo "Copying $ORIGIN_DIR to $DEST_DIR (as admin)."
                sudo cp -Rf "$ORIGIN_DIR" "$DEST_DIR"
            else
                if [ "$FORCE_OVERWRITE" ]
                then
                    echo "Removing existing directory: $DEST_DIR."
                    rm -Rf "$DEST_DIR"
                fi
                echo "Copying $ORIGIN_DIR to $DEST_DIR."
                cp -Rf "$ORIGIN_DIR" "$DEST_DIR"
            fi
        else
            echo "Directory $DEST_DIR already exists.  If you wish to replace it, delete it first."
            return 3 
        fi
    fi
    return 0
}


#-------------------------------------------------------------------------------
# Change permissions on all directories under a base directory.
#
# USAGE:> directory_access [ --sudo ] $BASE_DIR $PERM
#
function directory_access()
{
    local PARAMS=`normalize_params "$@"`
    local SUDO_ENABLED=''
        
    parse_flag "-s|--sudo" SUDO_ENABLED || return 1
    set -- $PARAMS
    
    local BASE_DIR="$1"
    local PERM="$2"
            
    if [ "$SUDO_ENABLED" ]
    then
        echo "Adjusting permissions for all directories under $BASE_DIR to $PERM (as admin)."
        sudo find "$BASE_DIR" -type d -exec chmod "$PERM" {} \; || return 2
    else
        echo "Adjusting permissions for all directories under $BASE_DIR to $PERM."
        find "$BASE_DIR" -type d -exec chmod "$PERM" {} \; || return 2
    fi
}


#-------------------------------------------------------------------------------
# Change permissions on all files under a base directory.
#
# USAGE:> file_access [ --sudo ] $BASE_DIR $PERM
#
function file_access()
{
    local PARAMS=`normalize_params "$@"`
    local SUDO_ENABLED=''
        
    parse_flag "-s|--sudo" SUDO_ENABLED || return 1
    set -- $PARAMS
    
    local BASE_DIR="$1"
    local PERM="$2"
    
    if [ "$SUDO_ENABLED" ]
    then
        echo "Adjusting permissions for all files under $BASE_DIR to $PERM (as admin)."
        sudo find "$BASE_DIR" -type f -exec chmod "$PERM" {} \; || return 2
    else
    echo "Adjusting permissions for all files under $BASE_DIR to $PERM."
        find "$BASE_DIR" -type f -exec chmod "$PERM" {} \; || return 2
    fi
}


#-------------------------------------------------------------------------------
# Change permissions on all files or directories matching a specified pattern 
# under a base directory.
#
# USAGE:> pattern_access [ --sudo ] $BASE_DIR $PATTERN $PERM
#
function pattern_access()
{
    local PARAMS=`normalize_params "$@"`
    local SUDO_ENABLED=''
        
    parse_flag "-s|--sudo" SUDO_ENABLED || return 1
    set -- $PARAMS
    
    local BASE_DIR="$1"
    local PATTERN="${2//\'/}"
    local PERM="$3"
    
    
    
    if [ "$SUDO_ENABLED" ]
    then
        echo "Adjusting permissions for all files or directories under $BASE_DIR matching $PATTERN to $PERM (as admin)."
        sudo find "$BASE_DIR" -name "$PATTERN" -exec chmod "$PERM" {} \; || return 2
    else
    echo "Adjusting permissions for all files or directories under $BASE_DIR matching $PATTERN to $PERM."
        find "$BASE_DIR" -name "$PATTERN" -exec chmod "$PERM" {} \; || return 2
    fi 
}
