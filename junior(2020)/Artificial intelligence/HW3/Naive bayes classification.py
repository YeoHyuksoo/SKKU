import json
import numpy as np
import re
import operator
import random
from math import *

def load(path):
    review = []
    for line in open(path, 'r'):
        row = json.loads(line)
        review.append(row)

    return np.array(review)

def preprocessing(sentence):
    letters = re.sub('[^a-zA-Z]', ' ', sentence)
    words_list = letters.lower().split()

    return words_list

json_data = load("yelp_academic_dataset_review.json")
json_text = open("data_filtered.json", 'w')

data_class = []
words_dic = {}

for data in json_data:
    vote_data = data["votes"]
    votes = vote_data["funny"] + vote_data["useful"] + vote_data["cool"]
    if votes >= 3 and votes <= 10:
        text = data["text"]
        text = preprocessing(text)
        json_text.write(str(text)+'\n')
        for word in text:
            if word in words_dic:
                words_dic[word] += 1
            else:
                words_dic[word] = 1
        content = ""
        if vote_data["funny"] > 0:
            content += "F"
        if vote_data["useful"] > 0:
            content += "U"
        if vote_data["cool"] > 0:
            content += "C"
        if data["stars"] > 3.5:
            content += "P"
        data_class.append(content)

json_text.close()
words_dic = sorted(words_dic.items(), key=operator.itemgetter(1))
words_dic.reverse()

words_dict = {}
num = 0
for key, value in words_dic:
    words_dict[key] = value
    num += 1
    if num == 5000:
        break

del words_dic

json_text = open("data_filtered.json", 'r', encoding='utf-8')

bag = {}

reviews_bag = open("reviews_bag.json", 'w')

line = json_text.readline()
cnt = 0
while line:
    bag.clear()
    line = line[1:len(line) - 2]
    line = line.split(", ")
    for word in line:
        w = word[1:len(word)-1]
        if w in words_dict:
            if w in bag:
                bag[w] += 1
            else:
                bag[w] = 1
    bag["fucp"] = data_class[cnt]
    reviews_bag.write(str(bag)+'\n')
    cnt += 1
    line = json_text.readline()

del data_class
json_text.close()
reviews_bag.close()

training_set = []
test_set = []

random_num = random.randint(1, 252862)
for i in range(0, 25600):
    while random_num in training_set:
        random_num = random.randint(1, 252862)
    training_set.append(random_num)

for i in range(0, 8000):
    while random_num in training_set or random_num in test_set:
        random_num = random.randint(1, 252862)
    test_set.append(random_num)

test_set.sort()
reviews_bag = open("reviews_bag.json", 'r', encoding='utf-8')

training_n = 50
class_label = ""
funny_dict = {}
useful_dict = {}
cool_dict = {}
positive_dict = {}
not_funny_dict = {}
not_useful_dict = {}
not_cool_dict = {}
not_positive_dict = {}
unique_words = []

for i in range(0, 10, 1):
    sub_trainset = training_set[:training_n]
    review = reviews_bag.readline()
    num = 1
    funny_data = 0
    useful_data = 0
    cool_data = 0
    positive_data = 0
    funny_words = 0
    not_funny_words = 0
    useful_words = 0
    not_useful_words = 0
    cool_words = 0
    not_cool_words = 0
    positive_words = 0
    not_positive_words = 0
    while review:
        if num in sub_trainset:
            r = review[1:len(review)-2]
            r = r.split(", ")
            class_label = str(r[len(r)-1])
            del r[len(r)-1]
            if 'F' in class_label:
                funny_data += 1
            if 'U' in class_label:
                useful_data += 1
            if 'C' in class_label:
                cool_data += 1
            if 'P' in class_label:
                positive_data += 1
            words = 0
            for word in r:
                w = word.split(": ")
                n = int(w[1])
                w = w[0][1:len(w[0])-1]
                if w in words_dict:
                    words += 1
                    if 'F' in class_label:
                        if w not in funny_dict:
                            funny_dict[w] = 1
                        else:
                            funny_dict[w] += 1
                    else:
                        if w not in not_funny_dict:
                            not_funny_dict[w] = 1
                        else:
                            not_funny_dict[w] += 1
                    if 'U' in class_label:
                        if w not in useful_dict:
                            useful_dict[w] = 1
                        else:
                            useful_dict[w] += 1
                    else:
                        if w not in not_useful_dict:
                            not_useful_dict[w] = 1
                        else:
                            not_useful_dict[w] += 1
                    if 'C' in class_label:
                        if w not in cool_dict:
                            cool_dict[w] = 1
                        else:
                            cool_dict[w] += 1
                    else:
                        if w not in not_cool_dict:
                            not_cool_dict[w] = 1
                        else:
                            not_cool_dict[w] += 1
                    if 'P' in class_label:
                        if w not in positive_dict:
                            positive_dict[w] = 1
                        else:
                            positive_dict[w] += 1
                    else:
                        if w not in not_positive_dict:
                            not_positive_dict[w] = 1
                        else:
                            not_positive_dict[w] += 1
                    if w not in unique_words:
                        unique_words.append(w)
            if 'F' in class_label:
                funny_words += words
            else:
                not_funny_words += words
            if 'U' in class_label:
                useful_words += words
            else:
                not_useful_words += words
            if 'C' in class_label:
                cool_words += words
            else:
                not_cool_words += words
            if 'P' in class_label:
                positive_words += words
            else:
                not_positive_words += words
        review = reviews_bag.readline()
        num += 1

    reviews_bag.seek(0)
    prev = 0
    correct_funny = 0
    correct_useful = 0
    correct_cool = 0
    correct_positive = 0

    """funny_cnt = 0
    useful_cnt = 0
    cool_cnt = 0
    positive_cnt = 0
    correct_not_funny = 0
    correct_not_useful = 0
    correct_not_cool = 0
    correct_not_positive = 0"""

    for j in range(0, 8000, 1):
        prob_funny = 0.0
        prob_not_funny = 0.0
        prob_useful = 0.0
        prob_not_useful = 0.0
        prob_cool = 0.0
        prob_not_cool = 0.0
        prob_positive = 0.0
        prob_not_positive = 0.0
        while test_set[j]-prev-1 != 0:
            reviews_bag.readline()
            prev += 1
        review = reviews_bag.readline()
        r = review[1:len(review) - 2]
        r = r.split(", ")
        class_label = str(r[len(r) - 1])
        del r[len(r) - 1]
        for word in r:
            w = word.split(": ")
            n = int(w[1])
            w = w[0][1:len(w[0]) - 1]
            if w in unique_words:
                if w not in funny_dict:
                    prob_funny += log10(1 / (funny_words + len(unique_words)))
                else:
                    prob_funny += log10((funny_dict[w]+1) / (funny_words + len(unique_words)))
                if w not in not_funny_dict:
                    prob_not_funny += log10(1 / (not_funny_words + len(unique_words)))
                else:
                    prob_not_funny += log10((not_funny_dict[w]+1) / (not_funny_words + len(unique_words)))
                if w not in useful_dict:
                    prob_useful += log10(1 / (useful_words + len(unique_words)))
                else:
                    prob_useful += log10((useful_dict[w]+1) / (useful_words + len(unique_words)))
                if w not in not_useful_dict:
                    prob_not_useful += log10(1 / (not_useful_words + len(unique_words)))
                else:
                    prob_not_useful += log10((not_useful_dict[w]+1) / (not_useful_words + len(unique_words)))
                if w not in cool_dict:
                    prob_cool += log10(1 / (cool_words + len(unique_words)))
                else:
                    prob_cool += log10((cool_dict[w]+1) / (cool_words + len(unique_words)))
                if w not in not_cool_dict:
                    prob_not_cool += log10(1 / (not_cool_words + len(unique_words)))
                else:
                    prob_not_cool += log10((not_cool_dict[w]+1) / (not_cool_words + len(unique_words)))
                if w not in positive_dict:
                    prob_positive += log10(1 / (positive_words + len(unique_words)))
                else:
                    prob_positive += log10((positive_dict[w]+1) / (positive_words + len(unique_words)))
                if w not in not_positive_dict:
                    prob_not_positive += log10(1 / (not_positive_words + len(unique_words)))
                else:
                    prob_not_positive += log10((not_positive_dict[w]+1) / (not_positive_words + len(unique_words)))

        prev = test_set[j]
        if funny_data == 0:
            prob_funny = -100000
            prob_not_funny += log10(1 - (funny_data / training_n))
        elif funny_data == training_n:
            prob_funny += log10(funny_data / training_n)
            prob_not_funny = -100000
        else:
            prob_funny += log10(funny_data / training_n)
            prob_not_funny += log10(1 - (funny_data / training_n))
        if useful_data == 0:
            prob_useful = -100000
            prob_not_useful += log10(1 - (useful_data / training_n))
        elif useful_data == training_n:
            prob_useful += log10(useful_data / training_n)
            prob_not_useful = -100000
        else:
            prob_useful += log10(useful_data / training_n)
            prob_not_useful += log10(1 - (useful_data / training_n))
        if cool_data == 0:
            prob_cool = -100000
            prob_not_cool += log10(1 - (cool_data / training_n))
        elif cool_data == training_n:
            prob_cool += log10(cool_data / training_n)
            prob_not_cool = -100000
        else:
            prob_cool += log10(cool_data / training_n)
            prob_not_cool += log10(1 - (cool_data / training_n))
        if positive_data == 0:
            prob_positive = -100000
            prob_not_positive += log10(1 - (positive_data / training_n))
        elif positive_data == training_n:
            prob_positive += log10(positive_data / training_n)
            prob_not_positive = -100000
        else:
            prob_positive += log10(positive_data / training_n)
            prob_not_positive += log10(1 - (positive_data / training_n))

        if prob_funny > prob_not_funny:
            if 'F' in class_label:
                # funny_cnt += 1
                correct_funny += 1
        else:
            if 'F' not in class_label:
                correct_funny += 1
                # correct_not_funny += 1
        if prob_useful > prob_not_useful:
            if 'U' in class_label:
                # useful_cnt += 1
                correct_useful += 1
        else:
            if 'U' not in class_label:
                correct_useful += 1
                # correct_not_useful += 1
        if prob_cool > prob_not_cool:
            if 'C' in class_label:
                # cool_cnt += 1
                correct_cool += 1
        else:
            if 'C' not in class_label:
                correct_cool += 1
                # correct_not_cool += 1
        if prob_positive > prob_not_positive:
            if 'P' in class_label:
                # positive_cnt += 1
                correct_positive += 1
        else:
            if 'P' not in class_label:
                correct_positive += 1
                # correct_not_positive += 1
    """print(100 - correct_funny*100 / 8000)
    print(100 - correct_useful*100 / 8000)
    print(100 - correct_cool*100 / 8000)
    print(100 - correct_positive*100 / 8000)
    print()"""
    """print("baseline model")
    if funny_cnt > 4000:
        print(100 - (correct_funny - correct_not_funny)*100 / 8000)
    else:
        print(100 - (correct_not_funny*100 / 8000))
    if useful_cnt > 4000:
        print(100 - (correct_useful - correct_not_useful)*100 / 8000)
    else:
        print(100 - (correct_not_useful*100 / 8000))
    if cool_cnt > 4000:
        print(100 - (correct_cool - correct_not_cool)*100 / 8000)
    else:
        print(100 - (correct_not_cool*100 / 8000))
    if positive_cnt > 4000:
        print(100 - (correct_positive - correct_not_positive)*100 / 8000)
    else:
        print(100 - (correct_not_positive*100 / 8000))"""
    reviews_bag.seek(0)
    training_n *= 2
    funny_dict.clear()
    useful_dict.clear()
    cool_dict.clear()
    positive_dict.clear()
    not_funny_dict.clear()
    not_useful_dict.clear()
    not_cool_dict.clear()
    not_positive_dict.clear()
    unique_words.clear()

reviews_bag.close()