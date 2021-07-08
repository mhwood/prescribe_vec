## prescribe_vec: A targeted prescription package for [MITgcm](https://github.com/MITgcm/MITgcm)

Author: Michael Wood

## Package Purpose and Motivation
Here, we design a flexible model package which is capable of prescribing model variables in any subset of the model domain e.g. along a vector (or "vec"). 

## Getting Started
The purpose of this repository is to provide a convenient way to merge new package files into MITgcm. To faciliate this merge, there are two convenient scripts provided in the [utils](https://github.com/mhwood/prescribe_vec/tree/main/utils) directory. To start, clone this repository into a convenient drive on your machine. Then, `cd` to the utils directory and run the following code from the command line, passing the path to a (preferrably fresh) clone of the main branch of the MITgcm:
```
python3 copy_pkg_files_to_MITgcm.py -m /path/to/MITgcm_fresh
```
This code will add the ```prescribe_vec``` package files into the pkg directory. In addition, there are a number of ```src``` scripts which must be edited to include the package. For a particular configuration, these edits can be carried out using the following script:
```
python3 edit_src_files_for_config.py -m /path/to/MITgcm_fresh -c /path/to/model/config
```
The edited ```src``` files will be stored in the configuration's code directory.
