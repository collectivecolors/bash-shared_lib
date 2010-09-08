 #!/bin/bash
#
# script.sh
#

#-------------------------------------------------------------------------------
# Shared functions


#-------------------------------------------------------------------------------
# Install a script package from a remote repository. 
#
# USAGE:> install_script_package [ --force ] [ --install ] 
#                                [ --github-acct $GITHUB_ACCT ] 
#                                [ --proj-dir $PROJ_DIR ] 
#                                $REPOSITORY 
#                                $PROJ_NAME
#                                $PUBLIC_SCRIPT (For checking existence of package)
#
function install_script_package()
{
    local PARAMS=`normalize_params "$@"`
    local FORCE_ENABLED=''
    local INSTALL_ENABLED=''
        
    local PKG_GITHUB_ACCT="$GITHUB_ACCT"
    local PKG_PROJ_DIR="$SCRIPT_PROJ_DIR"
    
    parse_flag '-f|--force' FORCE_ENABLED || return 1
    parse_flag '-i|--install' INSTALL_ENABLED || return 2
    parse_option '-g|--github-acct' PKG_GITHUB_ACCT validate_string "GitHub account can not be an empty string." || return 3
    parse_option '-p|--proj-dir' PKG_PROJ_DIR validate_directory "Path {} must be an existing directory." || return 4
    set -- $PARAMS
    
    local REPOSITORY="$1"
    local PROJ_NAME="$2"
    local PUBLIC_SCRIPT="$3"
    
    if [ "$PUBLIC_SCRIPT" -o ! `which "$PUBLIC_SCRIPT"` ]
    then
        PKG_REPO="git://github.com/$GITHUB_ACCT/$REPOSITORY.git"
        PKG_DIR="$PKG_PROJ_DIR/$PROJ_NAME"
    
        echo "Library $PROJ_NAME not found.  Downloading from source."
        
        if [ "$FORCE_ENABLED" ]
        then
            rm -Rf "$PKG_DIR" || exit 5
        fi
        
        mkdir -p "$PKG_PROJ_DIR" || exit 6   
        git clone "$PKG_REPO" "$PKG_DIR" || exit 7
    
        echo "Initializing shared lib at $SERVER_ADMIN_DIR."
        chmod 755 "$PKG_DIR/init.sh" || exit 8
        $PKG_DIR/init.sh "$FORCE_ENABLED" "$INSTALL_ENABLED" || exit 9
    fi	
}


#-------------------------------------------------------------------------------
# Create symbolic links in a specified searchable bin directory for all public
# scripts under a base directory.
#
# USAGE:> init_script_package [ --sudo ] [ --force ] 
#                             [ --script-ext $SCRIPT_EXT ] 
#                             [ --public-ext $PUBLIC_EXT ] 
#                             [ --bin-dir $BIN_DIR ] 
#                             $INIT_DIR 
#                             $LIB_DIR
#
function init_script_package()
{
    local PARAMS=`normalize_params "$@"`
    local SUDO_ENABLED=''
    local FORCE_ENABLED=''
    
    local PKG_SCRIPT_EXT="$SCRIPT_EXT"
    local PKG_PUBLIC_EXT="$PUBLIC_EXT"
    local PKG_BIN_DIR="$COMMON_BIN_DIR"
            
    parse_flag '-s|--sudo' SUDO_ENABLED || return 1
    parse_flag '-f|--force' FORCE_ENABLED || return 2
    parse_option '-e|--script-ext' PKG_SCRIPT_EXT validate_string "Script extension can not be an empty string." || return 3
    parse_option '-p|--public-ext' PKG_PUBLIC_EXT validate_string "Public script extension can not be an empty string." || return 4
    parse_option '-b|--bin-dir' PKG_BIN_DIR validate_directory "Path {} must be an existing directory." || return 5
    set -- $PARAMS
    
    local INIT_DIR="$1"
    local LIB_DIR="$2"
    
    echo "[ 1/3 ] - Transfering script package."
    transfer_directory "$SUDO_ENABLED" "$FORCE_ENABLED" "$INIT_DIR" "$LIB_DIR" || return 6

    echo "[ 2/3 ] - Adjusting permissions for script package."
    init_script_package_access "$SUDO_ENABLED" "$LIB_DIR" "$PKG_SCRIPT_EXT" || return 7

    echo "[ 3/3 ] - Linking public utilities and property files."
    link_public_scripts "$SUDO_ENABLED" "$LIB_DIR" "$PKG_BIN_DIR" "$PKG_PUBLIC_EXT" || return 8
    return 0	
}

    
#-------------------------------------------------------------------------------
# Initialize access settings for a script package.
#
# USAGE:> init_script_package_access [ --sudo ] $LIB_DIR $SCRIPT_EXT
#
function init_script_package_access()
{
    local PARAMS=`normalize_params "$@"`
    local SUDO_ENABLED=''
        
    parse_flag '-s|--sudo' SUDO_ENABLED || return 1
    set -- $PARAMS
    
    local PKG_LIB_DIR="$1"
    local PKG_SCRIPT_EXT="$2"
    
    directory_access "$SUDO_ENABLED" "$PKG_LIB_DIR" 755 || return 2
    file_access "$SUDO_ENABLED" "$PKG_LIB_DIR" 644 || return 3
    pattern_access "$SUDO_ENABLED" "$PKG_LIB_DIR" "'*.$PKG_SCRIPT_EXT'" 755 || return 4    
    return 0   	
}
 
    
#-------------------------------------------------------------------------------
# Create symbolic links in a specified searchable bin directory for all public
# scripts under a base directory.
#
# USAGE:> link_public_scripts [ --sudo ] $BASE_DIR $PUBLIC_BIN_DIR $PUBLIC_EXT
#
function link_public_scripts()
{
    local PARAMS=`normalize_params "$@"`
    local SUDO_ENABLED=''
        
    parse_flag '-s|--sudo' SUDO_ENABLED || return 1
    set -- $PARAMS
    
    local BASE_DIR="$1"
    local PUBLIC_BIN_DIR="$2"
    local PUBLIC_EXT="$3"
    
    for PUBLIC_SCRIPT in `find "$BASE_DIR" -name "*.$PUBLIC_EXT"` 
    do
        #echo "$PUBLIC_SCRIPT"
    
        SCRIPT_DIR=`dirname "$PUBLIC_SCRIPT"`
        SCRIPT_FILE=`basename "$PUBLIC_SCRIPT"`
        SCRIPT_NAME=${SCRIPT_FILE//.$PUBLIC_EXT/} # No extension
    
        #echo "$SCRIPT_DIR"
        #echo "$SCRIPT_FILE"
        #echo "$SCRIPT_NAME"
           
        if [ "$SUDO_ENABLED" ]
        then
            echo "Linking to $SCRIPT_DIR/$SCRIPT_FILE from $PUBLIC_BIN_DIR/$SCRIPT_NAME (as admin)."
            sudo ln -f -s "$PUBLIC_SCRIPT" "$PUBLIC_BIN_DIR/$SCRIPT_NAME" || return 2
        else
            echo "Linking to $SCRIPT_DIR/$SCRIPT_FILE from $PUBLIC_BIN_DIR/$SCRIPT_NAME."
            ln -f -s "$PUBLIC_SCRIPT" "$PUBLIC_BIN_DIR/$SCRIPT_NAME" || return 2
        fi    
    done
    return 0  
}
 