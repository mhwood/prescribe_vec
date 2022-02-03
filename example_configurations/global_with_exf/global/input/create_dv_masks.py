
import os
import matplotlib.pyplot as plt
import numpy as np

domain_shape = (40,90)
min_row = 10
max_row = 29
min_col= 25
max_col = 64

layers = 3

if 'dv' not in os.listdir(os.getcwd()):
    os.mkdir(os.path.join(os.getcwd(),'dv'))

# create the eastern masks
for layer in range(layers):
    mask = np.zeros(domain_shape)
    counter = 1
    for row in range(min_row,max_row+1):
        mask[row,max_col-layer] = counter
        counter+=1
    if layer==0:
        file_name = os.path.join(os.getcwd(),'dv','east_mask.bin')
    else:
        file_name = os.path.join(os.getcwd(),'dv', 'east_mask_i'+str(layer)+'.bin')
    mask.ravel(order='C').astype('>f4').tofile(file_name)

# create the western masks
for layer in range(layers):
    mask = np.zeros(domain_shape)
    counter = 1
    for row in range(min_row,max_row+1):
        mask[row,min_col+layer] = counter
        counter+=1
    if layer==0:
        file_name = os.path.join(os.getcwd(),'dv','west_mask.bin')
    else:
        file_name = os.path.join(os.getcwd(),'dv', 'west_mask_i'+str(layer)+'.bin')
    mask.ravel(order='C').astype('>f4').tofile(file_name)

# create the southern masks
for layer in range(layers):
    mask = np.zeros(domain_shape)
    counter = 1
    for col in range(min_col,max_col+1):
        mask[min_row+layer,col] = counter
        counter+=1
    if layer==0:
        file_name = os.path.join(os.getcwd(),'dv','south_mask.bin')
    else:
        file_name = os.path.join(os.getcwd(),'dv', 'south_mask_i'+str(layer)+'.bin')
    mask.ravel(order='C').astype('>f4').tofile(file_name)

# create the northern masks
for layer in range(layers):
    mask = np.zeros(domain_shape)
    counter = 1
    for col in range(min_col,max_col+1):
        mask[max_row-layer,col] = counter
        counter+=1
    if layer==0:
        file_name = os.path.join(os.getcwd(),'dv','north_mask.bin')
    else:
        file_name = os.path.join(os.getcwd(),'dv', 'north_mask_i'+str(layer)+'.bin')
    mask.ravel(order='C').astype('>f4').tofile(file_name)

# create the surface mask
mask = np.zeros(domain_shape)
counter = 1
for row in range(min_row, max_row + 1):
    for col in range(min_col,max_col+1):
        mask[row,col] = counter
        counter+=1
file_name = os.path.join(os.getcwd(),'dv','surface_mask.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

