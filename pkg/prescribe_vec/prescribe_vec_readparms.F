C----&------------------------------------------------------------------xxxxxxx|
C                         prescribe_vec_readparms
C----&------------------------------------------------------------------xxxxxxx|

#include "PRESCRIBE_VEC_OPTIONS.h"

CBOP
C     !ROUTINE: PRESCRIBE_VEC_READPARMS
C     !INTERFACE:
      SUBROUTINE PRESCRIBE_VEC_READPARMS( myThid )

C     !DESCRIPTION: \bv
C     *==========================================================*
C     | SUBROUTINE PRESCRIBE_VEC_READPARMS
C     | o Routine to initialize PRESCRIBE_VEC variables and constants.
C     *==========================================================*
C     \ev

C     !USES:
      IMPLICIT NONE
C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "PRESCRIBE_VEC.h"

C     !INPUT/OUTPUT PARAMETERS:
C     === Routine arguments ===
      INTEGER myThid

#ifdef ALLOW_PRESCRIBE_VEC

C     !LOCAL VARIABLES:
C     === Local variables ===
C     msgBuf       :: Informational/error message buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER, PARAMETER :: debug = 1
      INTEGER n, m, p
      INTEGER iUnit

      
CEOP
C----&------------------------------------------------------------------xxxxxxx|
CBOC

C----&------------------------------------------------------------------xxxxxxx|
C     Define the prescribe_vec variables (used in data.prescribe_vec)
C----&------------------------------------------------------------------xxxxxxx|
      
      CHARACTER*30 nml_fname_prefixes(nVEC_masks)
      CHARACTER*30 nml_depth_cell_fnames(N_VEC_FIELDS,nVEC_masks)
      CHARACTER*30 nml_relax_time_fnames(nVEC_masks)
      CHARACTER*30 nml_relax_mask_fnames(nVEC_masks)
      CHARACTER*8 nml_fields(N_VEC_FIELDS, nVEC_masks)
      INTEGER nml_levels(N_VEC_FIELDS, nVEC_masks)
      INTEGER nml_filePrec
      INTEGER nml_nTimesteps
      LOGICAL nml_fields_include_ICs
      LOGICAL nml_field_is_constant

      NAMELIST / PRESCRIBE_VEC_PARM01 /
     &     nml_fname_prefixes,
     &     nml_depth_cell_fnames,
     &     nml_relax_time_fnames, nml_relax_mask_fnames,
     &     nml_fields,
     &     nml_levels,
     &     nml_filePrec,
     &     nml_nTimesteps,
     &     nml_fields_include_ICs,
     &     nml_field_is_constant


      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN PRESCRIBE_VEC_READPARMS DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C----&------------------------------------------------------------------xxxxxxx|
C     Provide a weak warning if data.prescribe_vec is found but
C     useDiagnostics_vec is not activated in data.pkg
C----&------------------------------------------------------------------xxxxxxx|


      IF ( .NOT.usePRESCRIBE_VEC ) THEN
        _BEGIN_MASTER(myThid)
         CALL PACKAGES_UNUSED_MSG( 'usePRESCRIBE_VEC', ' ', ' ' )
        _END_MASTER(myThid)
        RETURN
      ENDIF

      _BEGIN_MASTER(myThid)

C----&------------------------------------------------------------------xxxxxxx|
C -- Define the default values for variables in data.prescribe_vec
C----&------------------------------------------------------------------xxxxxxx|

C --   Local default flags and values for PRESCRIBE_VEC

      DO n=1,N_VEC_FIELDS
            DO m=1,nVEC_masks
                  nml_fields(n,m) = ' '
                  nml_depth_cell_fnames(n,m) = ' '
                  nml_levels(n, m) = 1
            ENDDO
      ENDDO

      DO m=1,nVEC_masks
            nml_fname_prefixes(m) = ' '
            nml_relax_time_fnames(m) = ' '
            nml_relax_mask_fnames(m) = ' '
      ENDDO

      nml_filePrec  = 64
      nml_nTimesteps = 0
      nml_fields_include_ICs = .FALSE.
      nml_field_is_constant = .FALSE.


C----&------------------------------------------------------------------xxxxxxx|

C     Open and read the data.prescribe_VEC file
      WRITE(msgBuf,'(A)') ' PRESCRIBE_VEC_READPARMS:'
      WRITE(msgBuf,'(A)') ' opening data.prescribe_vec'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , myThid )
      CALL OPEN_COPY_DATA_FILE(
     I                          'data.prescribe_vec',
     I                          'PRESCRIBE_VEC_READPARMS',
     O                          iUnit,
     I                          myThid )

C--   Read parameters from open data file
      READ(UNIT=iUnit,NML=PRESCRIBE_VEC_PARM01)

      WRITE(msgBuf,'(A)') ' PRESCRIBE_VEC_READPARMS:'
      WRITE(msgBuf,'(A)') ' finished reading data.prescribe_vec'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , myThid )

C--   Close the open data file
#ifdef SINGLE_DISK_IO
      CLOSE(iUnit)
#else
      CLOSE(iUnit,STATUS='DELETE')
#endif /* SINGLE_DISK_IO */

C----&------------------------------------------------------------------xxxxxxx|
C     Fill PRESCRIBE_VEC.h COMMON Block with information provided by
C     data.diagnostics_vec
C----&------------------------------------------------------------------xxxxxxx|

      DO n=1,N_VEC_FIELDS
            DO m=1,nVEC_masks
              vec_flds(n, m) = nml_fields(n, m)
              vec_depth_cell_fnames(n, m) = 
     &             nml_depth_cell_fnames(n, m)
              if (nml_fields(n,m) .ne. ' ') then
                vec_nFlds(m) = vec_nFlds(m) + 1
              endif
              vec_levels(n, m) = nml_levels(n,m)
C              print *, 'vec_levels(',n,',',m,')',vec_levels(n, m)
            ENDDO
      ENDDO

      DO m=1,nVEC_masks
            vec_fname_prefixes(m) = nml_fname_prefixes(m)
            vec_relax_time_fnames(m) = nml_relax_time_fnames(m)
            vec_relax_mask_fnames(m) = nml_relax_mask_fnames(m)
      ENDDO

      vec_filePrec  = nml_filePrec
      nTimesteps_vec = nml_nTimesteps
      vec_fields_include_ICs = nml_fields_include_ICs
      vec_field_is_constant = nml_field_is_constant

C----&------------------------------------------------------------------xxxxxxx|
C     Fill PRESCRIBE_VEC.h COMMON Block with some default namelist 
C          values that have not yet been implemented
C----&------------------------------------------------------------------xxxxxxx|

      prescribe_in_forward_step = .TRUE.

C----&------------------------------------------------------------------xxxxxxx|
C     Print out the parameters read in by the above code
C----&------------------------------------------------------------------xxxxxxx|

      if (debug .eq. 1) then
      DO m=1,nVEC_masks
      WRITE(msgBuf,'(A,A,A,I2,A)') "For mask ",vec_fname_prefixes(m),
     &                        ', identified ',vec_nFlds(m),' fields:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      DO n=1,N_VEC_FIELDS
      WRITE(msgBuf,'(A,A)') "    ",vec_flds(n, m)
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      ENDDO
      ENDDO
      endif

! C----&------------------------------------------------------------------xxxxxxx|

      _END_MASTER(myThid)
C--   Everyone else must wait for the parameters to be loaded

      _BARRIER

#endif /* ALLOW_PRESCRIBE_VEC */

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END PRESCRIBE_VEC_READPARMS DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      RETURN
      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|