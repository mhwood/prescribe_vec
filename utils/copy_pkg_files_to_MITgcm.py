
import os
import argparse
import shutil

def add_pkg(mitgcm_dir):

    pkg_dir = os.path.join(mitgcm_dir,'pkg')

    if 'prescribe_vec' in os.listdir(pkg_dir):
        shutil.rmtree(os.path.join(mitgcm_dir,'pkg','prescribe_vec'))

    os.mkdir(os.path.join(mitgcm_dir,'pkg','prescribe_vec'))

    for file_name in os.listdir(os.path.join('..','pkg','prescribe_vec')):
        if 'prescribe' in file_name or 'PRESCRIBE' in file_name:
            shutil.copyfile(os.path.join('..','pkg','prescribe_vec',file_name),
                            os.path.join(pkg_dir,'prescribe_vec',file_name))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument("-m", "--mitgcm_dir", action="store",
                        help="Path to the main directory of the MITgcm clone.", dest="mitgcm_dir",
                        type=str, required=True)

    args = parser.parse_args()
    mitgcm_dir = args.mitgcm_dir

    add_pkg(mitgcm_dir)
