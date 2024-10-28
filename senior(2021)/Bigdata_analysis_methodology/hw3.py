import json
import numpy as np
from math import *
import collections

def load(path):
    review = []
    for line in open(path, 'r'):
        row = json.loads(line)
        review.append(row)

    return np.array(review)

json_data = load("yelp_academic_dataset_review.json")

userid_list = []
businessid_list = []
for data in json_data:
    userid_list.append(data['user_id'])
    businessid_list.append(data['business_id'])

common_userid = collections.Counter(userid_list).most_common(100)
common_businessid = collections.Counter(businessid_list).most_common(50)

print()
print("Collect 100 most common user_id :")
print(common_userid)
print("Collect 50 most common business_id :")
print(common_businessid)
print()

common_userid_list = []
for userid in common_userid:
    common_userid_list.append(userid[0])
common_businessid_list = []
for businessid in common_businessid:
    common_businessid_list.append(businessid[0])

matrix = np.zeros(shape=(100, 50))
matrix.fill(0)
cnt = 0

for data in json_data:
    if data['user_id'] in common_userid_list and data['business_id'] in common_businessid_list:
        if matrix[common_userid_list.index(data['user_id'])][common_businessid_list.index(data['business_id'])] == 0:
            matrix[common_userid_list.index(data['user_id'])][common_businessid_list.index(data['business_id'])] = data['stars']
            cnt+=1

print("<rating matrix> 100 x 50")
print(matrix)
print()

test_matrix = np.zeros(shape=(100, 50))
test_matrix.fill(0)

rand_number = [i for i in range(0, 5000)]
np.random.shuffle(rand_number)

rand_cnt = 0
i = 0
while i < int(cnt*0.1):
    while matrix[int(rand_number[rand_cnt]/50)][rand_number[rand_cnt]%50] == 0.0:
        rand_cnt+=1
    if sum(matrix[int(rand_number[rand_cnt]/50)]) - matrix[int(rand_number[rand_cnt]/50)][rand_number[rand_cnt]%50] == 0:
        rand_cnt+=1
        continue
    elif sum(matrix[:][rand_number[rand_cnt]%50]) - matrix[int(rand_number[rand_cnt]/50)][rand_number[rand_cnt]%50] == 0:
        rand_cnt += 1
        continue
    test_matrix[int(rand_number[rand_cnt] / 50)][rand_number[rand_cnt] % 50] = matrix[int(rand_number[rand_cnt] / 50)][rand_number[rand_cnt] % 50]
    matrix[int(rand_number[rand_cnt] / 50)][rand_number[rand_cnt] % 50] = 0
    i+=1

print("training data")
print(matrix)
print()
print("test data")
print(test_matrix)
print()

from numpy.linalg import svd
U, Sigma, Vt = svd(matrix)

mse_list = []

class MF():
    def __init__(self, R, test_data, K, alpha, beta, iterations):
        self.R = R
        self.num_users, self.num_items = R.shape
        self.K = K
        self.alpha = alpha
        self.beta = beta
        self.iterations = iterations

        self.test_data = test_data

    def train(self):
        self.P = np.random.normal(scale=1./self.K, size=(self.num_users, self.K))
        self.Q = np.random.normal(scale=1./self.K, size=(self.num_items, self.K))

        self.b_u = np.zeros(self.num_users)
        self.b_i = np.zeros(self.num_items)
        self.b = np.mean(self.R[np.where(self.R != 0)])

        self.samples = [
            (i, j, self.R[i, j])
            for i in range(self.num_users)
            for j in range(self.num_items)
            if self.R[i, j] > 0
        ]

        training_process = []
        for i in range(self.iterations):
            np.random.shuffle(self.samples)
            self.sgd()
            mse = self.mse()
            training_process.append((i, mse))
            print("iteration: %d ; error = %.4f" % (i+1, mse))
            mse_list.append(mse)

        self.R = self.test_data
        self.b = np.mean(self.R[np.where(self.R != 0)])

        self.samples = [
            (i, j, self.R[i, j])
            for i in range(self.num_users)
            for j in range(self.num_items)
            if self.R[i, j] > 0
        ]

        np.random.shuffle(self.samples)
        self.sgd()
        mse = self.mse()
        print("Final MSEs on test data = %.4f" % mse)

        return training_process

    def mse(self):
        xs, ys = self.R.nonzero()
        predicted = self.full_matrix()
        error = 0.0
        for x, y in zip(xs, ys):
            error += pow(self.R[x, y] - predicted[x, y], 2)
        return np.sqrt(error)

    def sgd(self):
        for i, j, r in self.samples:
            prediction = self.get_rating(i, j)
            e = (r - prediction)

            self.b_u[i] += self.alpha * (e - self.beta * self.b_u[i])
            self.b_i[j] += self.alpha * (e - self.beta * self.b_i[j])

            self.P[i, :] += self.alpha * (e * self.Q[j, :] - self.beta * self.P[i, :])
            self.Q[j, :] += self.alpha * (e * self.P[i, :] - self.beta * self.Q[j, :])

    def get_rating(self, i, j):
        prediction = self.b + self.b_u[i] + self.b_i[j] + self.P[i, :].dot(self.Q[j, :].T)
        return prediction

    def full_matrix(self):
        return self.b + self.b_u[:, np.newaxis] + self.b_i[np.newaxis:,] + self.P.dot(self.Q.T)

iter = 200
mf = MF(matrix, test_matrix, K=20, alpha=0.1, beta=0.01, iterations=iter)
mf.train()

import matplotlib.pyplot as plt

plt.plot(mse_list)
plt.xlabel('iterations')
plt.ylabel('MSE loss')
plt.show()