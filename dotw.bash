#!/bin/bash
# dowp.bash
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
    for tweetFile in `ls ${tweetDir}` ; do
      printf "Processing ${tweetFile}..."    
      while read thisLine ; do
      if echo ${thisLine} | grep "\"source\" :" > /dev/null ; then
        printf "."
        ((fileNum++))
        fileNumPadded=`printf %06d $fileNum`
        echo ${thisLine} > ${thisDir}/dotwPosts/post.${fileNumPadded}
       else
        echo ${thisLine} >> ${thisDir}/dotwPosts/post.${fileNumPadded}
      fi
    done < ${tweetDir}/${tweetFile}
    printf "\n"
  done
}

makePostFiles

