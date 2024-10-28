import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def save_prediction(weight_path, pred, test_idx):
    sub_id = pd.read_csv('../kaggle_data/annotation/test_id.csv', delimiter=',') #idx 기준
    
    sub_df = pd.DataFrame()
    sub_df['id'] = test_idx
    sub_df['label'] = pred
    sub_df = sub_df.set_index('id', drop=False)
    sub_df = sub_df.reindex(sub_id['id'])
    sub_df = sub_df.reset_index(drop=True)
    sub_df.to_csv(weight_path+'submission.csv', index=None)

    print('\nSubmission File Saved...!!')

def plot_accuracy(print_every, weight_path, num_epochs, train_accuracy, valid_accuracy):
        """
            Draw a plot of train/valid accuracy.
            X-axis : Epoch
            Y-axis : train_accuracy & valid_accuracy
            Draw train_acc-epoch, valid_acc-epoch graph in 'one' plot.
        """
        if len(train_accuracy)!=0:
            epochs = list(np.arange(1, (num_epochs+1)+1, print_every))

            plt.plot(epochs, train_accuracy, label='Train Acc.')
            plt.plot(epochs, valid_accuracy, label='Valid Acc.')

            plt.title('Epoch - Train/Valid Acc.')
            plt.xlabel('Epochs')
            plt.ylabel('Accuracy')
            plt.legend()

            plt.show()
            plt_file_path = f'{weight_path}Acc_Plot.png' 
            plt.savefig(plt_file_path)