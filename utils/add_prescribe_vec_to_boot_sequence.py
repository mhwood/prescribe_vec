
import os
import argparse
import shutil

def add_new_lines(lines,indicator,skip_line,add_lines):
    for ll in range(len(lines)):
        line = lines[ll]
        if line[:len(indicator)] == indicator:
            line_split_number = ll + skip_line + 1
    new_lines = lines[:line_split_number] + add_lines + lines[line_split_number:]
    return(new_lines)

def update_PARAMS(inc_dir,code_dir):
    print('Adding code to PARAMS.h')
    if 'PARAMS.h' not in os.listdir(code_dir):
        shutil.copyfile(os.path.join(inc_dir, 'PARAMS.h'),
                         os.path.join(code_dir, 'PARAMS.h'))

    f = open(os.path.join(code_dir, 'PARAMS.h'))
    lines = f.read()
    f.close()
    if 'Prescribe_vec' in lines:
        print('    Prescribe_vec has already been added to PARAMS.h')
        add_lines = False
    else:
        lines = lines.split('\n')
        add_lines = True

    if add_lines:
        # add the note to the chain
        indicator = '      LOGICAL useOBCS'
        skip_line = 0
        add_lines = ['      LOGICAL usePrescribe_vec']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        # add the note to the chain
        indicator = '     &        useGAD, useOBCS, useSHAP_FILT, useZONAL_FILT,'
        skip_line = 0
        add_lines = ['     &        usePrescribe_vec,']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        output = '\n'.join(lines)
        g = open(os.path.join(code_dir,'PARAMS.h'),'w')
        g.write(output)
        g.close()

def update_packages_boot(src_dir,code_dir):
    print('Adding code to packages_boot.F')
    if 'packages_boot.F' not in os.listdir(code_dir):
        shutil.copyfile(os.path.join(src_dir, 'packages_boot.F'),
                         os.path.join(code_dir, 'packages_boot.F'))

    f = open(os.path.join(code_dir, 'packages_boot.F'))
    lines = f.read()
    f.close()
    if 'Prescribe_vec' in lines:
        print('    Prescribe_vec has already been added to packages_boot.F')
        add_lines = False
    else:
        lines = lines.split('\n')
        add_lines = True


    if add_lines:
        # add the note to the chain
        indicator = '     &          useOBCS,'
        skip_line = 0
        add_lines = ['     &          usePrescribe_vec,']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        # add the note to the chain
        indicator = '      useOBCS         =.FALSE.'
        skip_line = 0
        add_lines = ['      usePrescribe_vec =.FALSE.']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        # add the check code
        indicator = '      CALL PACKAGES_PRINT_MSG( useOBCS'
        skip_line = 1
        add_lines = ['#ifdef ALLOW_PRESCRIBE_VEC',
                     '      CALL PACKAGES_PRINT_MSG( usePrescribe_vec,\'PRESCRIBE_VEC\',\' \' )',
                     '#endif']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        output = '\n'.join(lines)
        g = open(os.path.join(code_dir,'packages_boot.F'),'w')
        g.write(output)
        g.close()

def update_packages_check(src_dir,code_dir):
    print('Adding code to packages_check.F')
    if 'packages_check.F' not in os.listdir(code_dir):
        if 'packages_check.F' not in os.listdir(code_dir):
            shutil.copyfile(os.path.join(src_dir, 'packages_check.F'),
                             os.path.join(code_dir, 'packages_check.F'))

    f = open(os.path.join(code_dir, 'packages_check.F'))
    lines = f.read()
    f.close()
    if 'Prescribe_vec' in lines:
        print('    Prescribe_vec has already been added to packages_check.F')
        add_lines = False
    else:
        lines = lines.split('\n')
        add_lines = True


    if add_lines:

        # add the note to the chain
        indicator = 'C       |-- OBCS_CHECK'
        skip_line = 1
        add_lines = ['C       |-- PRESCRIBE_VEC_CHECK','C       |']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        # add the check code
        indicator = '      IF (useOBCS) CALL PACKAGES_ERROR_MSG(\'OBCS\',\' \',myThid)'
        skip_line = 1
        add_lines = ['',
                     '#ifdef ALLOW_PRESCRIBE_VEC',
                     '      IF (usePrescribe_vec) CALL PRESCRIBE_VEC_CHECK( myThid )',
                     '#else',
                     '      IF (usePrescribe_vec)',
                     '     & CALL PACKAGES_ERROR_MSG(\'PRESCRIBE_VEC\',\' \',myThid)',
                     '#endif']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        output = '\n'.join(lines)
        g = open(os.path.join(code_dir,'packages_check.F'),'w')
        g.write(output)
        g.close()

def update_packages_init_fixed(src_dir,code_dir):
    print('Adding code to packages_init_fixed.F')
    if 'packages_init_fixed.F' not in os.listdir(code_dir):
        if 'packages_init_fixed.F' not in os.listdir(code_dir):
            shutil.copyfile(os.path.join(src_dir, 'packages_init_fixed.F'),
                             os.path.join(code_dir, 'packages_init_fixed.F'))

    f = open(os.path.join(code_dir, 'packages_init_fixed.F'))
    lines = f.read()
    f.close()
    if 'Prescribe_vec' in lines:
        print('    Prescribe_vec has already been added to packages_init_fixed.F')
        add_lines = False
    else:
        lines = lines.split('\n')
        add_lines = True

    if add_lines:

        # add the note to the chain
        indicator = 'C       |-- OBCS_INIT_FIXED'
        skip_line = 1
        add_lines = ['C       |-- PRESCRIBE_VEC_INIT_FIXED','C       |']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        # add the check code
        indicator = '        CALL OBCS_INIT_FIXED( myThid )'
        skip_line = 2
        add_lines = ['',
                     'C--   Initialize fixed arrays for ALLOW_PRESCRIBE_VEC',
                     '#ifdef ALLOW_PRESCRIBE_VEC',
                     '      IF (usePrescribe_vec) THEN',
                     '# ifdef ALLOW_DEBUG',
                     '        IF (debugMode)',
                     '     & CALL DEBUG_CALL(\'PRESCRIBE_VEC_INIT_FIXED\',myThid)',
                     '# endif',
                     '        CALL PRESCRIBE_VEC_INIT_FIXED( myThid )',
                     '      ENDIF',
                     '#endif',]
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        output = '\n'.join(lines)
        g = open(os.path.join(code_dir,'packages_init_fixed.F'),'w')
        g.write(output)
        g.close()

def update_packages_init_variables(src_dir,code_dir):
    print('Adding code to packages_init_variables.F')
    if 'packages_init_variables.F' not in os.listdir(code_dir):
        if 'packages_init_variables.F' not in os.listdir(code_dir):
            shutil.copyfile(os.path.join(src_dir, 'packages_init_variables.F'),
                             os.path.join(code_dir, 'packages_init_variables.F'))
    f = open(os.path.join(code_dir, 'packages_init_variables.F'))
    lines = f.read()
    f.close()
    if 'Prescribe_vec' in lines:
        print('    Prescribe_vec has already been added to packages_init_variables.F')
        add_lines = False
    else:
        lines = lines.split('\n')
        add_lines = True


    if add_lines:

        # add the note to the chain
        indicator = 'C       |-- OBCS_INIT_VARIABLES'
        skip_line = 0
        add_lines = ['C       |','C       |-- PRESCRIBE_VEC_INIT_VARIA']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        # add the check code
        indicator = '        CALL OBCS_INIT_VARIABLES( myThid )'
        skip_line = 2
        add_lines = ['',
                     '#ifdef ALLOW_PRESCRIBE_VEC',
                     '      IF (usePrescribe_vec) THEN',
                     '# ifdef ALLOW_DEBUG',
                     '        IF (debugMode)',
                     '     & CALL DEBUG_CALL(\'PRESCRIBE_VEC_INIT_VARIA\',myThid)',
                     '# endif',
                     '        CALL PRESCRIBE_VEC_INIT_VARIA( myThid )',
                     '      ENDIF',
                     '#endif',]
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        output = '\n'.join(lines)
        g = open(os.path.join(code_dir,'packages_init_variables.F'),'w')
        g.write(output)
        g.close()

def update_packages_readparms(src_dir,code_dir):
    print('Adding code to packages_readparms.F')
    if 'packages_readparms.F' not in os.listdir(code_dir):
        shutil.copyfile(os.path.join(src_dir, 'packages_readparms.F'),
                         os.path.join(code_dir, 'packages_readparms.F'))

    f = open(os.path.join(code_dir, 'packages_readparms.F'))
    lines = f.read()
    f.close()
    if 'Prescribe_vec' in lines:
        print('    Prescribe_vec has already been added to packages_readparms.F')
        add_lines = False
    else:
        lines = lines.split('\n')
        add_lines = True


    if add_lines:

        # add the note to the chain
        indicator = 'C       |-- OBCS_READPARMS'
        skip_line = 0
        add_lines = ['C       |','C       |-- PRESCRIBE_VEC_READPARMS']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        # add the check code
        indicator = '      CALL OBCS_READPARMS( myThid )'
        skip_line = 1
        add_lines = ['',
                     '#ifdef ALLOW_PRESCRIBE_VEC',
                     'C--   if usePrescribe_vec=T, set PRESCRIBE_VEC parameters; otherwise just return',
                     '      CALL PRESCRIBE_VEC_READPARMS( myThid )',
                     '#endif']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        output = '\n'.join(lines)
        g = open(os.path.join(code_dir,'packages_readparms.F'),'w')
        g.write(output)
        g.close()

def edit_model_files(mitgcm_dir,config_dir):

    inc_dir = os.path.join(mitgcm_dir,'model','inc')
    src_dir = os.path.join(mitgcm_dir,'model','src')
    code_dir = os.path.join(config_dir,'code')

    update_PARAMS(inc_dir,code_dir)

    update_packages_boot(src_dir,code_dir)

    update_packages_check(src_dir,code_dir)

    update_packages_init_fixed(src_dir,code_dir)

    update_packages_init_variables(src_dir,code_dir)

    update_packages_readparms(src_dir,code_dir)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument("-m", "--mitgcm_dir", action="store",
                        help="Path to the main directory of the MITgcm clone.", dest="mitgcm_dir",
                        type=str, required=True)
    parser.add_argument("-c", "--config_dir", action="store",
                        help="Path to the directory where the configuration is stored.", dest="config_dir",
                        type=str, required=True)

    args = parser.parse_args()
    mitgcm_dir = args.mitgcm_dir
    config_dir = args.config_dir

    edit_model_files(mitgcm_dir,config_dir)
