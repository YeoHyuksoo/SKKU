import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sb

data = pd.read_csv('input_data.csv')
td = data[' Total Discharges ']

#1-(a)
sb.distplot(td)
plt.show()
sb.histplot(td)
plt.show()

data[' Average Covered Charges '] = data[' Average Covered Charges '].apply(lambda x: x[1:])
data[' Average Total Payments '] = data[' Average Total Payments '].apply(lambda x: x[1:])
data['Average Medicare Payments'] = data['Average Medicare Payments'].apply(lambda x: x[1:])
data = data.astype({' Average Covered Charges ': 'float'})
data = data.astype({' Average Total Payments ': 'float'})
data = data.astype({'Average Medicare Payments': 'float'})

#1-(b)
sb.distplot(data[' Average Covered Charges '])
plt.show()
sb.histplot(data[' Average Covered Charges '])
plt.show()
#1-(c)
plt.scatter(data[' Average Total Payments '], data['Average Medicare Payments'])
plt.xlabel('Average Total Payments')
plt.ylabel('Average Medicare Payments')
plt.show()
#1-(d)
plt.scatter(data[' Average Covered Charges '], data['Average Medicare Payments'])
plt.xlabel('Average Covered Charges')
plt.ylabel('Average Medicare Payments')
plt.show()