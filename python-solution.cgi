#!/usr/bin/env python


import cgi
import cgitb; cgitb.enable()
import traceback
import os
import os.path
import sys
import re
import math
import glob
import time
import subprocess
import random
import importlib
import operator
import collections
import urllib

def main():
    startHomePage()
    addContainer()
    addHome()
    startList()
    users_file = '/home/unixtool/data/question/users'
    sys.stdout.flush()
    getUsers(users_file)
    endList()
    addQuestion()
    endHomePage()

def getUsers(users_file):
    """The user names get read from the users file here"""
    user_names = tuple(open(users_file, 'r'));
    for user_name in user_names:
        clean_user_name = user_name.rstrip("\n")
        listQuestions(clean_user_name)

def listQuestions(clean_user_name):
    """The questions for the user get read here"""
    DEVNULL = open(os.devnull, 'wb')
    question_names_pipe = subprocess.Popen(['ls', '-1', "/home/"+clean_user_name+"/.question/questions"], stdout=subprocess.PIPE, stderr=DEVNULL)
    question_names = question_names_pipe.stdout.read().split('\n')
    question_names.pop()
    question_names.sort()
    for question_name in question_names:
        clean_question_name = question_name.rstrip("\n")
        if (clean_user_name != "" and clean_question_name != ""):
            generateQuestionList(clean_user_name, clean_question_name)

def viewQuestion(clean_user_name, clean_question_name):
    startHomePage()
    addContainer()
    addHome()
    getQuestionAnswers(clean_user_name, clean_question_name)
    addAnswer(clean_user_name, clean_question_name)
    endHomePage()

def startHomePage():
    print("Content-type: text/html\n\n")
    print("<html>")
    print("<Title>Nikita: Assignment4</Title>")
    print("<body style=\"background-color: #57068c\">")

def addContainer():
    print("<div style=\"border: 4px solid black; width: 90%; position: absolute; margin: 4% 6% 5% 4%; background-color: #99CCFF;\">")

def addHome():
    print("<div style=\"font-size: 1.5em; line-height: 1.7em; margin-left: 12%;\">")
    print("<b>")
    print("<u>")
    print("<a href=\"http://cims.nyu.edu/~nn899/cgi-bin/question.cgi\"; style=\"color: black\";>")
    print("<font color=\"#57068c\">")
    print("Home")
    print("</font>")
    print("</a>")
    print("</u>")
    print("</b>")
    print("</div>")

def startList():
    print("<ul style=\"list-style-type: disc; margin-left: 4%\">")

def endList():
    print("</ul>")

def getQuestionAnswers(clean_user_name, clean_question_name):
    print("<br/>")
    DEVNULL = open(os.devnull, 'wb')
    question_pipe = subprocess.Popen(['/home/nn899/bin/question', 'view', clean_user_name+"/"+clean_question_name], stdout=subprocess.PIPE, stderr=DEVNULL)
    question = question_pipe.stdout.read().split("====\n")
    print("<div style=\"font-size: 1.5em; line-height: 1.7em; margin-left: 8%; margin-right: 8%;\">")
    print("<b>")
    if len(question) == 1:
        question_only = question[0].rstrip("\n").split("\n", 1)
        if (len(question_only) == 1):
            question_only.append("")
        print("<div style=\"display: inline-block; width: 60%; margin-left: 5%; word-wrap: break-word;\">")
        print("<pre style=\"font-size: 1.5em; line-height:1.7em; white-space: pre-wrap; word-wrap: break-word;\">")
        print(cgi.escape(question_only[1], True))
        print("</pre>")
        print("</div>")
        print("</b>")
        print("<br/>")
        if not question_only[0]:
            question_only[0] = 0
        question_only[0] = int(question_only[0])
        print("<div style=\"display: inline-block; width: 60%; margin-left: 5%;\">")
        print("</div>")
        print("<div style=\"display: inline-block; width: 10%;\">")
        if (question_only[0] > 0):
            print("%+d") % question_only[0]
        else:
            print(question_only[0])
        print("</div>")
        print("<div style=\"display: inline-block; width: 10%;\">")
        print("<form action=\"question.cgi\" method=\"GET\">")
        print("<input type=\"hidden\" name=\"user_name\" value=\"%s\">") %(clean_user_name)
        print("<input type=\"hidden\" name=\"question_name\" value=\"%s\">") %(urllib.quote_plus(clean_question_name))
        print("<button type=\"submit\" name=\"vote\" value=\"up\" onclick=\"javascript:window.location='question.cgi';\">Up</button>")
        print("</form>")
        print("</div>")
        print("<div style=\"display: inline-block; width: 10%;\">")
        print("<form action=\"question.cgi\" method=\"GET\">")
        print("<input type=\"hidden\" name=\"user_name\" value=\"%s\">") %(clean_user_name)
        print("<input type=\"hidden\" name=\"question_name\" value=\"%s\">") %(urllib.quote_plus(clean_question_name))
        print("<button type=\"submit\" name=\"vote\" value=\"down\" onclick=\"javascript:window.location='question.cgi';\">Down</button>")
        print("</form>")
        print("</div>")
        print("<br/>")
        print("<hr style=\"border: 0.1em solid black; width: 94%;\">")
    if len(question) >= 2:
        question_only = question[0].rstrip("\n").split("\n", 1)
        if (len(question_only) == 1):
            question_only.append("")
        print("<div style=\"display: inline-block; width: 60%; margin-left: 5%; word-wrap: break-word;\">")
        print("<pre style=\"font-size: 1.5em; line-height:1.7em; white-space: pre-wrap; word-wrap: break-word;\">")
        print(cgi.escape(question_only[1], True))
        print("</pre>")
        print("</div>")
        print("</b>")
        print("<br/>")
        if not question_only[0]:
            question_only[0] = 0
        question_only[0] = int(question_only[0])
        print("<div style=\"display: inline-block; width: 60%; margin-left: 5%\">")
        print("</div>")
        print("<div style=\"display: inline-block; width: 10%;\">")
        if (question_only[0] > 0):
            print("%+d") % question_only[0]
        else:
            print(question_only[0])
        print("</div>")
        print("<div style=\"display: inline-block; width: 10%;\">")
        print("<form action=\"question.cgi\" method=\"GET\">")
        print("<input type=\"hidden\" name=\"user_name\" value=\"%s\">") %(clean_user_name)
        print("<input type=\"hidden\" name=\"question_name\" value=\"%s\">") %(urllib.quote_plus(clean_question_name))
        print("<button type=\"submit\" name=\"vote\" value=\"up\" onclick=\"javascript:window.location='question.cgi';\">Up</button>")
        print("</form>")
        print("</div>")
        print("<div style=\"display: inline-block; width: 10%;\">")
        print("<form action=\"question.cgi\" method=\"GET\">")
        print("<input type=\"hidden\" name=\"user_name\" value=\"%s\">") %(clean_user_name)
        print("<input type=\"hidden\" name=\"question_name\" value=\"%s\">") %(urllib.quote_plus(clean_question_name))
        print("<button type=\"submit\" name=\"vote\" value=\"down\" onclick=\"javascript:window.location='question.cgi';\">Down</button>")
        print("</form>")
        print("</div>")
        print("<br/>")
        print("<hr style=\"border: 0.1em solid black; width: 94%;\">")
        answer_only = question[1:len(question)]
        j = 0
        while (j < len(answer_only)):
            answer_only[j] = answer_only[j].lstrip("\n").rstrip("\n").split("\n", 1)
            if (len(answer_only[j]) == 1):
                #answer_only[j].append("")
                j = j + 1
                continue
            if not answer_only[j][0]:
                answer_only[j][0] = 0
            answer_only[j][0] = int(answer_only[j][0])
            j = j + 1
        answer_tuple = tuple(tuple(x) for x in answer_only)
        if len(answer_tuple[len(answer_tuple) - 1]) == 1:
            answer_tuple = answer_tuple[0:(len(answer_tuple) - 1)]
        answer_dictionary = dict((y,x) for x,y in answer_tuple)
        answers = collections.OrderedDict(sorted(answer_dictionary.items(), key = operator.itemgetter(1), reverse = True))
        print("<br/>")
        i = 0
        while (i < len(answers)):
            m = re.match("^(.*)\s+([^/\s]+/[^/]*)$", answers.items()[i][0], re.DOTALL)
            if m:
                print("<div style=\"display: inline-block; width: 60%; margin-left: 5%; word-wrap: break-word;\">")
                print("<pre style=\"font-size: 1.5em; line-height:1.7em; white-space: pre-wrap; word-wrap: break-word;\">")
                print(cgi.escape(m.group(1), True))
                print("</pre>")
                print("</div>")
            else:
                print("<div style=\"display: inline-block; width: 60%;\">")
                print("</div>")
            if m.group(2):
                answer_id = m.group(2)
            print("<div style=\"display: inline-block; width: 10%;\">")
            if (answers.items()[i][1] > 0):
                print("%+d") % answers.items()[i][1]
            else:
                print(answers.items()[i][1])
            print("</div>")
            print("<div style=\"display: inline-block; width: 10%;\">")
            print("<form action=\"question.cgi\" method=\"GET\">")
            print("<input type=\"hidden\" name=\"user_name\" value=\"%s\">") %(clean_user_name)
            print("<input type=\"hidden\" name=\"question_name\" value=\"%s\">") %(urllib.quote_plus(clean_question_name))
            print("<input type=\"hidden\" name=\"answer_id\" value=\"%s\">") %(urllib.quote_plus(answer_id))
            print("<button type=\"submit\" name=\"vote\" value=\"up\" onclick=\"javascript:window.location='question.cgi';\">Up</button>")
            print("</form>")
            print("</div>")
            print("<div style=\"display: inline-block; width: 10%;\">")
            print("<form action=\"question.cgi\" method=\"GET\">")
            print("<input type=\"hidden\" name=\"user_name\" value=\"%s\">") %(clean_user_name)
            print("<input type=\"hidden\" name=\"question_name\" value=\"%s\">") %(urllib.quote_plus(clean_question_name))
            print("<input type=\"hidden\" name=\"answer_id\" value=\"%s\">") %(urllib.quote_plus(answer_id))
            print("<button type=\"submit\" name=\"vote\" value=\"down\" onclick=\"javascript:window.location='question.cgi';\">Down</button>")
            print("</form>")
            print("</div>")
            print("<br/>")
            print("<hr style=\"border: 0.05em solid black; width: 94%;\">")
            i = i + 1
    print("<br/>")
    print("</div>")

def addQuestion():
    print("<div style=\"font-size: 1.5em; line-height: 1.7em; margin-left: 12%;\">")
    print("<b>")
    print("<u>")
    print("<a href=\"http://cims.nyu.edu/~nn899/cgi-bin/question.cgi?add_question=true\"; style=\"color: black\";>")
    print("Add question")
    print("</a>")
    print("</u>")
    print("</b>")
    print("</div>")
    print("<br/>")

def addAnswer(clean_user_name, clean_question_name):
    print("<div style=\"font-size: 1.5em; line-height: 1.7em; margin-left: 12%;\">")
    print("<b>")
    print("<u>")
    print("<a href=\"http://cims.nyu.edu/~nn899/cgi-bin/question.cgi?add_answer=true&user_name=%s&question_name=%s\"; style=\"color: black\";>") %(urllib.quote_plus(clean_user_name), urllib.quote_plus(clean_question_name))
    print("Add answer")
    print("</a>")
    print("</u>")
    print("</b>")
    print("</div>")
    print("<br/>")

def endHomePage():
    print("</div>")
    print("</body>")
    print("</html>")

def generateQuestionList(clean_user_name, clean_question_name):
    print("<li style=\"font-size: 1.5em; line-height: 1.7em; margin-left: 6%;\">")
    print("<u>")
    print("<a href=\"http://cims.nyu.edu/~nn899/cgi-bin/question.cgi?user_name=%s&question_name=%s\"; style=\"color: black\";>") %(urllib.quote_plus(clean_user_name), urllib.quote_plus(clean_question_name))
    print(clean_user_name+"/"+cgi.escape(clean_question_name, True))
    print("</a>")
    print("</u>")
    print("<br/>")
    print("</li>")

def generateQuestionName():
    i = 1
    j = 'q'
    temp_question_name = j + `i`
    existing_questions = os.listdir("/home/nn899/.question/questions")
    while (temp_question_name in existing_questions):
        i = i + 1
        temp_question_name = j + `i`
    return temp_question_name

def generateAnswerName(clean_user_name, clean_question_name):
    i = 1
    j = 'a'
    temp_answer_name = j + `i`
    if (os.path.isdir("/home/nn899/.question/answers/"+clean_user_name+"/"+clean_question_name)):
        existing_answers = os.listdir("/home/nn899/.question/answers/"+clean_user_name+"/"+clean_question_name)
        while (temp_answer_name in existing_answers):
            i = i + 1
            temp_answer_name = j + `i`
    return temp_answer_name

def createQuestion(unique_question_name):
    startHomePage()
    addContainer()
    addHome()
    print("<br/>")
    print("<div style=\"font-size: 1.5em; line-height: 1.7em; margin-left: 12%;\">")
    print("What is your question?")
    print("</div>")
    print("<div style=\"font-size: 1.5em; line-height: 1.7em; margin-left: 12%;\">")
    print("<form action=\"question.cgi\" method=\"POST\">")
    print("<textarea name=\"question\" style=\"width: 91%; height: 10em; font-size: 1.1em; line-height: 1em;\" required></textarea>")
    print("<br/>")
    print("<input type=\"hidden\" name=\"question_name\" value=\"%s\">") %(unique_question_name)
    print("<input type=\"submit\" value=\"Submit\">")
    print("<button type=\"reset\" value=\"Reset\">Reset</button>")
    print("<button type=\"reset\" onclick=\"javascript:window.location='question.cgi';\">Cancel</button>")
    print("</form>")
    print("</div>")
    endHomePage()

def createAnswer(clean_user_name, clean_question_name, unique_answer_name):
    startHomePage()
    addContainer()
    addHome()
    print("<br/>")
    print("<div style=\"font-size: 1.5em; line-height: 1.7em; margin-left: 12%;\">")
    print("What is your answer?")
    print("</div>")
    print("<div style=\"font-size: 1.5em; line-height: 1.7em; margin-left: 12%;\">")
    print("<form action=\"question.cgi\" method=\"POST\">")
    print("<textarea name=\"answer\" style=\"width: 91%; height: 10em; font-size: 1.1em; line-height: 1em;\" required></textarea>")
    print("<br/>")
    print("<input type=\"hidden\" name=\"user_name\" value=\"%s\">") %(clean_user_name)
    print("<input type=\"hidden\" name=\"question_name\" value=\"%s\">") %(urllib.quote_plus(clean_question_name))
    print("<input type=\"hidden\" name=\"answer_name\" value=\"%s\">") %(unique_answer_name)
    print("<input type=\"submit\" value=\"Submit\">")
    print("<button type=\"reset\" value=\"Reset\">Reset</button>")
    print("<button type=\"reset\" onclick=\"javascript:window.location='question.cgi?user_name=%s&question_name=%s';\">Cancel</button>") %(clean_user_name, urllib.quote_plus(clean_question_name))
    print("</form>")
    print("</div>")
    endHomePage()

try:
    form = cgi.FieldStorage()
    if (("user_name" not in form) and ("question_name" not in form) and ("add_question" not in form) and ("add_answer" not in form) and ("answer_name" not in form)):
        main()
    if (("user_name" in form) and ("question_name" in form) and ("add_answer" not in form) and ("answer_name" not in form) and ("vote" not in form)):
        clean_user_name = form["user_name"].value
        clean_question_name = urllib.unquote_plus(form["question_name"].value)
        viewQuestion(clean_user_name, clean_question_name)
    if ("add_question" in form):
        unique_question_name = generateQuestionName()
        createQuestion(unique_question_name)
    if ("add_answer" in form):
        clean_user_name = form["user_name"].value
        clean_question_name = urllib.unquote_plus(form["question_name"].value)
        unique_answer_name = generateAnswerName(clean_user_name, clean_question_name)
        createAnswer(clean_user_name, clean_question_name, unique_answer_name)
    if (("question_name" in form) and ("question" in form)):
        question_name = form["question_name"].value
        clean_question = form["question"].value
        DEVNULL = open(os.devnull, 'wb')
        question_pipe = subprocess.Popen(['/home/nn899/bin/question', 'create', question_name, clean_question], stdout=subprocess.PIPE, stderr=DEVNULL)
        main()
    if (("user_name" in form) and ("question_name" in form) and ("answer" in form) and ("answer_name" in form)):
        answer_name = form["answer_name"].value
        clean_answer = form["answer"].value
        clean_user_name = form["user_name"].value
        clean_question_name = urllib.unquote_plus(form["question_name"].value)
        DEVNULL = open(os.devnull, 'wb')
        answer_pipe = subprocess.Popen(['/home/nn899/bin/question', 'answer', clean_user_name+"/"+clean_question_name, answer_name, clean_answer], stdout=subprocess.PIPE, stderr=DEVNULL)
        viewQuestion(clean_user_name, clean_question_name)
    if (("user_name" in form) and ("question_name" in form) and ("vote" in form)):
        user_name = form["user_name"].value
        question_name = urllib.unquote_plus(form["question_name"].value)
        vote = form["vote"].value
        DEVNULL = open(os.devnull, 'wb')
        if ("answer_id" in form):
            answer_id = urllib.unquote_plus(form["answer_id"].value)
            vote_pipe = subprocess.Popen(['/home/nn899/bin/question', 'vote', vote, user_name+"/"+question_name, answer_id], stdout=subprocess.PIPE, stderr=DEVNULL)
        else:
            vote_pipe = subprocess.Popen(['/home/nn899/bin/question', 'vote', vote, user_name+"/"+question_name], stdout=subprocess.PIPE, stderr=DEVNULL)
        viewQuestion(user_name, question_name)

except:
    cgi.print_exception()
