#!/bin/bash
# dotw.bash
# Import Twitter posts into Day One.
# by Susan Pitman
# 11/14/14 Script created.
# 2/15/2019 Updated for dayone2. Added photo import (single right now) and tagging feature.

# Notes:
# 1. Change the twitter downloaded stuff directory name to "twitter."
# 2. Set your twitter username variable below. (Feel free to fix this; I was being lazy.)

#set -x

thisDir=`pwd`
twitterUsername="kitykity"

makePostFiles () {
    if ls -ld ${thisDir}/dotwPosts 2> /dev/null ; then
      printf "The posts directory already exists.\n"
     else
      mkdir ${thisDir}/dotwPosts
    fi
    fileNum="0"
    echo "" > "${thisDir}/dotwPosts/post.0"
      printf "Processing tweet.js file..."    
      # Each line in the monthly download file...
      while read thisLine ; do
      if echo ${thisLine} | grep "\"source\" :" > /dev/null ; then
        printf "."
        ((fileNum++))
        fileNumPadded=`printf %06d $fileNum`
        # Make a new file for each individual post.
        echo ${thisLine} > ${thisDir}/dotwPosts/post.${fileNumPadded}
       else
        echo ${thisLine} >> ${thisDir}/dotwPosts/post.${fileNumPadded}
      fi
  done < ${thisDir}/tweet.js
  printf "\n"
}

postPopper () {
  rm "${thisDir}/dotwPosts/post." "${thisDir}/dotwPosts/post.0" 2> /dev/null #Garbage file
  for fileName in `ls ${thisDir}/dotwPosts/p*` ; do
    postDateTime=`grep "created_at" ${fileName} | cut -d"\"" -f4`
    postYear=`grep "created_at" ${fileName} | cut -d"\"" -f4 | cut -d" " -f6`
    postMonthWord=`grep "created_at" ${fileName} | cut -d"\"" -f4 | cut -d" " -f2`
    postMonth=`date -jf %B ${postMonthWord} '+%m'`
    postMonth=`date -jf %B `grep "created_at" ${fileName} | cut -d"\"" -f4 | cut -d" " -f2` '+%m'`
    postDay=`grep "created_at" ${fileName} | cut -d"\"" -f4 | cut -d" " -f3`
    postHour=`grep "created_at" ${fileName} | cut -d"\"" -f4 | cut -d" " -f4 | cut -d":" -f1`
    postMinute=`grep "created_at" ${fileName} | cut -d"\"" -f4 | cut -d" " -f4 | cut -d":" -f2`
    if [ ${postHour} -gt "12" ] ; then
      postHour=`expr ${postHour} - 12`
      postAMPM="PM"
     else
      postAMPM="AM"
    fi
#    if [ ${postHour} = "00" ] ; then
      postTitle="Twitter Post"
#     else
### I gave up fighting with this. 
### If someone wants to figure out the time conversion, be my guest to clean up my mess...
#      postTitle="Twitter Post @ ${postHour}:${postMinute} ${postAMPM}"
#    fi
    postMinute=`echo ${postDateTime} | cut -d" " -f2 | cut -d":" -f2`
    postID=`grep "\"id\"" ${fileName} | head -1 | sed 's/"id" : //' | sed 's/\,//'`
    postUrl=`grep "expanded_url" ${fileName} | head -1 | cut -d"\"" -f4`
    #postText=`grep "\"text\"" ${fileName} | sed 's/\"text\" \: \"//' | sed 's/\"\,$//' | sed 's/^/#/'`
    postFullText=`grep "\"full_text\"" ${fileName} | cut -d"\"" -f4 | sed 's/\"\,$//'`
    postTextComplete="${postTitle}\n\n${postFullText}\n${postText}\n<${postUrl}>\n"
    postDateTimeForDayOne="${postMonth}/${postDay}/${postYear} ${postHour}:${postMinute}${postAMPM}"
    printf "\nFilename: ${fileName}\n"
    postMediaUrl=`grep "media_url\"" ${fileName} | head -1 | cut -d"\"" -f4`
    postMedia=`basename ${postMediaUrl}`
    postMediaFilename=`find ${thisDir}/twitter/tweet_media -name "*${postMedia}" | egrep "jpg|png|gif"`
    postTags=`grep "\"text\"" ${fileName} | cut -d":" -f2 | cut -d"\"" -f2 | sed 's/^/ /' | tr -d '\n'`
    printf "Post Date: ${postDateTimeForDayOne}\n"
    printf "${postText}\n"
    if [ ${postMedia} != "" ] ; then
      if [ ${postTags} != "" ] ; then
        printf "${postTextComplete}" | /usr/local/bin/dayone2 -p "${postMediaFilename}" -t "${postTags}" -d="${postDateTimeForDayOne}" new > /dev/null
       else
        printf "${postTextComplete}" | /usr/local/bin/dayone2 -p ${postMediaFilename} -d="${postDateTimeForDayOne}" new > /dev/null
      fi
     else
      if [ ${postTags} != "" ] ; then
        printf "${postTextComplete}" | /usr/local/bin/dayone2 -t "${postTags}" -d="${postDateTimeForDayOne}" new > /dev/null
       else
        printf "${postTextComplete}" | /usr/local/bin/dayone2 -d="${postDateTimeForDayOne}" new > /dev/null
      fi
    fi
    shortName=`echo ${fileName} | tr '/' '\n' | tail -1`
    mv ${fileName} ${thisDir}/dotwPosts/done.${shortName}
#    printf "`ls ${thisDir}/dotwPosts/p* | wc -l` posts left to import.\n"
#    sleep 5
    printf "Hit Enter for the next one... " ; read m
  done
}

## MAIN ##
#makePostFiles
postPopper
## END OF SCRIPT ##
