# YCF - Youtube Comment Filter
A solution for users to have a comfortable environment to enjoy their video time.

## Overview
Youtube Comment Filter(YCF) is a website that it can help people to filter the comments. 

Nowadays, people can find any kinds of videos easily by just only need to key some key words in the search bar in YouTube. As we know that each video may have many different comments from many different users. And these comments may be positve or negative. But the users can not have a chance to choose the comments what they want to see.

In our product, we solve the problem by using Machine Learning algorithm. Users can just only get positive comments or negative comments, but also all of them too. This method will provide users to have a better environment to watch videos because they don't need to see the comments what they don't want to realize.

## Short-term usability goals
- Get comments from users' selected video using YouTube API
- Analyze the comments by using SnowNLP
- Display the comments 

## Long-term goals
- Analyze the comments with more funny ways (EX. Word Cloud)
- Try to speedup
- Try to get more comments dynamically


## Requirement

In order to run the snownlp for comment analysis, please install the following package:

-   pip3 install snownlp

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
