`global_with_exf` (with `prescribe_vec`)

This experiment will demonstrate how `prescribe_vec` can be used to prescribe boundary conditions on a regional model. In particular, a regional model will be used to replicate the results of a global model as designed in the verification experiment `global_with_exf`.

Begin by creating a directory in your clone of MITgcm and copying over this directory:
```
cd MITgcm
mkdir configurations/
cd configurations
cp -r /path/to/prescribe_vec/example_configurations/global_with_exf .
cd global_with_exf
```
