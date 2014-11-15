#!/bin/bash
# dotw.bash
# Export Twitter posts.
# Import Twitter posts into Day One.
# by Susan Pitman
# 11/14/14 Script created.
thisDir=`pwd`
tweetDir="${thisDir}/data/js/tweets"

makePostFiles () {
    if ls -ld ${thisDir}/dotwPosts 2> /dev/null ; then
      printf "The posts directory already exists.\n"
     else
      mkdir ${thisDir}/dotwPosts
    fi
    fileNum="0"
    echo "" > "${thisDir}/dotwPosts/post.0"
    # For each monthly file that Twitter gives you in the download...
    for tweetFile in `ls ${tweetDir}` ; do
      printf "Processing ${tweetFile}..."    
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
    done < ${tweetDir}/${tweetFile}
    printf "\n"
  done
}

postPopper () {
  rm "${thisDir}/dotwPosts/post." "${thisDir}/dotwPosts/post.0" 2> /dev/null #Garbage file
  for fileName in `ls ${thisDir}/dotwPosts/p*` ; do
    postDateTime=`grep "created_at" ${fileName} | sed -e 's/\"created_at\" : \"//' | sed -e 's/\",//'`
    postYear=`echo ${postDateTime} | cut -d"-" -f1`
    postMonth=`echo ${postDateTime} | cut -d"-" -f2`
    postDay=`echo ${postDateTime} | cut -d"-" -f3 | cut -d" " -f1`
    postHour=`echo ${postDateTime} | cut -d" " -f2 | cut -d":" -f1`
    if [ ${postHour} -gt "12" ] ; then
      postHour=`expr ${postHour} - 12`
      postAMPM="PM"
     else
      postAMPM="AM"
    fi
    if [ ${postHour} = "00" ] ; then
      postTitle="Twitter Post"
     else
      postTitle="Twitter Post @ ${postHour}:${postMinute} ${postAMPM}"
    fi
    postMinute=`echo ${postDateTime} | cut -d" " -f2 | cut -d":" -f2`
    postID=`grep "\"id\"" ${fileName} | head -1 | sed 's/"id" : //' | sed 's/\,//'`
    postUsername=`grep "\"screen_name\"" ${fileName} | sed 's/\"screen_name\" \: \"//' | sed 's/\"\,$//'`
    postText=`grep "\"text\"" ${fileName} | sed 's/\"text\" \: \"//' | sed 's/\"\,$//'`
    postTextComplete="${postTitle}\n\n${postText}\n<a href=https://twitter.com/${postUsername}/statuses/${postID}>(view)</a>\n"
    postDateTimeForDayOne="${postMonth}/${postDay}/${postYear} ${postHour}:${postMinute}${postAMPM}"
    printf "\nFilename: ${fileName}\n"
    printf "Post Date: ${postDateTimeForDayOne}\n"
    printf "${postText}\n"
    printf "${postTextComplete}" | /usr/local/bin/dayone -d="${postDateTimeForDayOne}" new
    shortName=`echo ${fileName} | tr '/' '\n' | tail -1`
    mv ${fileName} ${thisDir}/dotwPosts/done.${shortName}
    printf "`ls ${thisDir}/dotwPosts/p* | wc -l` posts left to import.\n"
    sleep 5
    # printf "Hit Enter for the next one... " ; read m
  done
}

## MAIN ##
makePostFiles
postPopper
## END OF SCRIPT ##
