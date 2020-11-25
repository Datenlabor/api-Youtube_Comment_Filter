# YCF - Youtube Comment Filter
A solution for users to have a comfortable environment to enjoy their video time.

## Overview
Youtube Comment Filter(YCF) is a website that it can help people to filter the comments. 

Nowadays, people can find any kinds of videos easily by just only need to key some key words in the search bar in YouTube. As we know that each video can have many different comments from different users. These comments showed on YouTube can be positve or negative. But the problem is that the users can not have a chance to choose the comments what they want to see. And this problem may hurt the user experience while using YouTube.

In our product, we try to solve the problem by using Machine Learning algorithm. Users can just only get positive/negative comments, but also all of them too. Our method will provide users to have a better environment to watch videos because they won't find any comments which they don't want to see.

## Short-term usability goals
- Get comments from users' selected video using YouTube API
- Analyze the comments by using SnowNLP
- Display the comments 

## Long-term goals
- Analyze the comments with more funny ways (EX. Word Cloud)
- Try to speedup
- Try to get more comments dynamically


## Requirement

In order to run the snownlp/textblob for comment analysis, please install the following package:

-   pip3 install snownlp
-   pip3 install textblob

## Resource

-   Comments

## Elements (What we fetch from youtube api)

-   Comments
    -   textDisplay
    -   authorDisplayName
    -   author_id
    -   author_image
    -   likeCount
    -   totalReplyCount

## Entities

Replies would be hashed to the corresponding comments

-   Comments
    -   Score of each comment(called polarity in the project)
