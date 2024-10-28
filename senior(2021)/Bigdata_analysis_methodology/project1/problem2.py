import pandas as pd
import matplotlib.pyplot as plt

data = pd.read_csv('input_data.csv')
data[' Average Covered Charges '] = data[' Average Covered Charges '].apply(lambda x: x[1:])
data = data.astype({' Average Covered Charges ': 'float'})

info = data[['DRG Definition', 'Provider Id', 'Provider State', ' Average Covered Charges ']]

new_info = {}
col_list = ['Provider Id']

drg_list = []
for i in range(info.shape[0]):
    if info['DRG Definition'][i] not in drg_list:
        drg_list.append(info['DRG Definition'][i])
        col_list.append('DRG Charges '+str(info['DRG Definition'][i][:3]))

prov_id = []
prov_st = []

for i in range(data.shape[0]):
    if info['Provider Id'][i] not in prov_id:
        prov_id.append(info['Provider Id'][i])
        prov_st.append(info['Provider State'][i])

for c in col_list:
    new_info[c] = [0 for i in range(len(prov_id))]

#2 - Transforming Data~
df = pd.DataFrame({'Provider Id': prov_id, 'Provider State': prov_st})
df = df.astype({'Provider Id': 'int'})
new_info['Provider Id'] = prov_id
new_df = pd.DataFrame(new_info, columns= col_list)
new_df = new_df.astype({'Provider Id': 'int'})
for i in range(data.shape[0]):
    new_df.loc[new_df['Provider Id'] == info['Provider Id'][i], 'DRG Charges ' + str(info['DRG Definition'][i][:3])] = info[' Average Covered Charges '][i]

new_df = pd.merge(df, new_df, on='Provider Id')
# ~Transforming Data

#3 - Correlation and Scatterplots
corr_df = new_df
corr_df = corr_df.drop(['Provider Id', 'Provider State'], axis=1)
lists = []
for c in col_list[1:]:
    lists.append(list(corr_df[c]))

corr_df = pd.DataFrame(lists).T
corr = corr_df.corr(method = 'pearson') # compute correlations

corr_dic = {}
for i in range(len(corr)):
    for j in range(len(corr)):
        if float(corr[i][j]) != 1.0:
            corr_dic[len(corr)*i + j] = float(corr[i][j])

corr_list = sorted(corr_dic.items(), key=lambda x: x[1], reverse=True)

#3-(a) plot scatterplots
plt.scatter(list(new_df['DRG Charges ' + str(drg_list[int(corr_list[0][0] / 100)][:3])]), list(new_df['DRG Charges ' + str(drg_list[int(corr_list[0][0] % 100)][:3])]))
plt.xlabel(drg_list[int(corr_list[0][0] / 100)])
plt.ylabel(drg_list[int(corr_list[0][0] % 100)])
plt.show()

plt.scatter(list(new_df['DRG Charges ' + str(drg_list[int(corr_list[2][0] / 100)][:3])]), list(new_df['DRG Charges ' + str(drg_list[int(corr_list[2][0] % 100)][:3])]))
plt.xlabel(drg_list[int(corr_list[2][0] / 100)])
plt.ylabel(drg_list[int(corr_list[2][0] % 100)])
plt.show()

plt.scatter(list(new_df['DRG Charges ' + str(drg_list[int(corr_list[len(corr_list)-1][0] / 100)][:3])]), list(new_df['DRG Charges ' + str(drg_list[int(corr_list[len(corr_list)-1][0] % 100)][:3])]))
plt.xlabel(drg_list[int(corr_list[len(corr_list)-1][0] / 100)])
plt.ylabel(drg_list[int(corr_list[len(corr_list)-1][0] % 100)])
plt.show()

plt.scatter(list(new_df['DRG Charges ' + str(drg_list[int(corr_list[len(corr_list)-3][0] / 100)][:3])]), list(new_df['DRG Charges ' + str(drg_list[int(corr_list[len(corr_list)-3][0] % 100)][:3])]))
plt.xlabel(drg_list[int(corr_list[len(corr_list)-3][0] / 100)])
plt.ylabel(drg_list[int(corr_list[len(corr_list)-3][0] % 100)])
plt.show()
# ~Correlation and Scatterplots

#4 - Boxplots and T-tests
ca = new_df['Provider State'] == 'CA'
fl = new_df['Provider State'] == 'FL'
tx = new_df['Provider State'] == 'TX'
wv = new_df['Provider State'] == 'WV'
ma = new_df['Provider State'] == 'MA'
ok = new_df['Provider State'] == 'OK'
state_label = ['CA', 'FL', 'TX', 'WV', 'MA', 'OK']
#4-(a) Boxplots

# make boxplots for all DRG Charge feature to choose three features
"""for c in col_list[1:]:
    valid = new_df[c] != 0.0
    state6 = [new_df[ca & valid][c],
              new_df[fl & valid][c],
              new_df[tx & valid][c],
              new_df[wv & valid][c],
              new_df[ma & valid][c],
              new_df[ok & valid][c]]
    plt.boxplot(state6, labels=state_label)
    plt.xlabel(c)
    plt.ylabel(' Average Covered Charges ')
    plt.show()"""
# make boxplots for all DRG Charge feature to choose three features

from scipy import stats
valid = new_df['DRG Charges 301'] != 0.0
tTestResultDiffVar = stats.ttest_ind(new_df[ca & valid]['DRG Charges 301'], new_df[fl & valid]['DRG Charges 301'], equal_var=False)
print("t-statistics: %.8f, p-value: %.8f" % tTestResultDiffVar) # 4-(b)

# 4-(c) concatenate three selected DRG categories
tx_df = new_df[tx & valid]['DRG Charges 301']
valid = new_df['DRG Charges 377'] != 0.0
tx_df = pd.concat([tx_df, new_df[tx & valid]['DRG Charges 377']])
valid = new_df['DRG Charges 602'] != 0.0
tx_df = pd.concat([tx_df, new_df[tx & valid]['DRG Charges 602']])

wv_df = new_df[wv & valid]['DRG Charges 301']
valid = new_df['DRG Charges 377'] != 0.0
wv_df = pd.concat([wv_df, new_df[wv & valid]['DRG Charges 377']])
valid = new_df['DRG Charges 602'] != 0.0
wv_df = pd.concat([wv_df, new_df[wv & valid]['DRG Charges 602']])

#downsample and testing
tTestResultDiffVar2 = stats.ttest_ind(tx_df.sample(n=len(wv_df)), wv_df, equal_var=False)
print("t-statistics: %.8f, p-value: %.8f" % tTestResultDiffVar2) # 4-(c)