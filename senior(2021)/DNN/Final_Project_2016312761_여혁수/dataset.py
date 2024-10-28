import codecs
import os

import numpy as np
import torch
from torch import distributions as dist
from torch import nn
from torch.nn import functional as F
from torch.utils import data
from PIL import Image
import re


class SSL_Dataset(data.Dataset):
    def __init__(
        self,
        root,
        mode,
        transform=None,
        **kwargs
    ):
        super().__init__()
        self.root = root
        self.transform = transform
        self.mode = mode

        if self.mode in ['labeled_train']:
            self.data, self.targets = self._load_data()
        elif self.mode in ['test']: 
            self.idx, self.data = self._load_data()
        #################### EDIT HERE ####################
        elif self.mode in ['unlabeled_train']:
            self.idx, self.data = self._load_data()
        ###################################################
   
    def __len__(self):
        return len(self.data)

    def __getitem__(self, index):
        if self.mode in ['labeled_train']: 
            impath, target = self.data[index], self.targets[index]
            img = Image.open('../kaggle_data'+ impath).convert('RGB')
            if self.transform is not None:
                img = self.transform(img)
            target = target.long()
            return img, target
        elif self.mode in ['test']: 
            impath = self.data[index]
            img = Image.open('../kaggle_data'+ impath).convert('RGB')
            if self.transform is not None:
                img = self.transform(img)
            return img
        #################### EDIT HERE ####################
        elif self.mode in ['unlabeled_train']:
            impath = self.data[index]
            img = Image.open('../kaggle_data'+ impath).convert('RGB')
            if self.transform is not None:
                img = self.transform(img)
            return img
        ###################################################

    def _load_data(self):
        data = []
        targets = []
        idx = []

        labeled_train = "kaggle_data/annotation/train_labeled_filelist.txt" 
        unlabeled_train = "kaggle_data/annotation/train_unlabeled_filelist.txt"
        unlabeled_test = "kaggle_data/annotation/test_filelist.txt"

        if self.mode == 'labeled_train':
            flist = self.root + labeled_train
            with open(flist, 'r') as rf:
                for line in rf.readlines():
                    imgdata, clean_label = line.strip().split()
                    data.append(imgdata)
                    targets.append(float(clean_label))
                targets = torch.LongTensor(targets)
                return data, targets
        elif self.mode == 'test': 
            flist = self.root + unlabeled_test
            with open(flist, 'r') as rf:
                for line in rf.readlines():
                    imgdata = line.strip()
                    data.append(imgdata)
                    idx.append(imgdata.split('/')[2][:-4])
                return idx, data
        #################### EDIT HERE ####################
        elif self.mode == 'unlabeled_train':
            flist = self.root + unlabeled_train
            with open(flist, 'r') as rf:
                for line in rf.readlines():
                    imgdata = line.strip()
                    data.append(imgdata)
                    idx.append(imgdata.split('/')[2][:-4])
                return idx, data
        ###################################################

