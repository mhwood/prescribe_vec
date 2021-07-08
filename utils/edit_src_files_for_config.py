
import os
import argparse

def add_new_lines(lines,indicator,skip_line,add_lines):
    for ll in range(len(lines)):
        line = lines[ll]
        if line[:len(indicator)] == indicator:
            line_split_number = ll + skip_line + 1
    new_lines = lines[:line_split_number] + add_lines + lines[line_split_number:]
    return(new_lines)

def update_PARAMS(inc_dir,code_dir):
    print('Adding code to PARAMS.h')
    if 'PARAMS.h' in os.listdir(code_dir):
        f = open(os.path.join(code_dir, 'PARAMS.h'))
        lines = f.read()
        f.close()
        if 'Prescribe_vec' in lines:
            print('    Prescribe_vec has already been added to PARAMS.h')
            add_lines = False
        else:
            lines = lines.split('\n')
            add_lines = True
    else:
        f = open(os.path.join(inc_dir, 'PARAMS.h'))
        lines = f.read()
        f.close()
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
    if 'packages_boot.F' in os.listdir(code_dir):
        f = open(os.path.join(code_dir, 'packages_boot.F'))
        lines = f.read()
        f.close()
        if 'Prescribe_vec' in lines:
            print('    Prescribe_vec has already been added to packages_boot.F')
            add_lines = False
        else:
            lines = lines.split('\n')
            add_lines = True
    else:
        f = open(os.path.join(src_dir, 'packages_boot.F'))
        lines = f.read()
        f.close()
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
    if 'packages_check.F' in os.listdir(code_dir):
        f = open(os.path.join(code_dir, 'packages_check.F'))
        lines = f.read()
        f.close()
        if 'Prescribe_vec' in lines:
            print('    Prescribe_vec has already been added to packages_check.F')
            add_lines = False
        else:
            lines = lines.split('\n')
            add_lines = True
    else:
        f = open(os.path.join(src_dir, 'packages_check.F'))
        lines = f.read()
        f.close()
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
    if 'packages_init_fixed.F' in os.listdir(code_dir):
        f = open(os.path.join(code_dir, 'packages_init_fixed.F'))
        lines = f.read()
        f.close()
        if 'Prescribe_vec' in lines:
            print('    Prescribe_vec has already been added to packages_init_fixed.F')
            add_lines = False
        else:
            lines = lines.split('\n')
            add_lines = True
    else:
        f = open(os.path.join(src_dir, 'packages_init_fixed.F'))
        lines = f.read()
        f.close()
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
    if 'packages_init_variables.F' in os.listdir(code_dir):
        f = open(os.path.join(code_dir, 'packages_init_variables.F'))
        lines = f.read()
        f.close()
        if 'Prescribe_vec' in lines:
            print('    Prescribe_vec has already been added to packages_init_variables.F')
            add_lines = False
        else:
            lines = lines.split('\n')
            add_lines = True
    else:
        f = open(os.path.join(src_dir, 'packages_init_variables.F'))
        lines = f.read()
        f.close()
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
    if 'packages_readparms.F' in os.listdir(code_dir):
        f = open(os.path.join(code_dir, 'packages_readparms.F'))
        lines = f.read()
        f.close()
        if 'Prescribe_vec' in lines:
            print('    Prescribe_vec has already been added to packages_readparms.F')
            add_lines = False
        else:
            lines = lines.split('\n')
            add_lines = True
    else:
        f = open(os.path.join(src_dir, 'packages_readparms.F'))
        lines = f.read()
        f.close()
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

def update_dynamics(src_dir,code_dir):
    print('Adding code to dynamics.F')
    if 'dynamics.F' in os.listdir(code_dir):
        f = open(os.path.join(code_dir, 'dynamics.F'))
        lines = f.read()
        f.close()
        if 'PRESCRIBE_VEC' in lines:
            print('    Prescribe_vec has already been added to dynamics.F')
            add_lines = False
        else:
            lines = lines.split('\n')
            add_lines = True
    else:
        f = open(os.path.join(src_dir, 'dynamics.F'))
        lines = f.read()
        f.close()
        lines = lines.split('\n')
        add_lines = True

    if add_lines:

        indicator = '          CALL OBCS_APPLY_UV( bi, bj, 0, gU, gV, myThid )'
        skip_line = 2
        add_lines = ['',
                     '#ifdef ALLOW_PRESCRIBE_VEC',
                     'C--   Prescribe GU and GV conditions',
                     '      IF (usePrescribe_vec) THEN',
                     '            CALL PRESCRIBE_VEC_PRESCRIBE_FIELD(\'GU\', ',
                     '     &                                         myTime, myIter, myThid)',
                     '            CALL PRESCRIBE_VEC_PRESCRIBE_FIELD(\'GV\',',
                     '     &                                         myTime, myIter, myThid)',
                     '      ENDIF',
                     '#endif /* ALLOW_PRESCRIBE_VEC */', ]
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        output = '\n'.join(lines)
        g = open(os.path.join(code_dir, 'dynamics.F'), 'w')
        g.write(output)
        g.close()

def update_forward_step(src_dir,code_dir):
    print('Adding code to forward_step.F')
    if 'forward_step.F' in os.listdir(code_dir):
        f = open(os.path.join(code_dir, 'forward_step.F'))
        lines = f.read()
        f.close()
        if 'PRESCRIBE_VEC' in lines:
            print('    Prescribe_vec has already been added to forward_step.F')
            add_lines = False
        else:
            lines = lines.split('\n')
            add_lines = True
    else:
        f = open(os.path.join(src_dir, 'forward_step.F'))
        lines = f.read()
        f.close()
        lines = lines.split('\n')
        add_lines = True

    if add_lines:
        indicator = '# include "OBCS_OPTIONS.h"'
        skip_line = 1
        add_lines = ['#ifdef ALLOW_PRESCRIBE_VEC',
                     '# include "PRESCRIBE_VEC_OPTIONS.h"',
                     '#endif']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        indicator = 'CEOP'
        skip_line = 0
        add_lines = ['',
                     '#ifdef ALLOW_PRESCRIBE_VEC',
                     '      CALL PRESCRIBE_VEC_READ_TS_FIELDS(myTime, myIter, myThid )',
                     '      CALL PRESCRIBE_VEC_READ_UV_FIELDS(0, myTime, myIter, myThid )',
                     '#endif']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)


        indicator = '        CALL TIMER_STOP (\'SOLVE_FOR_PRESSURE  [FORWARD_STEP]\',myThid)'
        skip_line = 1
        add_lines = ['',
                     '#ifdef ALLOW_PRESCRIBE_VEC',
                     '      CALL PRESCRIBE_VEC_READ_ETAN_FIELD(myTime, myIter, myThid )',
                     '#endif']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        indicator = '        CALL TIMER_STOP (\'INTEGR_CONTINUITY   [FORWARD_STEP]\',myThid)'
        skip_line = 6
        add_lines = ['',
                     '#ifdef ALLOW_PRESCRIBE_VEC',
                     '      CALL PRESCRIBE_VEC_READ_ETAN_FIELD(myTime, myIter, myThid )',
                     '#endif']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        output = '\n'.join(lines)
        g = open(os.path.join(code_dir, 'forward_step.F'), 'w')
        g.write(output)
        g.close()

def update_ini_depths(src_dir,code_dir):
    print('Adding code to ini_depths.F')
    if 'ini_depths.F' in os.listdir(code_dir):
        f = open(os.path.join(code_dir, 'ini_depths.F'))
        lines = f.read()
        f.close()
        if 'PRESCRIBE_VEC' in lines:
            print('    Prescribe_vec has already been added to ini_depths.F')
            add_lines = False
        else:
            lines = lines.split('\n')
            add_lines = True
    else:
        f = open(os.path.join(src_dir, 'ini_depths.F'))
        lines = f.read()
        f.close()
        lines = lines.split('\n')
        add_lines = True

    if add_lines:
        indicator = '      INTEGER  i, j'
        skip_line = 0
        add_lines = ['#ifdef ALLOW_PRESCRIBE_VEC',
                     '      INTEGER i_add, j_add',
                     '#endif']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        indicator = '#endif /* ALLOW_OBCS */'
        skip_line = 1
        add_lines = ['#ifdef ALLOW_PRESCRIBE_VEC',
                     '      IF ( usePrescribe_vec ) THEN',
                     'C     check for inconsistent topography along boundaries and fix it',
                     'C           Fill in the halo region if the point is on the boundary',
                     '      IF (i.eq.sNx) THEN',
                     '            DO i_add=1,OLx',
                     '                  R_low(i+i_add,j,bi,bj) = R_low(i,j,bi,bj)',
                     '            ENDDO',
                     '      ENDIF',
                     '      IF (i.eq.1) THEN',
                     '            DO i_add=1,OLx',
                     '                  R_low(i-i_add,j,bi,bj) = R_low(i,j,bi,bj)',
                     '            ENDDO',
                     '      ENDIF',
                     '      IF (j.eq.sNy) THEN',
                     '            DO j_add=1,OLy',
                     '                  R_low(i,j+j_add,bi,bj) = R_low(i,j,bi,bj)',
                     '            ENDDO',
                     '      ENDIF ',
                     '      IF (j.eq.1) THEN',
                     '            DO i_add=1,OLx',
                     '                  R_low(i,j-j_add,bi,bj) = R_low(i,j,bi,bj)',
                     '            ENDDO',
                     '      ENDIF',
                     '      ENDIF',
                     '#endif /* ALLOW_PRESCRIBE_VEC */',
                     '']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        output = '\n'.join(lines)
        g = open(os.path.join(code_dir, 'ini_depths.F'), 'w')
        g.write(output)
        g.close()

def update_momentum_correction_step(src_dir,code_dir):
    print('Adding code to momentum_correction_step.F')
    if 'momentum_correction_step.F' in os.listdir(code_dir):
        f = open(os.path.join(code_dir, 'momentum_correction_step.F'))
        lines = f.read()
        f.close()
        if 'PRESCRIBE_VEC' in lines:
            print('    Prescribe_vec has already been added to momentum_correction_step.F')
            add_lines = False
        else:
            lines = lines.split('\n')
            add_lines = True
    else:
        f = open(os.path.join(src_dir, 'momentum_correction_step.F'))
        lines = f.read()
        f.close()
        lines = lines.split('\n')
        add_lines = True

    if add_lines:
        indicator = '#endif /* ALLOW_OBCS */'
        skip_line = 1
        add_lines = ['#ifdef ALLOW_PRESCRIBE_VEC',
                     'C--   Prescribe UVEL and VVEL conditions',
                     '        IF ( usePrescribe_vec ) THEN',
                     '            CALL PRESCRIBE_VEC_PRESCRIBE_FIELD(\'UVEL\',',
                     '     &                                         myTime, myIter, myThid)',
                     '            CALL PRESCRIBE_VEC_PRESCRIBE_FIELD(\'VVEL\',',
                     '     &                                         myTime, myIter, myThid)',
                     '        ENDIF',
                     '#endif /* ALLOW_PRESCRIBE_VEC */',
                     '']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        output = '\n'.join(lines)
        g = open(os.path.join(code_dir, 'momentum_correction_step.F'), 'w')
        g.write(output)
        g.close()

def update_thermodynamics(src_dir,code_dir):
    print('Adding code to thermodynamics.F')
    if 'thermodynamics.F' in os.listdir(code_dir):
        f = open(os.path.join(code_dir, 'thermodynamics.F'))
        lines = f.read()
        f.close()
        if 'PRESCRIBE_VEC' in lines:
            print('    Prescribe_vec has already been added to thermodynamics.F')
            add_lines = False
        else:
            lines = lines.split('\n')
            add_lines = True
    else:
        f = open(os.path.join(src_dir, 'thermodynamics.F'))
        lines = f.read()
        f.close()
        lines = lines.split('\n')
        add_lines = True

    if add_lines:
        indicator = 'C--   end bi,bj loops.'
        skip_line = 3
        add_lines = ['#ifdef ALLOW_PRESCRIBE_VEC',
                     'C--   Prescribe THETA AND SALT conditions',
                     '        IF ( usePrescribe_vec ) THEN',
                     '            CALL PRESCRIBE_VEC_PRESCRIBE_FIELD(\'THETA\',',
                     '     &                                         myTime, myIter, myThid)',
                     '            CALL PRESCRIBE_VEC_PRESCRIBE_FIELD(\'SALT\',',
                     '     &                                         myTime, myIter, myThid)',
                     '        ENDIF',
                     '#endif /* ALLOW_PRESCRIBE_VEC */',
                     '']
        lines = add_new_lines(lines, indicator, skip_line, add_lines)

        output = '\n'.join(lines)
        g = open(os.path.join(code_dir, 'thermodynamics.F'), 'w')
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

    update_dynamics(src_dir, code_dir)

    update_forward_step(src_dir, code_dir)

    update_ini_depths(src_dir, code_dir)

    update_momentum_correction_step(src_dir, code_dir)

    update_thermodynamics(src_dir, code_dir)

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
