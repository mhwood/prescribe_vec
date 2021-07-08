C------------------------------------------------------------------------------|
C                           prescribe_vec_read_field
C------------------------------------------------------------------------------|

#include "PRESCRIBE_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: READ_VEC_FIELD

C !INTERFACE:
      SUBROUTINE READ_VEC_FIELD(file_name, vec_id, fld,
     I                          mask_len, n_levels,
     I                          iRecord, myThid )

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
      CHARACTER(*) file_name
      INTEGER vec_id, fld
      INTEGER mask_len, n_levels
      INTEGER myThid
      INTEGER iRecord


C !FUNCTIONS
      INTEGER  MDS_RECLEN
      EXTERNAL MDS_RECLEN
      

C     !LOCAL VARIABLES:
C      INTEGER i,j,k,l, bi,bj
      INTEGER, PARAMETER :: debug = 0
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER xSize, ySize
      INTEGER length_of_rec,rcl
      INTEGER irec, dUnit, i, k
      Real*4 vec_buff_r4(sNx*sNy,Nr)
      Real*8 vec_buff_r8(sNx*sNy,Nr)

CEOP
C------------------------------------------------------------------------------|
CBOC

#ifdef ALLOW_PRESCRIBE_VEC

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN READ_VEC_FIELD DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C------------------------------------------------------------------------------|

C - fill in the buffers with zeros
      IF (vec_filePrec .EQ. 32) THEN
        DO i=1,sNx*sNy 
            DO k=1,Nr
                  vec_buff_r4(i,k) = 0
            ENDDO
        ENDDO
      ELSE
        DO i=1,sNx*sNy
            DO k=1,Nr
                  vec_buff_r8(i,k) = 0
            ENDDO
        ENDDO
      ENDIF

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A,A)') "  Reading from ",file_name
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,I5,A,I5,A,I5)') "    mask_len = ", mask_len,
     &                            ",     n_levels =", n_levels,
     &                            ",    iRecord =",iRecord  
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      CALL MDSFINDUNIT( dUnit, myThid )
      length_of_rec = MDS_RECLEN(vec_filePrec, mask_len, myThid)
      
      OPEN( dUnit, file=file_name, status='old',
     &     access='direct', recl=length_of_rec )
      DO k=1,n_levels
        irec = 1 + (k-1) + n_levels*(iRecord-1)
        IF (vec_filePrec .EQ. precFloat32) THEN
            READ(dUnit,rec=irec) (vec_buff_r4(i,k), i=1,mask_len)
        ELSE
            READ(dUnit,rec=irec) (vec_buff_r8(i,k), i=1,mask_len)
        ENDIF
      ENDDO
      CLOSE( dUnit )

      IF (vec_filePrec .EQ. precFloat32) THEN
            CALL PASS_R4_to_RL(vec_buff_r4, vec_id, fld,
     &                           mask_len, n_levels)
      ELSE
            CALL PASS_R8_to_RL(vec_buff_r8, vec_id, fld,
     &                           mask_len, n_levels)
      ENDIF

C------------------------------------------------------------------------------|

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END READ_VEC_FIELD DEBUG "
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



C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
       SUBROUTINE PASS_R4_to_RL(vec_buff_r4, vec_id, fld,
     &                           mask_len, n_levels)
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PRESCRIBE_VEC.h"

         Real*4 vec_buff_r4(sNx*sNy,Nr)
         INTEGER vec_id, fld
         INTEGER i, k
         INTEGER, PARAMETER :: debug = 0
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
           DO i=1, sNx*sNy
            DO k=1, n_levels
             vec_subFields(vec_id,fld,i,k) = vec_buff_r4(i,k)
            ENDDO
           ENDDO

       END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|


C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
       SUBROUTINE PASS_R8_to_RL(vec_buff_r8, vec_id, fld,
     &                           mask_len, n_levels)
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PRESCRIBE_VEC.h"
 
          Real*8 vec_buff_r8(sNx*sNy,Nr)
          INTEGER vec_id, fld
          INTEGER i, k
          INTEGER, PARAMETER :: debug = 0
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
            DO i=1, sNx*sNy
             DO k=1, n_levels
               vec_subFields(vec_id,fld,i,k) = vec_buff_r8(i,k)
             ENDDO
            ENDDO
 
        END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
 




