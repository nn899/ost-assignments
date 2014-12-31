#!/usr/bin/env bash


# The above line could be #!/usr/bin/bash or #!/usr/local/bin/bash as well but
# this way the user's preferred Bourne Again Shell installation will be used.

# Script name: question

# Since the script is supposed to be run like a command, following steps will be
# required to create the script:
# mkdir -p ~/bin
# cd bin
# vim question
# This script goes into the file "question"
# chmod 711 question
# export PATH=$PATH:~/bin
# The script can now be run as:
# question option [args]
# instead of:
# ./question option [args]

mkdir -p ~/.question/questions ~/.question/answers ~/.question/votes
# The above command creates missing parent directories as well and does not
# complain if the directory already exists.

chmod 711 /home/$USER
#chmod 711 /home/nn899
# The above commented line can be run instead if specifically my directory permissions
# are required to be changed.
# As mentioned in the assignment, this makes sure that my home directory has
# execute permission for everyone.

chmod -R 711 /home/$USER/bin
# This makes sure that everybody has execute permission on this script.
# This is required to be able to run the script as a command.

chmod -R 744 ~/.question
# This makes the permissions of this directory and all directories and files
# under it world readable.

USERS_FILE=/home/unixtool/data/question/users
ERROR_WRONG_USERS_FILE=1
ERROR_UNAUTHORIZED_USER=2

if [ ! -e $USERS_FILE ]
then
    printf "The file $USERS_FILE does not exist.\n"
    printf "Please provide correct path to the file and run the command again.\n"
    exit $ERROR_WRONG_USERS_FILE
fi

USERNAME_MATCH=`grep -oP "\b$USER\b" $USERS_FILE`
if [[ ! $USERNAME_MATCH ]]
then
    printf "You are not an authorized user on the server.\n" 1>&2
    printf "Your name must be present in the file $USERS_FILE to use the question command.\n" 1>&2
    exit $ERROR_UNAUTHORIZED_USER
fi

MIN_ARGS=1
ERROR_NO_ARGUMENTS=3
if [ $# -lt "$MIN_ARGS" ]
then
    printf "No option supplied\n" 1>&2
    printf "Usage: `basename $0` option [args]\n" 1>&2
    exit $ERROR_NO_ARGUMENTS
fi

ERROR_INVALID_OPTION=4
if ! [[ "$1" == "create" || "$1" == "answer" || "$1" == "list" || "$1" == "vote" || "$1" == "view" ]]
then
    printf "Invalid option supplied\n" 1>&2
    printf "The available options are create, answer, list, vote and view.\n" 1>&2
    printf "Usage: `basename $0` option [args]\n" 1>&2
    exit $ERROR_INVALID_OPTION
fi

MAX_ARGS=4
ERROR_EXCESS_ARGUMENTS=5
if [[ $# -gt "$MAX_ARGS" && "$1" != "view" ]]
then
    printf "Too many arguments supplied\n" 1>&2
    printf "Usage: `basename $0` option [args]\n" 1>&2
    exit $ERROR_EXCESS_ARGUMENTS
fi

################################ create ###################################################
ERROR_CREATE_ARGUMENTS=6
ERROR_INVALID_QUESTION_NAME=7
ERROR_QUESTION_NOT_UNIQUE=8
ERROR_INVALID_QUESTION=9
if [ "$1" == "create" ]
then
    if [[ $# -eq 1 || $# -eq 4 ]]
    then
        printf "Invalid number of arguments supplied for create option\n" 1>&2
        printf "Usage: question create name [question]\n" 1>&2
	exit $ERROR_CREATE_ARGUMENTS
    fi
    question_name=$2
    if [[ "$question_name" =~ "/" || -z "$question_name" || "$question_name" == $'\n' || "$question_name" =~ ^\ +$ ]]
    then
        printf "Invalid question name supplied\n" 1>&2
	printf "Question name cannot have forward slash (/) in it, should not be empty or have only whitespaces.\n" 1>&2
	exit $ERROR_INVALID_QUESTION_NAME
    fi
    if [ -e ~/.question/questions/"$question_name" ]
    then
        printf "A question with this name already exists. Please try another unique name.\n" 1>&2
	exit $ERROR_QUESTION_NOT_UNIQUE
    fi
    if [ $# -eq 3 ]
    then
        question=$3
        if [[ "$question" =~ "====" || -z "$question" || "$question" == $'\n' || "$question" =~ ^\ +$ ]]
	then
	    printf "Invalid characters in the question\n" 1>&2
            printf "Question cannot be empty or only whitespaces or contain the sequence of characters ====\n" 1>&2
	    exit $ERROR_INVALID_QUESTION
	fi
    fi
    if [ $# -eq 2 ]
    then
#       printf "Please press Enter key followed by CTRL+D to end your question:\n"
#	question=`cat`
        printf "Please enter your question below and hit Enter key when done:\n" 1>&2
	read question
	if [[ "$question" =~ "====" || -z "$question" || "$question" == $'\n' || "$question" =~ ^\ +$ ]]
	then
	    printf "Invalid characters in the question\n" 1>&2
	    printf "Question cannot be empty or only whitespaces or contain the sequence of characters ====\n" 1>&2
	    exit $ERROR_INVALID_QUESTION
	fi
    fi
    touch ~/.question/questions/"$question_name"
    chmod 755 ~/.question/questions/"$question_name"
    echo "$question" > ~/.question/questions/"$question_name"
fi

############################## answer ##########################################################
ERROR_ANSWER_ARGUMENTS=10
ERROR_INVALID_QUESTION_ID=11
ERROR_INVALID_USER=12
ERROR_NO_READ_PERMISSION=13
ERROR_NO_CORRESPONDING_QUESTION=14
ERROR_INVALID_ANSWER_NAME=15
ERROR_ANSWER_NOT_UNIQUE=16
ERROR_INVALID_ANSWER=17
if [ "$1" == "answer" ]
then
    if [[ $# -eq 1 || $# -eq 2 ]]
    then
        printf "Invalid number of arguments supplied for answer option\n" 1>&2
        printf "Usage: question answer question_id name [answer]\n" 1>&2
	exit $ERROR_ANSWER_ARGUMENTS
    fi

    question_id=$2
    question_id_login=`expr match "$question_id" '\(.*\)/'`
    question_id_name=`expr match "$question_id" '.*/\(.*\)'`

# Add condition to check validity of the login and name part of id and also check
# that a question corresponding to the name part of the id exists.
    if [[ "$question_id_login" =~ "/" || "$question_id_name" =~ "/" || -z "$question_id_login" || -z "$question_id_name" || "$question_id_login" == $'\n' || "$question_id_name" == $'\n' || "$question_id_login" =~ ^\ +$ || "$question_id_name" =~ ^\ +$ ]]
    then
        printf "Invalid question_id supplied\n" 1>&2
	printf "A valid question_id is of the form login/name where login and name\n" 1>&2
	printf "should not be empty or only whitespaces or contain a forward slash (/).\n" 1>&2
	exit $ERROR_INVALID_QUESTION_ID
    fi
    GREP_MATCH=`grep -oP "\b$question_id_login\b" $USERS_FILE`
    if [[ ! $GREP_MATCH ]]
    then
        printf "The user $question_id_login is an invalid user\n" 1>&2
        exit $ERROR_INVALID_USER
    fi
    if [ ! -r /home/"$question_id_login"/.question ]
    then
        printf "No read permission on the /home/$question_id_login/.question directory\n" 1>&2
        exit $ERROR_NO_READ_PERMISSION
    fi
    if [ ! -e /home/"$question_id_login"/.question/questions/"$question_id_name" ]
    then
        printf "No corresponding question exists for $question_id\n" 1>&2
        exit $ERROR_NO_CORRESPONDING_QUESTION
    fi
    answer_name=$3
    if [[ "$answer_name" =~ "/" || -z "$answer_name" || "$answer_name" == $'\n' || "$answer_name" =~ ^\ +$ ]]
    then
        printf "Invalid answer name supplied\n" 1>&2
	printf "Answer name cannot have forward slash (/) in it, cannot have only whitespaces and has to have some characters.\n" 1>&2
	exit $ERROR_INVALID_ANSWER_NAME
    fi
    if [ -e ~/.question/answers/"$question_id"/"$answer_name" ]
    then
        printf "An answer with this name already exists. Please try another unique name.\n" 1>&2
	exit $ERROR_ANSWER_NOT_UNIQUE
    fi
    if [ $# -eq 4 ]
    then
        answer=$4
        if [[ "$answer" =~ "====" || -z "$answer" || "$answer" == $'\n' || "$answer" =~ ^\ +$ ]]
	then
	    printf "Invalid characters in the answer\n" 1>&2
            printf "Answer cannot be empty or only whitespaces or contain the sequence of characters ====\n" 1>&2
	    exit $ERROR_INVALID_ANSWER
	fi
    fi
    if [ $# -eq 3 ]
    then
        printf "Please enter your answer below and hit Enter key when done:\n" 1>&2
        read answer
        if [[ "$answer" =~ "====" || -z "$answer" || "$answer" == $'\n' || "$answer" =~ ^\ +$ ]]
	then
	    printf "Invalid characters in the answer\n" 1>&2
	    printf "Answer cannot be empty or only whitespaces or contain the sequence of characters ====\n" 1>&2
	    exit $ERROR_INVALID_ANSWER
	fi
    fi
    mkdir -p ~/.question/answers/"$question_id"
    touch ~/.question/answers/"$question_id"/"$answer_name"
    chmod 755 ~/.question/answers/"$question_id"/"$answer_name"
    echo "$answer" > ~/.question/answers/"$question_id"/"$answer_name"
fi

############################## list ############################################################
ERROR_LIST_ARGUMENTS=18
ERROR_INVALID_USER_NAME=19
ERROR_USER_NO_QUESTIONS=20
if [ "$1" == "list" ]
then
    if [[ $# -eq 3 || $# -eq 4 ]]
    then
        printf "Invalid number of arguments supplied for list option\n" 1>&2
        printf "Usage: question list [user]\n" 1>&2
	exit $ERROR_LIST_ARGUMENTS
    fi
    if [[ $# -eq 1 ]]
    then
#       for i in `find ~/.question/answers/ -maxdepth 2 -mindepth 2 -type d`
#       FIND_OUTPUT=`find /home/ -mindepth 2 -maxdepth 2 -type d -name ".question" -perm /u+r,g+r,o+r 2>/dev/null | sort`
        FIND_OUTPUT=`cat $USERS_FILE | tr "\n" " " | sort`
        for i in $FIND_OUTPUT
        do
            FIND_OUTPUT2=`find /home/$i/.question/questions/ -maxdepth 1 -mindepth 1 -type f 2>/dev/null | sort`
            OIFS="$IFS"
            IFS=$'\n'
            for j in $FIND_OUTPUT2
            do
                k1=`expr match "$j" '.*/\(.*\)/.*/.*/.*'`
                k2=`expr match "$j" '.*/\([^/]*\)'`
                if [[ $k1 != "" ]] && [[ $k2 != "" ]]
                then
                    printf -- "$k1/$k2\n"
                fi
            done
            IFS="$OIFS"
	done
    fi
    if [[ $# -eq 2 ]]
    then
        user_name=$2
	if [[ "$user_name" =~ "/" || -z "$user_name" || "$user_name" == $'\n' || "$user_name" =~ ^\ +$ ]]
        then
            printf "Invalid user name supplied\n" 1>&2
	    printf "User name cannot have forward slash (/) in it, cannot have only whitespaces and has to have some characters.\n" 1>&2
	    exit $ERROR_INVALID_USER_NAME
        fi
        USER_NAME_MATCHED=`grep -oP "\b$user_name\b" $USERS_FILE`
        if [[ ! $USER_NAME_MATCHED ]]
        then
            printf "The user $user_name is an invalid user\n" 1>&2
            exit $ERROR_INVALID_USER
        fi
        if [ ! -r /home/"$user_name"/.question ]
        then
            printf "No read permission on the /home/$user_name/.question directory\n" 1>&2
            exit $ERROR_NO_READ_PERMISSION
        fi
        if [ ! -d /home/"$user_name"/.question/questions ]
        then
            printf "This user does not have any questions yet.\n" 1>&2
	    exit $ERROR_USER_NO_QUESTIONS
        fi
        OIFS="$IFS"
        IFS=$'\n'
        for i in $(find /home/"$user_name"/.question/questions -maxdepth 1 -mindepth 1 -type f 2>/dev/null | sort -n)
	do
            j1=`expr match "$i" '.*/\(.*\)/.*/.*/.*'`
            j2=`expr match "$i" '.*/\([^/]*\)'`
            if [[ $j1 != "" ]] && [[ $j2 != "" ]]
            then
                printf -- "$j1/$j2\n"
            fi
	done
        IFS="$OIFS"
    fi
fi

########################################## vote #########################################################
ERROR_VOTE_ARGUMENTS=21
ERROR_INVALID_VOTE=22
ERROR_VOTE_INVALID_QUESTION_ID=23
ERROR_VOTE_INVALID_QUESTION=24
ERROR_VOTE_INVALID_ANSWER_ID=25
ERROR_VOTE_INVALID_ANSWER=26
if [ "$1" == "vote" ]
then
    if [[ $# -eq 1 || $# -eq 2 ]]
    then
        printf "Invalid number of arguments supplied for vote option\n" 1>&2
        printf "Usage: question vote up|down question_id [answer_id]\n" 1>&2
	exit $ERROR_VOTE_ARGUMENTS
    fi
    vote=$2
    if ! [[ "$vote" == "up" || "$vote" == "down" ]]
    then
        printf "Invalid vote supplied\n" 1>&2
	printf "The value of vote can either be up or down only\n" 1>&2
	printf "Usage: question vote up|down question_id [answer_id]\n" 1>&2
	exit $ERROR_INVALID_VOTE
    fi
    question_id=$3
    question_id_login=`expr match "$question_id" '\(.*\)/'`
    question_id_name=`expr match "$question_id" '.*/\(.*\)'`
# Add condition to check validity of the login and name part of id and also check
# that a question corresponding to the name part of the id exists.
# After /home/unixtool/data/question/users file gets created, maybe also add code
# to check for a valid user name by running a grep -o on it.
    if [[ "$question_id_login" =~ "/" || "$question_id_name" =~ "/" || -z "$question_id_login" || -z "$question_id_name" || "$question_id_login" == $'\n' || "$question_id_name" == $'\n' || "$question_id_login" =~ ^\ +$ || "$question_id_name" =~ ^\ +$ ]]
    then
        printf "Invalid question_id supplied\n" 1>&2
        printf "A valid question_id is of the form login/name where login and name\n" 1>&2
        printf "should not be empty or only whitespaces or contain a forward slash (/).\n" 1>&2
        exit $ERROR_VOTE_INVALID_QUESTION_ID
    fi
    QUESTION_MATCH_VARIABLE=`grep -oP "\b$question_id_login\b" $USERS_FILE`
    if [[ ! $QUESTION_MATCH_VARIABLE ]]
    then
        printf "The user $question_id_login is an invalid user\n" 1>&2
        exit $ERROR_INVALID_USER
    fi
    if [ ! -r /home/"$question_id_login"/.question ]
    then
        printf "No read permission on the /home/$question_id_login/.question directory\n" 1>&2
        exit $ERROR_NO_READ_PERMISSION
    fi
    if [ ! -e /home/"$question_id_login"/.question/questions/"$question_id_name" ]
    then
        printf "No corresponding question exists for $question_id\n" 1>&2
        exit $ERROR_VOTE_INVALID_QUESTION
    fi
    if [[ $# -eq 3 ]]
    then
        mkdir -p ~/.question/votes/"$question_id_login"
        touch ~/.question/votes/"$question_id"
        chmod 755 ~/.question/votes/"$question_id"
        echo "$vote" >> ~/.question/votes/"$question_id"
    fi
    if [[ $# -eq 4 ]]
    then
        answer_id=$4
        answer_id_login=`expr match "$answer_id" '\(.*\)/'`
        answer_id_name=`expr match "$answer_id" '.*/\(.*\)'`
# Add condition to check validity of the login and name part of id and also check
# that an answer corresponding to the name part of the id exists.
# After /home/unixtool/data/question/users file gets created, maybe also add code
# to check for a valid user name by running a grep -o on it.
        if [[ "$answer_id_login" =~ "/" || "$answer_id_name" =~ "/" || -z "$answer_id_login" || -z "$answer_id_name" || "$answer_id_login" == $'\n' || "$answer_id_name" == $'\n' || "$answer_id_login" =~ ^\ +$ || "$answer_id_name" =~ ^\ +$ ]]
        then
            printf "Invalid answer_id supplied\n" 1>&2
            printf "A valid answer_id is of the form login/name where login and name\n" 1>&2
            printf "should not be empty or only whitespaces or contain a forward slash (/).\n" 1>&2
            exit $ERROR_VOTE_INVALID_ANSWER_ID
        fi
        ANSWER_MATCH_VARIABLE=`grep -oP "\b$answer_id_login\b" $USERS_FILE`
        if [[ ! $ANSWER_MATCH_VARIABLE ]]
        then
            printf "The user $answer_id_login is an invalid user\n" 1>&2
            exit $ERROR_INVALID_USER
        fi
        if [ ! -r /home/"$answer_id_login"/.question ]
        then
            printf "No read permission on the /home/$answer_id_login/.question directory\n" 1>&2
            exit $ERROR_NO_READ_PERMISSION
        fi
        if [ ! -e /home/"$answer_id_login"/.question/answers/"$question_id_login"/"$question_id_name"/"$answer_id_name" ]
        then
            printf "No corresponding answer exists for $answer_id\n" 1>&2
            exit $ERROR_VOTE_INVALID_ANSWER
        fi
	mkdir -p ~/.question/votes/"$question_id_login"
        touch ~/.question/votes/"$question_id"
        chmod 755 ~/.question/votes/"$question_id"
	echo "$vote $answer_id" >> ~/.question/votes/"$question_id"
    fi
fi

########################################### view #######################################################
ERROR_SHOW_ARGUMENTS=27
ERROR_SHOW_INVALID_QUESTION_ID=28
ERROR_SHOW_INVALID_QUESTION=29
if [ "$1" == "view" ]
then
    if [[ $# -eq 1 ]]
    then
        printf "Invalid number of arguments supplied for view option\n" 1>&2
        printf "Usage: question view question_id ...\n" 1>&2
	exit $ERROR_LIST_ARGUMENTS
    fi
    OIFS="$IFS"
    IFS=$'\n'
    for question_id in "$@"
    do
        if [[ "$question_id" == $1 ]]
	then
	    continue
	fi
        question_id_login=`expr match "$question_id" '\(.*\)/'`
        question_id_name=`expr match "$question_id" '.*/\(.*\)'`
# Add condition to check validity of the login and name part of id and also check
# that a question corresponding to the name part of the id exists.
        if [[ "$question_id_login" =~ "/" || "$question_id_name" =~ "/" || -z "$question_id_login" || -z "$question_id_name" || "$question_id_login" == $'\n' || "$question_id_name" == $'\n' || "$question_id_login" =~ ^\ +$ || "$question_id_name" =~ ^\ +$ ]]
        then
            printf "Invalid question_id supplied\n" 1>&2
	    printf "A valid question_id is of the form login/name where login and name\n" 1>&2
	    printf "should not be empty or only whitespaces or contain a forward slash (/).\n" 1>&2
	    exit $ERROR_SHOW_INVALID_QUESTION_ID
        fi
        MATCH_VARIABLE=`grep -oP "\b$question_id_login\b" $USERS_FILE`
        if [[ ! $MATCH_VARIABLE ]]
        then
            printf "The user $question_id_login is an invalid user\n" 1>&2
            exit $ERROR_INVALID_USER
        fi
        if [ ! -r /home/"$question_id_login"/.question ]
        then
            printf "No read permission on the /home/$question_id_login/.question directory\n" 1>&2
            exit $ERROR_NO_READ_PERMISSION
        fi
        if [ ! -e /home/"$question_id_login"/.question/questions/"$question_id_name" ]
        then
            printf "No corresponding question exists for $question_id\n" 1>&2
            exit $ERROR_SHOW_INVALID_QUESTION
        fi
	question_ups=0
	question_downs=0
        for i in `cat $USERS_FILE`
        do
            if [ -e /home/"$i"/.question/votes/"$question_id" -a -r /home/"$i"/.question/votes/"$question_id" ]
	    then
                last_question_vote=$(grep -P "(^up$|^down$)" /home/"$i"/.question/votes/"$question_id" | tail -n 1)
	        ((question_ups+=`echo $last_question_vote | grep -Pc "^up$"`))
	        ((question_downs+=`echo $last_question_vote | grep -Pc "^down$"`))
	    fi
        done
	question_votes=$[$question_ups-$question_downs]
	printf -- "$question_votes\n"
        if [ ! -r /home/"$question_id_login"/.question/questions/"$question_id_name" ]
        then
            printf "No read permission on the /home/$question_id_login/.question/questions/$question_id_name file\n" 1>&2
            exit $ERROR_NO_READ_PERMISSION
        fi
	question=`cat /home/"$question_id_login"/.question/questions/"$question_id_name"`
	printf -- "$question\n"
        for j in `cat $USERS_FILE`
        do
            if [ -d /home/"$j"/.question/answers/"$question_id" -a -r /home/"$j"/.question/answers/"$question_id" ]
            then
                for answer_name in `ls -1 /home/"$j"/.question/answers/"$question_id"`
	        do
	            printf "====\n"
	            answer_ups=0
	            answer_downs=0
	            for k in `cat $USERS_FILE`
                    do
                        if [ -e /home/"$k"/.question/votes/"$question_id" -a -r /home/"$k"/.question/votes/"$question_id" ]
	                then
                            last_answer_vote=$(grep -P "(^up $j/$answer_name|^down $j/$answer_name)" /home/"$k"/.question/votes/"$question_id" | tail -n 1)
	                    ((answer_ups+=`echo $last_answer_vote | grep -Pc "^up $j/$answer_name"`))
	                    ((answer_downs+=`echo $last_answer_vote | grep -Pc "^down $j/$answer_name"`))
	                fi
                    done
                    answer_votes=$[$answer_ups-$answer_downs]
	            printf -- "$answer_votes\n"
                    if [ ! -r /home/"$j"/.question/answers/"$question_id"/"$answer_name" ]
                    then
                        printf "No read permission on the /home/$j/.question/answers/$question_id/$answer_name file\n" 1>&2
                        exit $ERROR_NO_READ_PERMISSION
                    fi
	            answer=`cat /home/"$j"/.question/answers/"$question_id"/"$answer_name"`
                    printf -- "$answer $j/$answer_name\n"
	        done
            fi
        done
#       printf "=======================================================================\n"
# The above line can be uncommented to separate each question and its answers and the votes from the next question.
    done
    IFS="$OIFS"
fi

exit 0
