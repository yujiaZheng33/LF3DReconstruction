# -*- coding: utf-8 -*-
"""
Created on Thu Apr  5 13:38:16 2018

@author: shinyonsei2
"""

import imageio
import numpy as np
import os

def load_LFdata_pro(dir_LFimages, size1, size2):    
    traindata_all=np.zeros((len(dir_LFimages), size1, size2, 9, 9, 3),np.uint8)
    traindata_label=np.zeros((len(dir_LFimages), size1, size2),np.float32)
    
    image_id=0
    for dir_LFimage in dir_LFimages:
        print(dir_LFimage)
        for i in range(81):
            try:
                tmp  = np.float32(imageio.imread('hci_dataset/'+dir_LFimage+'/input_Cam0%.2d.png' % i)) # load LF images(9x9) 
            except:
                print('hci_dataset/'+dir_LFimage+'/input_Cam0%.2d.png..does not exist' % i )
            traindata_all[image_id,:,:,i//9,i-9*(i//9),:]=tmp  
            del tmp
        try:            
            tmp  = np.float32(read_pfm('hci_dataset/'+dir_LFimage+'/gt_disp_lowres.pfm')) # load LF disparity map
        except:
            print('hci_dataset/'+dir_LFimage+'/gt_disp_lowres.pfm..does not exist' % i )            
        traindata_label[image_id,:,:]=tmp  
        del tmp
        image_id=image_id+1
    return traindata_all, traindata_label


def generate_traindata_pro(traindata_all, traindata_label, Setting02_AngualrViews, size1, size2):
    """
    Generate validation or test set( = full size(512x512) LF images)

     input: traindata_all   (16x512x512x9x9x3) uint8
            traindata_label (16x512x512x9x9)   float32
            Setting02_AngualrViews [0,1,2,3,4,5,6,7,8] for 9x9


     output: traindata_batch_list   (batch_size x 512 x 512 x len(Setting02_AngualrViews)) float32
             traindata_label_batchNxN (batch_size x 512 x 512 )               float32
    """

    input_size = size1
    label_size = size2
    traindata_batch = np.zeros((len(traindata_all), input_size, input_size, len(Setting02_AngualrViews), len(Setting02_AngualrViews)), dtype=np.float32)

    traindata_label_batchNxN = np.zeros((len(traindata_all), label_size, label_size))

    """ inital setting """
    ### sz = (16, 27, 9, 512, 512)

    crop_half1 = int(0.5 * (input_size - label_size))

    for ii in range(0, len(traindata_all)):

        R = 0.299  ### 0,1,2,3 = R, G, B, Gray // 0.299 0.587 0.114
        G = 0.587
        B = 0.114

        image_id = ii

        ix_rd = 0
        iy_rd = 0
        idx_start = 0
        idy_start = 0

        traindata_batch[ii, :, :, :, :] = np.squeeze(
            R * traindata_all[image_id:image_id + 1, idx_start: idx_start + input_size,
                idy_start: idy_start + input_size, :, :, 0].astype('float32') +
            G * traindata_all[image_id:image_id + 1, idx_start: idx_start + input_size,
                idy_start: idy_start + input_size, :, :, 1].astype('float32') +
            B * traindata_all[image_id:image_id + 1, idx_start: idx_start + input_size,
                idy_start: idy_start + input_size, :, :, 2].astype('float32'))



        if (len(traindata_all) >= 12 and traindata_label.shape[-1] == 9):
            traindata_label_batchNxN[ii, :, :] = traindata_label[image_id,
                                              idx_start + crop_half1: idx_start + crop_half1 + label_size,
                                              idy_start + crop_half1: idy_start + crop_half1 + label_size,
                                              4 + ix_rd, 4 + iy_rd]
        elif (len(traindata_label.shape) == 5):
            traindata_label_batchNxN[ii, :, :] = traindata_label[image_id,
                                                 idx_start + crop_half1: idx_start + crop_half1 + label_size,
                                                 idy_start + crop_half1: idy_start + crop_half1 + label_size, 0, 0]
        else:
            traindata_label_batchNxN[ii, :, :] = traindata_label[image_id,
                                                 idx_start + crop_half1: idx_start + crop_half1 + label_size,
                                                 idy_start + crop_half1: idy_start + crop_half1 + label_size]

    traindata_batch = np.float32((1 / 255) * traindata_batch)

    traindata_batch = np.minimum(np.maximum(traindata_batch, 0), 1)
    
    traindata_img = np.zeros((len(traindata_all), input_size*len(Setting02_AngualrViews), input_size*len(Setting02_AngualrViews), 1), dtype=np.float32)
    for u in range(traindata_batch.shape[3]):
        for v in range(traindata_batch.shape[4]):
            traindata_img[:, u*input_size: (u+1)*input_size, v*input_size: (v+1)*input_size, :] = np.expand_dims(traindata_batch[:, :, :, u, v], axis=-1)
    
    del traindata_batch

    return traindata_img, traindata_label_batchNxN
