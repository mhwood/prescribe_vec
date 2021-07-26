C------------------------------------------------------------------------------|
C                           prescribe_vec_read_fields
C------------------------------------------------------------------------------|

#include "PRESCRIBE_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: PRESCRIBE_VEC_READ_FIELDS

C !INTERFACE:
      SUBROUTINE PRESCRIBE_VEC_READ_ETAN_FIELD(myTime, 
     &                                       myIter, myThid )

C     !DESCRIPTION:
C     Initialize PRESCRIBE_VEC ETAN variable

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "GRID.h"
#include "PRESCRIBE_VEC.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid
      _RL     myTime
      INTEGER myIter
      

C     !LOCAL VARIABLES:
C      INTEGER i,j,k,l, bi,bj
      INTEGER, PARAMETER :: debug = 1
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER vec_id, i, f, n
      INTEGER fld_name_len
      INTEGER mask_name_len
      CHARACTER*50 field_file_name
      INTEGER iRecord
      LOGICAL continue_to_read

CEOP
C------------------------------------------------------------------------------|
CBOC

#ifdef ALLOW_PRESCRIBE_VEC

      IF (vec_field_is_constant) THEN 
C           Plus one here b/c etan is read after the iter is incremented 
C           in forward_step
            IF (myIter.gt.nIter0+1) THEN 
                  continue_to_read = .FALSE.
            ELSE
                  continue_to_read = .TRUE.
            ENDIF
      ELSE
            continue_to_read = .TRUE.
      ENDIF

      IF (continue_to_read) THEN

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') " BEGIN PRESCRIBE_VEC_READ_ETAN_FIELD DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C------------------------------------------------------------------------------|

C     In this code, we 
C        1 - loop through all of the masks and read in the the variables 
C            provided for each one, storing in a common grid. 

C     The stored grids are then applied using prescribe_ob_apply_fields in 
C     | - forward_step.F
C       | - thermodynamics (theta and salt)
C       | - dynamics (uvel and vvel applied to gu and gv, resp.)
C       | - momentum_correction (uvel and vvel)
C       
C     Note that solve_for_pressure.f has some considerations for etan
C        but etan is never actually prescribed (as of now)



C     Loop through each mask to read in the variables
      DO vec_id=1,nVEC_masks

C           Counting number of valid characters to trim trailing whitespaces 
C           around the mask name
            mask_name_len = 0
            DO i=1, len(vec_fname_prefixes(vec_id))
              IF (vec_fname_prefixes(vec_id)(i:i) .ne. ' ') then
                  mask_name_len = mask_name_len + 1
              ENDIF
            ENDDO


C           Loop through each field name to read in the file
            DO f=1,vec_nFlds(vec_id)

C           Counting number of valid characters to trim trailing 
C           whitespaces around the field name
            fld_name_len = 0
            DO i=1, len(vec_flds(f, vec_id))
                  IF (vec_flds(f, vec_id)(i:i) .ne. ' ') THEN
                        fld_name_len = fld_name_len + 1
                  ENDIF
            ENDDO
            WRITE(field_file_name, "(A,A,A,A)") 
     &          vec_fname_prefixes(vec_id)(1:mask_name_len),"_",
     &          vec_flds(f, vec_id)(1:fld_name_len),".bin"

C                 Next, read in the fields     
C                 For now, the record number to read is just assigned to how many steps
C                 have occured since the start of the simulation
C                 If the first field is the initial condition, then ignore it
            IF (vec_fields_include_ICs) THEN
                  iRecord = myIter - nIter0 + 1
            ELSE
                  iRecord = myIter - nIter0 + 0
            ENDIF

C           only read the field if its etan
            IF (fld_name_len.eq.4) THEN
            if (vec_flds(f, vec_id)(1:fld_name_len).eq.'ETAN') then

            WRITE(msgBuf,'(A,A,I5,A,I5)') " Reading in the ETAN ",
     &         "field on mask ", vec_id," at myIter = ",myIter
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                          SQUEEZE_RIGHT, myThid )

                  CALL READ_VEC_FIELD(field_file_name, vec_id, f,
     I                 vec_numPnts_allproc(vec_id, mpiMyId+1),
     I                 vec_levels(f, vec_id),
     I                 iRecord, myThid)

            endif
            ENDIF

            ENDDO     

      ENDDO



C------------------------------------------------------------------------------|

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END PRESCRIBE_VEC_READ_ETAN_FIELD DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C     endif (continue_to_read) 
      ENDIF

      RETURN

#endif /* ALLOW_PRESCRIBE_VEC */
      
      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|






