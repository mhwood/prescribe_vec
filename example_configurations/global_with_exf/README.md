# `global_with_exf` (with `prescribe_vec`)

This experiment will demonstrate how `prescribe_vec` can be used to prescribe boundary conditions on a regional model. In particular, a regional model will be used to replicate the results of a global model as designed in the verification experiment `global_with_exf`.

Begin by creating a repository for this project and cloning the following repositories:
```
git clone https://github.com/MITgcm/MITgcm.git
git clone https://github.com/mhwood/diagnostics_vec.git
git clone https://github.com/mhwood/prescribe_vec.git # this repo
```

Then, add `diagnostics_vec` to your clone of MITgcm using the `diagnostics_vec` `utils`:
```
cd diagnostics_vec/utils
python3 copy_pkg_files_to_MITgcm.py -m ../../MITgcm
cd ../../
```

Next, create a directory in your clone of MITgcm and copying over this example directory:
```
cd MITgcm
mkdir configurations/
cd configurations
cp -r /path/to/prescribe_vec/example_configurations/global_with_exf .
cd global_with_exf
```

## The Global Model
In the first part of this example, we run the global model forward for 30 days. This simulation is nearly identical to the verification experiment provided with MITgcm except that it uses the `diagnostics_vec` package to output the boundary conditions to be used for the subdomain. Accordingly, the code and input directories only have 6 files which differ from the verification experiement:
1. code/packages.conf - diagnostics_vec is added
2. code/SIZE.h (this experiment runs with mpi)
3. input/data (modified to run for 1 month with deltaT = 1200 s)
4. input/data.pkg - useDiagnostics_vec is set to .TRUE.
5. input/data.exf
6. prepare_run

In addition, there are 3 new files associated with the diagnostics_vec package:
1. code/DIAGNOSTICS_VEC_SIZE.h
2. input/data.diagnostics_vec
3. input/create_dv_masks.py

To create the setup, first run the `prepare_run` script to collect all of the code and input files from the core tutorial. Note that this scripts expects the `prescribe_vec` and `MITgcm` clones (from above) to be in the same directory.
```
cd global/input
bash prepare_run
python3 create_dv_masks.py
cd ..
```
If you would like to view the locations of the `diagnostics_vec` masks used for boundary output, use the global_config notebook provided in the notebooks directory.

:exclamation: Note: If you use a `conda` environment, be sure to deactivate it in your terminal before building and running the model.

Next, build the model according to the specifications on your machine. For example:
```
mkdir build
cd build
../../../../../MITgcm/tools/genmake2 -mods ../code -mpi -optfile ../../../../../MITgcm/tools/build_options/darwin_amd64_gfortran -rootdir ../../../../../MITgcm
make depend
make
cd ..
```
Note that this configuration requires MPI. If you prefer not to use MPI, then reconfigure accordingly.

Then, run the global experiment:
```
mkdir run
cd run
mkdir diags
mkdir diags/diagsEXF
mkdir diags/diagsDyn
cp -r ../input/dv .
ln -s ../input/* .
mpirun -np 2 ../build/mitgcmuv
cd ..
```

## The Regional Model
Next, the output from the global model will be used to prescribe the external forcing and boundary conditions for the regional model. First, we will create the regional model fields in the following steps:

1. Subset bathymetry and hydography fields from the global to regional domain; create exf conditions
2. Create boundary conditions from the global model output to be applied with the prescribe_vec package
3. Copy unchanged files from the core tutorial
There are three convenient scripts in the regional/input directory which carry out the steps above:
```
cd ../regional/input
python3 subset_regional_fields.py
python3 create_pv_files.py
bash prepare_run
```
If you would like to view the locations of the `prescribe_vec` masks used for boundary conditions, use the regional_config notebook provided in the notebooks directory.

Before buliding the model, we will add the `prescribe_vec` package to the boot sequence and the main loop using the following scripts:
```
cd ../../../../../prescribe_vec/utils
python3 add_prescribe_vec_to_boot_sequence.py -m ../../MITgcm -c ../../MITgcm/configurations/global_with_exf/regional
python3 add_prescribe_vec_to_main_loop.py -m ../../MITgcm -c ../../MITgcm/configurations/global_with_exf/regional
cd ../../MITgcm/configurations/global_with_exf/regional
```
Note that the code directory now has new files for the book sequence and the main loop.

Now, build the model as was done for the regional model:
```
mkdir build
cd build
../../../../../MITgcm/tools/genmake2 -mods ../code -mpi -optfile ../../../../../MITgcm/tools/build_options/darwin_amd64_gfortran -rootdir ../../../../../MITgcm
make depend
make
cd ..
```

Finally, run the regional model:
```
mkdir run
cd run
mkdir diags
mkdir diags/diagsDyn
ln -s ../input/* .
ln -s ../input/bcs/*.bin .
mpirun -np 4 ../build/mitgcmuv
cd ..
```

To compare the output of the regional model with the output of the global model, us the global_vs_regional notebook. 
