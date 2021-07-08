C----&------------------------------------------------------------------xxxxxxx|
C                           prescribe_vec_check
C----&------------------------------------------------------------------xxxxxxx|

#include "PRESCRIBE_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: PRESCRIBE_VEC_CHECK

C !INTERFACE:
      SUBROUTINE PRESCRIBE_VEC_CHECK( myThid )

C     !DESCRIPTION:
C     Check dependances with other packages

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "PRESCRIBE_VEC.h"

C     !INPUT PARAMETERS:
C     myThid   :: my Thread Id number
      INTEGER myThid

C     !LOCAL VARIABLES:
C     msgBuf   :: Informational/error message buffer
      INTEGER errCount
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER, PARAMETER :: debug = 1
CEOP
C----&------------------------------------------------------------------xxxxxxx|
CBOC

#ifdef ALLOW_PRESCRIBE_VEC

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN PRESCRIBE_VEC_CHECK DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif


      _BEGIN_MASTER(myThid)

       WRITE(msgBuf,'(A)')
     &      'PRESCRIBE_VEC_CHECK: #define PRESCRIBE_VEC'
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT , 1)

      errCount = 0

C ---  First check: all of the vanishing times should be greater than
C      or equal to the smallest time step

C ---  Second check: the number of tiles per processor must be 1
C      Multiple tiles have not yet been tested 
C         -> vec_mask_index_list needs refs to tiles, which is not yet implemented
      IF (nSx.GT.1) THEN
            errCount = errCount +1
            WRITE(msgBuf,'(A)')
     &    'prescribe_vec has not been tested with nSx > 1 or nSy > 1'
            CALL PRINT_ERROR( msgBuf, myThid )
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT , 1)
      ENDIF

      IF (nSy.GT.1) THEN
            errCount = errCount +1
            WRITE(msgBuf,'(A)')
     &    'prescribe_vec has not been tested with nSx > 1 or nSy > 1'
            CALL PRINT_ERROR( msgBuf, myThid )
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT , 1)
      ENDIF

      IF (nPx.GT.1) THEN
            errCount = errCount +1
            WRITE(msgBuf,'(A)')
     &    'prescribe_vec has not been tested with nPx > 1 or nPy > 1'
            CALL PRINT_ERROR( msgBuf, myThid )
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT , 1)
      ENDIF

      IF (nPy.GT.1) THEN
            errCount = errCount +1
            WRITE(msgBuf,'(A)')
     &    'prescribe_vec has not been tested with nPx > 1 or nPy > 1'
            CALL PRINT_ERROR( msgBuf, myThid )
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT , 1)
      ENDIF

C ---  Fourth check: if ALLOW_PRESCRIBE_VEC_THETA (e.g.)
C      make sure "THETA" is in the list of variables
C      for one of the masks, and vice versa

C ---  If there were any errors, kill the run
      IF ( errCount.GE.1 ) THEN
            WRITE(msgBuf,'(A,I5,A)')
     &     'PRESCRIBE_VEC_CHECK: detected', errCount,' fatal error(s)'
            CALL PRINT_ERROR( msgBuf, myThid )
            CALL ALL_PROC_DIE( 0 )
            STOP 'ABNORMAL END: S/R PRESCRIBE_VEC_CHECK'
      ENDIF

      _END_MASTER(myThid)

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN PRESCRIBE_VEC_CHECK DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

#endif /* ALLOW_PRESCRIBE_VEC */

      RETURN
      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|