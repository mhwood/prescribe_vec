C------------------------------------------------------------------------------|
C                           prescribe_vec_set_fields
C------------------------------------------------------------------------------|

#include "PRESCRIBE_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: PRESCRIBE_VEC

C !INTERFACE:
      SUBROUTINE PRESCRIBE_VEC_OVERWRITE_HALO( fld_name, myThid )

C     !DESCRIPTION:
C     Initialize PRESCRIBE_VEC variables

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "PRESCRIBE_VEC.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      CHARACTER*(*) fld_name
      INTEGER myThid
      

C     !LOCAL VARIABLES:
C      INTEGER i,j,k,l, bi,bj
      INTEGER, PARAMETER :: debug = 1
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER fld, vec_id
      INTEGER mask_fld_index
      INTEGER n_point, i, j, k, bi, bj
      INTEGER i_add, j_add
      _RL val


CEOP
C------------------------------------------------------------------------------|
CBOC

#ifdef ALLOW_PRESCRIBE_VEC

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN PRESCRIBE_VEC_OVERWRITE_HALO DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C------------------------------------------------------------------------------|

C------------------------------------------------------------------------------|
C-- THETA
      
      IF (fld_name(1:5) .eq. "THETA") THEN


C     Fill in the west and east boundaries boundary

      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
      DO k=1,Nr

      DO j=1,sNy
C           West boundary first
            val = theta(1,j,k,bi,bj)
            DO i_add=1,OLx
                  theta(1-i_add,j,k,bi,bj) = val
            ENDDO
C           Then east boundary
            val = theta(sNx,j,k,bi,bj)
            DO i_add=1,OLx
                  theta(sNx+i_add,j,k,bi,bj) = val
            ENDDO
      ENDDO

      DO i=1-OLx,sNx+OLx
C           South boundary first
            val = theta(i,1,k,bi,bj)
            DO j_add=1,OLy
                  theta(i,1-j_add,k,bi,bj) = val
            ENDDO
C           Then north boundary
            val = theta(i,sNy,k,bi,bj)
            DO j_add=1,OLy
                  theta(i,sNy+j_add,k,bi,bj) = val
            ENDDO
      ENDDO

      ENDDO
      ENDDO
      ENDDO

      ENDIF

C------------------------------------------------------------------------------|
C-- SALT
      
      IF (fld_name(1:4) .eq. "SALT") THEN

      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
      DO k=1,Nr

C     Fill in the west and east boundaries boundary      

      DO j=1,sNy
C           West boundary first
            val = salt(1,j,k,bi,bj)
            DO i_add=1,OLx
                  salt(1-i_add,j,k,bi,bj) = val
            ENDDO
C           Then east boundary
            val = salt(sNx,j,k,bi,bj)
            DO i_add=1,OLx
                  salt(sNx+i_add,j,k,bi,bj) = val
            ENDDO
      ENDDO

      DO i=1-OLx,sNx+OLx
C           South boundary first
            val = salt(i,1,k,bi,bj)
            DO j_add=1,OLy
                  salt(i,1-j_add,k,bi,bj) = val
            ENDDO
C           Then north boundary
            val = salt(i,sNy,k,bi,bj)
            DO j_add=1,OLy
                  salt(i,sNy+j_add,k,bi,bj) = val
            ENDDO
      ENDDO

      ENDDO
      ENDDO
      ENDDO

      ENDIF

C------------------------------------------------------------------------------|
C-- UVEL
      
      IF (fld_name(1:4) .eq. "UVEL") THEN

      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
      DO k=1,Nr

C     Fill in the west and east boundaries boundary      
      
      DO j=1,sNy
C           West boundary first
            val = uvel(1,j,k,bi,bj)
            DO i_add=1,OLx
                  uvel(1-i_add,j,k,bi,bj) = val
            ENDDO
C           Then east boundary
            val = uvel(sNx,j,k,bi,bj)
            DO i_add=1,OLx
                  uvel(sNx+i_add,j,k,bi,bj) = val
            ENDDO
      ENDDO

      DO i=1-OLx,sNx+OLx
C           South boundary first
            val = uvel(i,1,k,bi,bj)
            DO j_add=1,OLy
                  uvel(i,1-j_add,k,bi,bj) = val
            ENDDO
C           Then north boundary
            val = uvel(i,sNy,k,bi,bj)
            DO j_add=1,OLy
                  uvel(i,sNy+j_add,k,bi,bj) = val
            ENDDO
      ENDDO

      ENDDO
      ENDDO
      ENDDO

      ENDIF

C------------------------------------------------------------------------------|
C-- VVEL
      
      IF (fld_name(1:4) .eq. "VVEL") THEN

      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
      DO k=1,Nr
            
C     Fill in the west and east boundaries boundary      
      
      DO j=1,sNy
C           West boundary first
            val = vvel(1,j,k,bi,bj)
            DO i_add=1,OLx
                  vvel(1-i_add,j,k,bi,bj) = val
            ENDDO
C           Then east boundary
            val = vvel(sNx,j,k,bi,bj)
            DO i_add=1,OLx
                  vvel(sNx+i_add,j,k,bi,bj) = val
            ENDDO
      ENDDO

      DO i=1-OLx,sNx+OLx
C           South boundary first
            val = vvel(i,1,k,bi,bj)
            DO j_add=1,OLy
                  vvel(i,1-j_add,k,bi,bj) = val
            ENDDO
C           Then north boundary
            val = vvel(i,sNy,k,bi,bj)
            DO j_add=1,OLy
                  vvel(i,sNy+j_add,k,bi,bj) = val
            ENDDO
      ENDDO

      ENDDO
      ENDDO
      ENDDO

      ENDIF


C------------------------------------------------------------------------------|
C-- WVEL
      
      IF (fld_name(1:4) .eq. "WVEL") THEN

      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
      DO k=1,Nr

C     Fill in the west and east boundaries boundary      
      
      DO j=1,sNy
C           West boundary first
            val = wvel(1,j,k,bi,bj)
            DO i_add=1,OLx
                  wvel(1-i_add,j,k,bi,bj) = val
            ENDDO
C           Then east boundary
            val = wvel(sNx,j,k,bi,bj)
            DO i_add=1,OLx
                  wvel(sNx+i_add,j,k,bi,bj) = val
            ENDDO
      ENDDO

      DO i=1-OLx,sNx+OLx
C           South boundary first
            val = wvel(i,1,k,bi,bj)
            DO j_add=1,OLy
                  wvel(i,1-j_add,k,bi,bj) = val
            ENDDO
C           Then north boundary
            val = wvel(i,sNy,k,bi,bj)
            DO j_add=1,OLy
                  wvel(i,sNy+j_add,k,bi,bj) = val
            ENDDO
      ENDDO

      ENDDO
      ENDDO
      ENDDO

      ENDIF

C------------------------------------------------------------------------------|
C-- ETAN
      
      IF (fld_name(1:4) .eq. "ETAN") THEN

      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)

C     Fill in the west and east boundaries boundary      
      
      DO j=1,sNy
C           West boundary first
            val = etan(1,j,bi,bj)
            DO i_add=1,OLx
                  etan(1-i_add,j,bi,bj) = val
            ENDDO
C           Then east boundary
            val = etan(sNx,j,bi,bj)
            DO i_add=1,OLx
                  etan(sNx+i_add,j,bi,bj) = val
            ENDDO
      ENDDO

      DO i=1-OLx,sNx+OLx
C           South boundary first
            val = etan(i,1,bi,bj)
            DO j_add=1,OLy
                  etan(i,1-j_add,bi,bj) = val
            ENDDO
C           Then north boundary
            val = etan(i,sNy,bi,bj)
            DO j_add=1,OLy
                  etan(i,sNy+j_add,bi,bj) = val
            ENDDO
      ENDDO

      ENDDO
      ENDDO

      ENDIF

C------------------------------------------------------------------------------|     

C--   Make everyone wait until all procs have applied their boundaries to
C     ensure some procs do not go ahead without the prescribed values
      _BARRIER


C------------------------------------------------------------------------------|

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END PRESCRIBE_VEC_OVERWRITE_HALO DEBUG "
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










