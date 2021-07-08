C------------------------------------------------------------------------------|
C                           prescribe_vec_init_varia
C------------------------------------------------------------------------------|

#include "PRESCRIBE_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: PRESCRIBE_VEC_INIT_VARIA

C !INTERFACE:
      SUBROUTINE PRESCRIBE_VEC_INIT_VARIA( myThid )

C     !DESCRIPTION:
C     Initialize PRESCRIBE_VEC variables

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
      

C     !LOCAL VARIABLES:
C      INTEGER i,j,k,l, bi,bj
      INTEGER, PARAMETER :: debug = 0
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER vec_id, i, f, k

CEOP
C------------------------------------------------------------------------------|
CBOC

#ifdef ALLOW_PRESCRIBE_VEC

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN PRESCRIBE_VEC_INIT_VARIA DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C------------------------------------------------------------------------------|


! C     Set the global_vec field to 0 - this will be filled in at the 
! C     start of forward_step.F
!       DO vec_id=1,nVEC_masks
!         DO f=1,N_VEC_FIELDS
!           DO i=1,sNx*sNy
!             DO k = 1,Nr
!                   vec_subFields(vec_id,f,i,k) = 0
!             ENDDO
!           ENDDO
!         ENDDO
!       ENDDO

C------------------------------------------------------------------------------|

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END PRESCRIBE_VEC_INIT_VARIA DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      RETURN

#endif /* ALLOW_PRESCRIBE_VEC */
      
      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|










