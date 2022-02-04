
import os
import matplotlib.pyplot as plt
import numpy as np

# record some statistics about the regional domain
min_row = 10
max_row = 29
min_col= 25
max_col = 64
regional_domain_shape = (max_row-min_row+1,max_col-min_col+1)
nTimesteps = 2160
layers = 3

if 'bcs' not in os.listdir(os.getcwd()):
    os.mkdir(os.path.join(os.getcwd(),'bcs'))

boundary_names = ['west','north','south','east']
var_names = ['ETAN','THETA','SALT','UVEL','VVEL']

print('Creating the prescribe_vec fields and masks')

for boundary_name in boundary_names:
    print(' - Creating fields for the '+boundary_name+' boundary')
    for var_name in var_names:

        if var_name=='ETAN':
            Nr=1
        else:
            Nr = 15

        if boundary_name=='west' or boundary_name=='east':
            N = regional_domain_shape[0]
            prescribe_vec_grid = np.zeros((nTimesteps,Nr,layers*N))
        if boundary_name=='north' or boundary_name=='north':
            N = regional_domain_shape[1]
            prescribe_vec_grid = np.zeros((nTimesteps,Nr,layers*N))

        for layer in range(layers):
            if layer==0:
                dv_file_name = os.path.join('..','..','global','run','dv',boundary_name+'_mask_'+var_name+'.bin')
            else:
                dv_file_name = os.path.join('..', '..', 'global', 'run', 'dv',
                                            boundary_name + '_mask_i'+str(layer)+'_' + var_name + '.bin')
            layer_grid = np.fromfile(dv_file_name,'>f4')
            layer_grid = np.reshape(layer_grid,(nTimesteps,Nr,N))

            # note: layers were made outside in
            if boundary_name=='west':
                prescribe_vec_grid[:,:,layer*N:(layer+1)*N] = layer_grid
            if boundary_name=='south':
                prescribe_vec_grid[:,:,layer*N:(layer+1)*N] = layer_grid
            if boundary_name=='east':
                prescribe_vec_grid[:,:,layer*N:(layer+1)*N] = layer_grid
            if boundary_name=='north':
                prescribe_vec_grid[:,:,layer*N:(layer+1)*N] = layer_grid

        print('    - The '+str(var_name)+' grid has shape '+str(np.shape(prescribe_vec_grid)))

        file_name = os.path.join(os.getcwd(),'bcs','BC_'+boundary_name+'_'+var_name+'.bin')
        prescribe_vec_grid.ravel(order='C').astype('>f4').tofile(file_name)

    print(' - Creating the mask for the ' + boundary_name + ' boundary')
    prescribe_vec_mask = np.zeros(regional_domain_shape)
    counter = 1
    for layer in range(layers):
        # note: layers were made outside in
        if boundary_name == 'west':
            for n in range(N):
                prescribe_vec_mask[n, layer] = counter
                counter += 1
        if boundary_name == 'south':
            for n in range(N):
                prescribe_vec_mask[layer, n] = counter
                counter += 1
        if boundary_name == 'east':
            for n in range(N):
                prescribe_vec_mask[n, -layer-1] = counter
                counter += 1
        if boundary_name == 'north':
            for n in range(N):
                prescribe_vec_mask[-layer-1, n] = counter
                counter += 1
    print('    - The mask has shape '+str(np.shape(prescribe_vec_mask))+' with '+str(np.sum(prescribe_vec_mask!=0))+' points')
    file_name = os.path.join(os.getcwd(), 'bcs', 'BC_' + boundary_name + '.bin')
    prescribe_vec_mask.ravel(order='C').astype('>f4').tofile(file_name)
