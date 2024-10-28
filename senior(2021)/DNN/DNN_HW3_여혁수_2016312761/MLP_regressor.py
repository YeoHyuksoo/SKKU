
from utils import MSE
import torch
import torch.nn as nn
from torch.utils.data import TensorDataset, DataLoader
import time
import os
import numpy as np
import matplotlib.pyplot as plt

'''
Please refer the models/Linear_regressor.py and the PyTorch tutorials in report file.
'''
class MLP_regressor(nn.Module):
    def __init__(self, input_dim, learning_rate):
        super(MLP_regressor, self).__init__()
        '''
        Please define layers, loss, and optimizer in here.
        You can use "nn.Linear" for MLP layers, 
        "nn.MSELoss" for MSE Loss, and "torch.optim.SGD" for SGD optimizer.
        '''
        self.loss_function = None
        self.optimizer = None
        # =============================== EDIT HERE ===============================

        self.loss_function = nn.MSELoss()
        self.fc1 = nn.Linear(in_features=input_dim, out_features=50, bias=True)
        self.fc2 = nn.Linear(50, 1, bias=True)

        self.optimizer = torch.optim.SGD(self.parameters(), lr=learning_rate)

        # =========================================================================

        return

    def forward(self, x):
        '''
        Please define model in here.
        You can use "torch.sigmoid" for Sigmoid function.
        '''
        out = torch.zeros((x.shape[0], 1))
        # =============================== EDIT HERE ===============================
        x = torch.rrelu(self.fc1(x))
        out = self.fc2(x)

        # =========================================================================
        return out

    def predict(self, x):
        '''
        Please define model predict function.
        You have to use "torch.no_grad()" in order not to calculate the gradient. 
        And, implement in mini-batch.
        '''
        pred_y = np.zeros((x.shape[0], 1))
        # =============================== EDIT HERE ===============================

        # transfrom numpy data to torch data and make torch dataset
        x_tenser = torch.tensor(x)
        data_loader = DataLoader(x_tenser, batch_size=self.batch_size)

        # predict y with mini-batch
        pred_y = []
        with torch.no_grad():
            for batch_data in data_loader:
                batch_x = batch_data
                batch_pred_y = self.forward(batch_x)
                pred_y.append(batch_pred_y.numpy())
        pred_y = np.concatenate(pred_y, axis=0)

        # =========================================================================
        return pred_y

    def train(self, train_x, train_y, valid_x, valid_y, num_epochs, batch_size, print_every=10):
        '''
        Calculate loss and update model using optimizer.
        You can easily use mini-batch using "TensorDataset" and "DataLoader".
        '''
        self.train_MSE = []
        self.valid_MSE = []
        best_epoch = -1
        best_mse = float('inf')
        self.num_epochs = num_epochs
        self.print_every = print_every

        # transfrom numpy data to torch data and make torch dataset
        x_tenser = torch.tensor(train_x).float()
        y_tenser = torch.tensor(train_y).float()
        dataset = TensorDataset(x_tenser, y_tenser)

        data_loader = DataLoader(dataset, batch_size=batch_size)
        self.batch_size = batch_size

        # train the model with mini-batch
        for epoch in range(1, num_epochs+1):
            start = time.time()
            epoch_loss = 0.0
            # model train
            for b, batch_data in enumerate(data_loader):
                batch_x, batch_y = batch_data
                pred_y = self.forward(batch_x)

                if self.loss_function:
                    # calcuate the loss
                    loss = self.loss_function(pred_y.reshape(-1), batch_y)
                    # model update
                    self.optimizer.zero_grad()
                    loss.backward()
                    self.optimizer.step()
                    epoch_loss += loss

            epoch_loss /= len(data_loader)
            end = time.time()
            lapsed_time = end - start
            print(f'Epoch {epoch} took {lapsed_time} seconds\n')

            # model validate 
            if epoch % print_every == 0:
                # TRAIN ACCURACY
                pred = self.predict(train_x)
                train_mse = MSE(pred, train_y)
                self.train_MSE.append(train_mse)

                # VAL ACCURACY
                pred = self.predict(valid_x)
                valid_mse = MSE(pred, valid_y)
                self.valid_MSE.append(valid_mse)

                print('[EPOCH %d] Loss = %.5f' % (epoch, epoch_loss))
                print('Train MSE = %.3f' % train_mse + ' // ' + 'Valid MSE = %.3f' % valid_mse)

                # best model save
                if best_mse > valid_mse:
                    print('Best Accuracy updated (%.4f => %.4f)' % (best_mse, valid_mse))
                    best_mse = valid_mse
                    best_epoch = epoch
                    torch.save(self.state_dict(), './best_model/MLP_regressor.pt')
        print('Training Finished...!!')
        print('Best Valid mse : %.2f at epoch %d' % (best_mse, best_epoch))

    def restore(self):
        with open(os.path.join('./best_model/MLP_regressor.pt'), 'rb') as f:
            state_dict = torch.load(f)
        self.load_state_dict(state_dict)

    def plot_accuracy(self):
        """
            Draw a plot of train/valid accuracy.
            X-axis : Epoch
            Y-axis : train MSE & valid MSE
            Draw train MSE-epoch, valid MSE-epoch graph in 'one' plot.
        """
        epochs = list(np.arange(1, self.num_epochs+1, self.print_every))

        print(len(epochs), len(self.train_MSE))

        plt.plot(epochs, self.train_MSE, label='Train MSE')
        plt.plot(epochs, self.valid_MSE, label='Valid MSE')

        plt.title('Epoch - Train/Valid MSE')
        plt.xlabel('Epochs')
        plt.ylabel('Mean Squared Error')
        plt.legend()

        plt.show()
