from tensorflow.contrib.keras.api.keras.optimizers import RMSprop, Adam
from tensorflow.contrib.keras.api.keras.models import Model, Sequential
from tensorflow.contrib.keras.api.keras.layers import Input, Activation
from tensorflow.contrib.keras.api.keras.layers import Conv2D, Reshape, Conv3D, AveragePooling2D, Lambda, UpSampling2D, UpSampling3D, GlobalAveragePooling2D
from tensorflow.contrib.keras.api.keras.layers import Dropout, BatchNormalization
from tensorflow.contrib.keras.api.keras.layers import concatenate, add, multiply

import tensorflow as tf
from tensorflow.contrib.keras import backend as K
import numpy as np

def conv2Dx2(input, size, channels1, channels2):

    seq = Conv2D(channels1, size, 1, padding='same', kernel_initializer='glorot_uniform')(input)
    seq = Activation('selu')(seq)
    seq = Conv2D(channels2, size, 1, padding='same', kernel_initializer='glorot_uniform')(seq)
    seq = BatchNormalization()(seq)
    seq = Activation('selu')(seq)

    return seq

def dilaConv9x9(input, dilation):

    seq = Conv2D(4, 9, 1, padding='valid', dilation_rate=dilation, kernel_initializer='glorot_uniform')(input)
    seq = BatchNormalization()(seq)
    seq = Activation('selu')(seq)

    return seq

def dilaConv5x5(input, dilation):

    seq = Conv2D(4, 3, 1, padding='same', kernel_initializer='glorot_uniform')(input)
    seq = BatchNormalization()(seq)

    seq = Conv2D(4, 5, 1, padding='valid', dilation_rate=dilation, kernel_initializer='glorot_uniform')(seq)
    seq = BatchNormalization()(seq)

    seq = Activation('selu')(seq)
    
    seq = Conv2D(8, 3, 1, padding='same', kernel_initializer='glorot_uniform')(seq)
    seq = BatchNormalization()(seq)

    seq = Conv2D(8, 5, 1, padding='valid', dilation_rate=dilation, kernel_initializer='glorot_uniform')(seq)
    seq = BatchNormalization()(seq)
    
    seq = Activation('selu')(seq)

    return seq

def dilaConv3x3(input, dilation):

    seq = Conv2D(2, 3, 1, padding='same', kernel_initializer='glorot_uniform')(input)
    seq = BatchNormalization()(seq)
    seq = Conv2D(4, 3, 1, padding='valid', dilation_rate=dilation, kernel_initializer='glorot_uniform')(input)
    seq = BatchNormalization()(seq)
    seq = Activation('selu')(seq)

    seq = Conv2D(4, 3, 1, padding='same', kernel_initializer='glorot_uniform')(seq)
    seq = BatchNormalization()(seq)
    seq = Conv2D(8, 3, 1, padding='valid', dilation_rate=dilation, kernel_initializer='glorot_uniform')(seq)
    seq = BatchNormalization()(seq)
    seq = Activation('selu')(seq)

    seq = Conv2D(8, 3, 1, padding='same', kernel_initializer='glorot_uniform')(seq)
    seq = BatchNormalization()(seq)
    seq = Conv2D(16, 3, 1, padding='valid', dilation_rate=dilation, kernel_initializer='glorot_uniform')(seq)
    seq = BatchNormalization()(seq)
    seq = Activation('selu')(seq)

    seq = Conv2D(16, 3, 1, padding='same', kernel_initializer='glorot_uniform')(seq)
    seq = BatchNormalization()(seq)
    seq = Conv2D(32, 3, 1, padding='valid', dilation_rate=dilation, kernel_initializer='glorot_uniform')(seq)
    seq = BatchNormalization()(seq)
    seq = Activation('selu')(seq)

    return seq

def Inception_res(input):

    channels = input.shape.as_list()[-1]
    x1 = Conv2D(32, 1, 1, padding='same')(input)
    x1 = BatchNormalization()(x1)

    x2 = Conv2D(32, 1, 1, padding='same')(input) 
    x2 = BatchNormalization()(x2)
    x2 = Conv2D(48, 3, 1, padding='same')(x2) 
    x2 = BatchNormalization()(x2)

    x3 = Conv2D(32, 1, 1, padding='same')(input) 
    x3 = BatchNormalization()(x3)
    x3 = Conv2D(48, 3, 1, padding='same')(x3) 
    x3 = BatchNormalization()(x3)
    x3 = Conv2D(64, 3, 1, padding='same')(x3) 
    x3 = BatchNormalization()(x3)

    x = concatenate([x1, x2, x3], axis=-1)
    x = Conv2D(channels, 1, padding='same')(x)
    x = Activation('linear')(x)
    y = add([input, x])
    y = Activation('selu')(y)

    return y

def senet_res(input, reduction):#reduction = 4
    
    channels = input.shape.as_list()[-1]
    avg_x = GlobalAveragePooling2D()(input)
    avg_x = Reshape((1,1,channels))(avg_x)
    avg_x = Conv2D(int(channels)//reduction, 1, 1, padding='valid')(avg_x)
    avg_x = BatchNormalization()(avg_x)
    avg_x = Activation('selu')(avg_x)
    avg_x = Conv2D(int(channels), 1, 1, padding='valid')(avg_x)
    avg_x = BatchNormalization()(avg_x)
    avg_x = Activation('selu')(avg_x)

    max_x = GlobalAveragePooling2D()(input)
    max_x = Reshape((1,1,channels))(max_x)
    max_x = Conv2D(int(channels)//reduction, 1, 1, padding='valid')(max_x)
    max_x = BatchNormalization()(max_x)
    max_x = Activation('selu')(max_x)
    max_x = Conv2D(int(channels), 1, 1, padding='valid')(max_x)
    max_x = BatchNormalization()(max_x)
    max_x = Activation('selu')(max_x)

    y = add([avg_x, max_x])
    y = Activation('hard_sigmoid')(y)
    y = multiply([input, y])
    y = add([input, y])
    y = Activation('selu')(y)

    return y


def layer1_extract(input, sz_input, sz_input2, dilation):

    ''' dilation Conv 9x9*1 or 5x5*2 or 3x3*4 '''
    #seq = dilaConv9x9(input, dilation)
    #seq = dilaConv5x5(input, dilation)
    seq = dilaConv3x3(input, dilation)
    
    for i in range(3):
        seq = conv2Dx2(seq, 3, 200, 200)
        
    #seq = Dropout(0.02)(seq)
    
    for i in range(7):
        #seq = conv2Dx2(seq, 2, 128, 128)
        #seq = Conv2D(64, 2, 1, padding='same', kernel_initializer='glorot_uniform')(seq)
        #seq = BatchNormalization()(seq)
        seq = Inception_res(seq)
        #seq = Dropout(0.02)(seq)
        seq = senet_res(seq, 4)
    
    return seq

def layer2_processing(input):
    
    seq = conv2Dx2(input, 3, 64, 64)    
    #seq = senet_res(seq, 4)
    seq = conv2Dx2(seq, 3, 64, 64)
    #seq = senet_res(seq, 4)
    seq = Conv2D(1, 1, 1, padding='same')(seq)

    return seq


def define_LFattNet(sz_input, sz_input2, view_n, learning_rate):

    SZ_full = len(view_n) * sz_input
    SZ_full2 = len(view_n) * sz_input2

    img = Input(shape=(SZ_full, SZ_full2, 1), name='img')

    pred = layer1_extract(img, sz_input, sz_input2, sz_input)

    pred = layer2_processing(pred)

    model = Model(inputs=img, outputs=[pred])
    
    model.summary()

    opt = RMSprop(lr=learning_rate)

    model.compile(optimizer=opt, loss='mae')

    return model

