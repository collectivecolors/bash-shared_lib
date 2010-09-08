#!/bin/bash
#
# command.sh
#


#-------------------------------------------------------------------------------
# Convert parameters into newline separated sections.
#
# This way we can avoid problems with quote expansion when passing parameters
# around.
#
# USAGE:> PARAMS=`normalize_params "$@"`
#
function normalize_params()
{
    local PARAMS=''
    
    for PARAM in "$@"
    do
        PARAMS="${PARAMS}${PARAM}"$'\n'
    done
    
    echo "$PARAMS"
    return 0    
}


#-------------------------------------------------------------------------------
# Return whether or not parameters have a particular flag enabled.
#
# USAGE:> parse_flag $FLAG FOUND_REF
#
# Note: Needs [ PARAMS="$@" ] defined in the calling function.
#       The flag is removed from this variable.
#
function parse_flag()
{
    local FLAGS="$1"
    local FOUND="$2"
    
    local LOCAL_FOUND=''
    
    local ALT_PARAMS=''
    local IFS_ORIG="$IFS"
    
    IFS='|'
    read -ra FLAG_ARRAY <<< "$FLAGS"
    
    IFS=$'\n'        
    for PARAM in $PARAMS  # $PARAMS is not a local variable
    do 
        # echo "PARAM = $PARAM"
        for FLAG in "${FLAG_ARRAY[@]}"
        do
           if [ "$PARAM" = "$FLAG" ]
           then
               eval $FOUND="$PARAM" # Notify parent script that flag was found.
               LOCAL_FOUND='1'
               
               # echo "Flag $FLAG found."
               break
           fi
        done
        
        if [ ! "$LOCAL_FOUND" ]
        then
           ALT_PARAMS="${ALT_PARAMS}${PARAM}"$'\n'
           # echo "ALT_PARAMS = $ALT_PARAMS"  
        fi
        
        LOCAL_FOUND=''
    done
    
    PARAMS=$ALT_PARAMS  # Reassign to calling function params.
    IFS="$IFS_ORIG"
    return 0
}


#-------------------------------------------------------------------------------
# Return whether or not parameters have a particular option specified.
#
# USAGE:> parse_option $OPTION VALUE_REF $VALIDATOR_FUNC $ERROR_MSG
#
# Note: Needs [ PARAMS="$@" ] defined in the calling function.
#       The option and value are removed from this variable.
#
function parse_option()
{
    local OPTIONS="$1"
    local VALUE="$2"
    local VALIDATOR="$3"
    local ERROR_MSG="$4"
    
    if [ ! "$VALIDATOR" ]
    then
    	VALIDATOR='validate_string' # Default option value is non empty string
    fi
    
    local ALT_PARAMS=''
    local IFS_ORIG="$IFS"
        
    local OPTION_FOUND=''
    local VALUE_FOUND=''
    local NEEDS_PROCESSING=''
    
    local APPENDED_VALUES=''
    
    local TEMP_PARAM=''
    local TEMP_VALUE=''
    
    IFS='|'
    read -ra OPTION_ARRAY <<< "$OPTIONS"
    
    IFS=$'\n'
    for PARAM in $PARAMS  # $PARAMS is not a local variable
    do 
        # echo "PARAM = $PARAM"
        if [ "$NEEDS_PROCESSING" ]
        then
            # echo "OPTION FOUND - Retreiving Value"
            if [ "$VALIDATOR" ]
            then
                # echo "$VALIDATOR '$PARAM'"
                if ! $VALIDATOR "$PARAM"
                then
                    ERROR_MSG=`echo $ERROR_MSG | sed "s|{}|$PARAM|g"`
                    echo "$ERROR_MSG"
                    return 1
                fi
            fi
            eval $VALUE="'$PARAM'" # Notify parent script that option was found.
            VALUE_FOUND='1'
            NEEDS_PROCESSING=''
            continue
        fi
            
        IFS='=' # See if we have an equal sign separating option from value
        read -ra APPENDED_VALUES <<< "$PARAM"
        IFS="$IFS_ORIG"
           
        PARAM="${APPENDED_VALUES[0]}"
        TEMP_VALUE="${APPENDED_VALUES[1]}"
            
        # echo "MOD PARAM = $PARAM"
        # echo "TEMP_VALUE = $TEMP_VALUE"
            
        for OPTION in "${OPTION_ARRAY[@]}"
        do
            # echo "OPTION  = $OPTION"
                            
            if [ "$PARAM" = "$OPTION" ]
            then
            	OPTION_FOUND='1'
            	
                if [ "$TEMP_VALUE" ]
                then
                   if [ "$VALIDATOR" ]
                    then
                        # echo "$VALIDATOR '$TEMP_VALUE'"
                        if ! $VALIDATOR "$TEMP_VALUE"
                        then
                            ERROR_MSG=`echo $ERROR_MSG | sed "s|{}|$TEMP_VALUE|g"`
                            echo "$ERROR_MSG"
                            
                            IFS="$IFS_ORIG"
                            return 1
                        fi
                    fi
                    eval $VALUE="'$TEMP_VALUE'" # Notify parent script that option was found.
                    VALUE_FOUND='1'
                    NEEDS_PROCESSING='' 
                else
                   # echo "OPTION FOUND - Setting Flag"
                   NEEDS_PROCESSING='1'
                fi                
                break                
            fi
        done
        
        if [ ! "$NEEDS_PROCESSING" -a ! "$TEMP_VALUE" ]
        then
           ALT_PARAMS="${ALT_PARAMS}${PARAM}"$'\n'
           # echo "ALT_PARAMS = $ALT_PARAMS"
           TEMP_VALUE=''  
        fi
    done
    
    # Check if we have a value.
    if [ "$OPTION_FOUND" -a ! "$VALUE_FOUND" ]
    then
        ERROR_MSG=`echo $ERROR_MSG | sed "s|{}|(empty)|g"`
        echo "$ERROR_MSG"
                            
        IFS="$IFS_ORIG"
        return 1	
    fi
    
    PARAMS=$ALT_PARAMS  # Reassign to calling function params.
    IFS="$IFS_ORIG"
    return 0
}
