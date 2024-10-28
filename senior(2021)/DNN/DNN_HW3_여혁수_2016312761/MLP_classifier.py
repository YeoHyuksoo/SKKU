
import time
import os
import torch
import torch.nn as nn

import numpy as np
import matplotlib.pyplot as plt

from torch.utils.data import TensorDataset, DataLoader

'''
Please refer the models/Linear_regressor.py and the PyTorch tutorials in report file.
'''
class MLP_classifier(nn.Module):
    def __init__(self, input_dim, output_dim, learning_rate):
        super(MLP_classifier, self).__init__()
        '''
        Please define layers, loss, and optimizer in here.
        You can use "nn.Linear" for MLP layers, 
        "nn.CrossEntropyLoss" for CE Loss, and "torch.optim.SGD" for SGD optimizer.
        '''
        self.output_dim = output_dim
        self.loss_function = None
        self.optimizer = None
        # =============================== EDIT HERE ===============================

        self.linear = nn.Linear(in_features=input_dim, out_features=200)
        self.linear2 = nn.Linear(200, 128)
        self.linear3 = nn.Linear(128, 10)

        self.loss_function = nn.CrossEntropyLoss()
        self.optimizer = torch.optim.SGD(self.parameters(), lr=learning_rate)

        # =========================================================================

    def forward(self, x):
        '''
        Please define model in here.
        You can use "torch.sigmoid" for Sigmoid function.
        '''
        out = torch.zeros((x.shape[0], self.output_dim))
        # =============================== EDIT HERE ===============================
        x = torch.relu(self.linear(x))
        x = torch.relu(self.linear2(x))
        out = self.linear3(x)


        # =========================================================================
        return out

    def predict(self, x):
        '''
        Please define model predict function.
        You have to use "torch.no_grad()" in order not to calculate the gradient. 
        And, implement in mini-batch.
        '''
        pred_y = np.zeros((x.shape[0], ))
        # =============================== EDIT HERE ===============================

        # transfrom numpy data to torch data and make torch dataset
        x_tenser = torch.tensor(x, dtype=torch.float32)
        data_loader = DataLoader(x_tenser, batch_size=self.batch_size)

        # predict y with mini-batch
        cnt = 0
        with torch.no_grad():
            for batch_data in data_loader:
                batch_x = batch_data
                batch_pred_y = self.forward(batch_x)
                pred_y[cnt:cnt+len(batch_pred_y)] = batch_pred_y.max(1)[1]
                cnt+=len(batch_pred_y)
        #pred_y = np.concatenate(pred_y, axis=0)

        # =========================================================================
        return pred_y

    def train(self, train_x, train_y, valid_x, valid_y, num_epochs, batch_size, print_every=10):
        '''
        Calculate loss and update model using optimizer.
        You can easily use mini-batch using "TensorDataset" and "DataLoader".
        '''
        self.train_accuracy = []
        self.valid_accuracy = []
        best_epoch = -1
        best_acc = -1
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
                    loss = self.loss_function(pred_y, torch.argmax(batch_y, -1))
                    
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
                true = np.argmax(train_y, -1).astype(int)
                correct = len(np.where(pred == true)[0])
                total = len(true)
                train_acc = correct / total
                self.train_accuracy.append(train_acc)

                # VAL ACCURACY
                pred = self.predict(valid_x)
                true = np.argmax(valid_y, -1).astype(int)

                correct = len(np.where(pred == true)[0])
                total = len(true)
                valid_acc = correct / total
                self.valid_accuracy.append(valid_acc)

                print('[EPOCH %d] Loss = %.5f' % (epoch, epoch_loss))
                print('Train Accuracy = %.3f' % train_acc + ' // ' + 'Valid Accuracy = %.3f' % valid_acc)

                # best model save
                if best_acc < valid_acc:
                    print('Best Accuracy updated (%.4f => %.4f)' % (best_acc, valid_acc))
                    best_acc = valid_acc
                    best_epoch = epoch
                    torch.save(self.state_dict(), './best_model/MLP_classifier.pt')
        print('Training Finished...!!')
        print('Best Valid acc : %.2f at epoch %d' % (best_acc, best_epoch))

    def restore(self):
        with open(os.path.join('./best_model/MLP_classifier.pt'), 'rb') as f:
            state_dict = torch.load(f)
        self.load_state_dict(state_dict)

    
    def plot_accuracy(self):
        """
            Draw a plot of train/valid accuracy.
            X-axis : Epoch
            Y-axis : train_accuracy & valid_accuracy
            Draw train_acc-epoch, valid_acc-epoch graph in 'one' plot.
        """
        epochs = list(np.arange(1, self.num_epochs+1, self.print_every))

        print(len(epochs), len(self.train_accuracy))

        plt.plot(epochs, self.train_accuracy, label='Train Acc.')
        plt.plot(epochs, self.valid_accuracy, label='Valid Acc.')

        plt.title('Epoch - Train/Valid Acc.')
        plt.xlabel('Epochs')
        plt.ylabel('Accuracy')
        plt.legend()

        plt.show()
