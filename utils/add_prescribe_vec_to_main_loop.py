
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



def update_forward_step(src_dir,code_dir):
    print('Adding code to forward_step.F')
    if 'forward_step.F' not in os.listdir(code_dir):
        shutil.copyfile(os.path.join(src_dir, 'forward_step.F'),
                         os.path.join(code_dir, 'forward_step.F'))

    f = open(os.path.join(code_dir, 'forward_step.F'))
    lines = f.read()
    f.close()
    if 'PRESCRIBE_VEC' in lines:
        print('    Prescribe_vec has already been added to forward_step.F')
        add_lines = False
    else:
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


def update_thermodynamics(src_dir,code_dir):
    print('Adding code to thermodynamics.F')
    if 'thermodynamics.F' not in os.listdir(code_dir):
        shutil.copyfile(os.path.join(src_dir, 'thermodynamics.F'),
                        os.path.join(code_dir, 'thermodynamics.F'))

    f = open(os.path.join(code_dir, 'thermodynamics.F'))
    lines = f.read()
    f.close()
    if 'PRESCRIBE_VEC' in lines:
        print('    Prescribe_vec has already been added to thermodynamics.F')
        add_lines = False
    else:
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


def update_dynamics(src_dir,code_dir):
    print('Adding code to dynamics.F')
    if 'dynamics.F' not in os.listdir(code_dir):
        shutil.copyfile(os.path.join(src_dir, 'dynamics.F'),
                        os.path.join(code_dir, 'dynamics.F'))

    f = open(os.path.join(code_dir, 'dynamics.F'))
    lines = f.read()
    f.close()
    if 'PRESCRIBE_VEC' in lines:
        print('    Prescribe_vec has already been added to dynamics.F')
        add_lines = False
    else:
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


def update_momentum_correction_step(src_dir,code_dir):
    print('Adding code to momentum_correction_step.F')
    if 'momentum_correction_step.F' not in os.listdir(code_dir):
        shutil.copyfile(os.path.join(src_dir, 'momentum_correction_step.F'),
                        os.path.join(code_dir, 'momentum_correction_step.F'))

    f = open(os.path.join(code_dir, 'momentum_correction_step.F'))
    lines = f.read()
    f.close()
    if 'PRESCRIBE_VEC' in lines:
        print('    Prescribe_vec has already been added to momentum_correction_step.F')
        add_lines = False
    else:
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


def edit_model_files(mitgcm_dir,config_dir):

    inc_dir = os.path.join(mitgcm_dir,'model','inc')
    src_dir = os.path.join(mitgcm_dir,'model','src')
    code_dir = os.path.join(config_dir,'code')

    update_forward_step(src_dir, code_dir)

    update_thermodynamics(src_dir, code_dir)

    update_dynamics(src_dir, code_dir)

    update_momentum_correction_step(src_dir, code_dir)


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
