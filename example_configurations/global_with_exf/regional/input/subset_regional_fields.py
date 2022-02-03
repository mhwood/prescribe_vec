
import os
import matplotlib.pyplot as plt
import numpy as np
import shutil

domain_shape = (40,90)
min_row = 10
max_row = 29
min_col= 25
max_col = 64
Nr = 15

print('Subsetting files...')

print('   - bathymetry.bin')
global_bathy_file = os.path.join('..','..','global','input','bathymetry.bin')
global_bathy = np.fromfile(global_bathy_file,'>f4')
global_bathy = np.reshape(global_bathy,(domain_shape[0],domain_shape[1]))
regional_bathy = global_bathy[min_row:max_row+1,min_col:max_col+1]
regional_bathy_file = os.path.join(os.getcwd(),'bathymetry.bin')
regional_bathy.ravel(order='C').astype('>f4').tofile(regional_bathy_file)

print('   - lev_sst.bin')
global_sst_file = os.path.join('..','..','global','input','lev_sst.bin')
global_sst = np.fromfile(global_sst_file,'>f4')
global_sst = np.reshape(global_sst,(12, domain_shape[0],domain_shape[1]))
regional_sst = global_sst[:,min_row:max_row+1,min_col:max_col+1]
regional_sst_file = os.path.join(os.getcwd(),'lev_sst.bin')
regional_sst.ravel(order='C').astype('>f4').tofile(regional_sst_file)

print('   - lev_sss.bin')
global_sss_file = os.path.join('..','..','global','input','lev_sss.bin')
global_sss = np.fromfile(global_sss_file,'>f4')
global_sss = np.reshape(global_sss,(12, domain_shape[0],domain_shape[1]))
regional_sss = global_sss[:,min_row:max_row+1,min_col:max_col+1]
regional_sss_file = os.path.join(os.getcwd(),'lev_sss.bin')
regional_sss.ravel(order='C').astype('>f4').tofile(regional_sss_file)

print('   - lev_t.bin')
global_t_file = os.path.join('..','..','global','input','lev_t.bin')
global_t = np.fromfile(global_t_file,'>f4')
global_t = np.reshape(global_t,(12, Nr, domain_shape[0],domain_shape[1]))
regional_t = global_t[:,:,min_row:max_row+1,min_col:max_col+1]
regional_t_file = os.path.join(os.getcwd(),'lev_t.bin')
regional_t.ravel(order='C').astype('>f4').tofile(regional_t_file)

print('   - lev_s.bin')
global_s_file = os.path.join('..','..','global','input','lev_s.bin')
global_s = np.fromfile(global_s_file,'>f4')
global_s = np.reshape(global_s,(12, Nr, domain_shape[0],domain_shape[1]))
regional_s = global_s[:,:,min_row:max_row+1,min_col:max_col+1]
regional_s_file = os.path.join(os.getcwd(),'lev_s.bin')
regional_s.ravel(order='C').astype('>f4').tofile(regional_s_file)

print('   - exf_HFLUX.bin (generated with diagnostics_vec)')
global_hflux_file = os.path.join('..','..','global','run','dv','surface_mask_HFLUX.bin')
region_hflux_file = os.path.join(os.getcwd(),'exf_HFLUX.bin')
shutil.copyfile(global_hflux_file,region_hflux_file)

print('   - exf_SFLUX.bin (generated with diagnostics_vec)')
global_sflux_file = os.path.join('..','..','global','run','dv','surface_mask_SFLUX.bin')
region_sflux_file = os.path.join(os.getcwd(),'exf_SFLUX.bin')
shutil.copyfile(global_sflux_file,region_sflux_file)

print('   - exf_USTRESS.bin (generated with diagnostics_vec)')
global_ustress_file = os.path.join('..','..','global','run','dv','surface_mask_USTRESS.bin')
region_ustress_file = os.path.join(os.getcwd(),'exf_USTRESS.bin')
shutil.copyfile(global_ustress_file,region_ustress_file)

print('   - exf_VSTRESS.bin (generated with diagnostics_vec)')
global_vstress_file = os.path.join('..','..','global','run','dv','surface_mask_VSTRESS.bin')
region_vstress_file = os.path.join(os.getcwd(),'exf_VSTRESS.bin')
shutil.copyfile(global_vstress_file,region_vstress_file)






