#!/bin/bash

# -----
# Usage
# -----
# $ . gapps.sh <banks|pn>



# ------
# Colors
# ------
BLDGREEN="\033[1m""\033[32m"
RST="\033[0m"



# ----------
# Parameters
# ----------
# Parameter 1: Which GApps to compile? (currently Banks or Pure Nexus Dynamic GApps)

# Unassign personal flag
PERSONAL=false

if [[ "${1}" == "me" ]]; then
   PERSONAL=true
   TYPE=banks
   ZIPMOVE=${HOME}/shared/.me
else
   TYPE=${1}
   ZIPMOVE=${HOME}/shared/GApps
fi


# ---------
# Variables
# ---------
ANDROIDDIR=${HOME}
if [[ "${TYPE}" == "banks" ]]; then
    SOURCEDIR=${ANDROIDDIR}/GApps/Banks
    ZIPBEG=banks
    BRANCH=m
elif [[ "${TYPE}" == "pn" ]]; then
    SOURCEDIR=${ANDROIDDIR}/GApps/PN
    ZIPBEG=PureNexus
    BRANCH=mm2
fi
# Export the LOG variable for other files to use (I currently handle this via .bashrc)
# export LOGDIR=${ANDROID_DIR}/Logs
# export LOG=${LOGDIR}/compile_log_`date +%m_%d_%y`.log



# Clear the terminal
clear



# Start tracking time
START=$(date +%s)



# Go into repo folder
cd ${SOURCEDIR}



# Clean up repo
git reset --hard origin/${BRANCH}
git clean -f -d -x



# Get new changes
git pull



# Make GApps
. mkgapps.sh



# If the above was successful
if [[ `ls ${SOURCEDIR}/out/${ZIPBEG}*.zip 2>/dev/null | wc -l` != "0" ]]; then
   BUILD_RESULT_STRING="BUILD SUCCESSFUL"



   # Remove current GApps and move the new ones in their place
   if [[ "${TYPE}" == "banks" && ${PERSONAL} = false ]]; then
      rm -rf ${HOME}/shared/.me/${ZIPBEG}*.zip
   fi
   rm -rf ${ZIPMOVE}/${ZIPBEG}*.zip

   if [[ "${TYPE}" == "banks" && ${PERSONAL} = false ]]; then
      cp -v ${SOURCEDIR}/out/${ZIPBEG}*.zip ${HOME}/shared/.me
   fi
   mv -v ${SOURCEDIR}/out/${ZIPBEG}*.zip ${ZIPMOVE}



# If the build failed, add a variable
else
   BUILD_RESULT_STRING="BUILD FAILED"

fi



# Upload them
. ~/upload.sh



# Stop tracking time
END=$(date +%s)



# Go home and we're done!
cd ${HOME}



echo -e ${BLDGREEN}
echo -e "-------------------------------------"
echo -e "SCRIPT ENDING AT $(date +%D\ %r)"
echo -e ""
echo -e "${BUILD_RESULT_STRING}!"
echo -e "TIME: $(echo $((${END}-${START})) | awk '{print int($1/60)" MINUTES AND "int($1%60)" SECONDS"}')"
echo -e "-------------------------------------"
echo -e ${RST}

# Add line to compile log
echo -e "`date +%H:%M:%S`: ${BASH_SOURCE} ${TYPE}" >> ${LOG}
echo -e "${BUILD_RESULT_STRING} IN $(echo $((${END}-${START})) | awk '{print int($1/60)" MINUTES AND "int($1%60)" SECONDS"}')\n" >> ${LOG}

echo -e "\a"
