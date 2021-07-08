C----&------------------------------------------------------------------xxxxxxx|
C                         prescribe_vec_init_fixed
C----&------------------------------------------------------------------xxxxxxx|

#include "PRESCRIBE_VEC_OPTIONS.h"






C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: PRESCRIBE_VEC_INIT_FIXED

C !INTERFACE:
      SUBROUTINE PRESCRIBE_VEC_INIT_FIXED( myThid )

C     !DESCRIPTION:
C     Initialize PRESCRIBE_VEC variables that are kept fixed during the run.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "PRESCRIBE_VEC.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid

C     !LOCAL VARIABLES:
      INTEGER, PARAMETER :: debug = 1
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER i, j, bi, bj, p, k
      INTEGER vec_id
      INTEGER mask_name_len
      INTEGER prescribe_counter
      INTEGER relax_counter
      CHARACTER*50 mask_filename
      CHARACTER*50 relax_time_filename
      CHARACTER*50 relax_mask_filename
      _RL mask_buffer(nVEC_masks,1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)
      _RL rt_buff(nVEC_masks,1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)
      
      
CEOP
C----&------------------------------------------------------------------xxxxxxx|

C----&------------------------------------------------------------------xxxxxxx|
C     Initialize prescribe_vec COMMON block variables:
C----&------------------------------------------------------------------xxxxxxx|


#ifdef ALLOW_PRESCRIBE_VEC

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN PRESCRIBE_VEC_INIT_FIXED DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C----&------------------------------------------------------------------xxxxxxx|
C     Fill PRESCRIBE_VEC.h COMMON Block with some default 
C          values for the vector variables
C----&------------------------------------------------------------------xxxxxxx|


      DO vec_id=1, nVEC_masks

            vec_nPoints(vec_id) = 0
            vec_nRelaxPoints(vec_id) = 0
            vec_nPrescribePoints(vec_id) = 0

            DO p=1,nPx*nPy
                  vec_numPnts_allproc(vec_id, p) = 0
            ENDDO

            DO bj = myByLo(myThid), myByHi(myThid)
            DO bi = myBxLo(myThid), myBxHi(myThid)
                  DO j=1-OLy,sNy+OLy
                  DO i=1-OLx,sNx+OLx
                        vec_subMask(vec_id,i,j,bi,bj) = 0.0
                        relax_time(vec_id,i,j,bi,bj) = 0.0
                        relax_mask(vec_id,i,j,bi,bj) = 0.0
                  ENDDO
                  ENDDO
            ENDDO
            ENDDO

            DO i=1,sNx*sNy
            DO p=1,nPx*nPy
                  vec_mask_index_list(vec_id, p,i) = 0
            ENDDO
            ENDDO

            DO i=1,sNx*sNy
                  vec_point_ij(vec_id, 1,i) = 0
                  vec_point_ij(vec_id, 2,i) = 0
                  vec_point_ij(vec_id, 3,i) = 0
                  vec_point_ij(vec_id, 4,i) = 0
            ENDDO

      ENDDO


C----&------------------------------------------------------------------xxxxxxx|
C     Read in the masks
C----&------------------------------------------------------------------xxxxxxx|

C     Looping through each vector mask
      DO vec_id=1, nVEC_masks

      mask_filename = vec_fname_prefixes(vec_id)

      if (debug .eq. 1) then
        
        WRITE(msgBuf,'(A,A,A)')  'Identifying vec mask points for ',
     &  ' mask ', mask_filename
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C     Counting number of valid characters to trim trailing whitespaces
      mask_name_len = 0
      DO i=1, len(vec_fname_prefixes(vec_id))
        IF (vec_fname_prefixes(vec_id)(i:i) .ne. ' ') then
            mask_name_len = mask_name_len + 1
        ENDIF
      ENDDO
      WRITE(mask_filename,'(A,A)') 
     &     vec_fname_prefixes(vec_id)(1:mask_name_len),'.bin'

C       Read mask files and assign portion of mask to each process
        CALL READ_REC_XY_RL( mask_filename,
     &               mask_buffer(vec_id,:,:,:,:), 1, 0, myThid )

C       Filling in halo regions of sub masks
        _EXCH_XY_RL(mask_buffer(vec_id,:,:,:,:), myThid)

        DO bj = myByLo(myThid), myByHi(myThid)
            DO bi = myBxLo(myThid), myBxHi(myThid)
                  DO j=1-OLy,sNy+OLy
                  DO i=1-OLx,sNx+OLx
                        vec_subMask(vec_id,i,j,bi,bj)
     &                      = mask_buffer(vec_id,i,j,bi,bj)
                  ENDDO
                  ENDDO
            ENDDO
        ENDDO

C       Mask a list of where the mask points are located
        CALL IDENTIFY_VEC_POINTS(mask_buffer,vec_id, myThid)

      ENDDO

C----&------------------------------------------------------------------xxxxxxx|
C     Read in the relaxation timescales
C----&------------------------------------------------------------------xxxxxxx|

C     Looping through each vector mask
      DO vec_id=1, nVEC_masks

      IF (vec_relax_time_fnames(vec_id)(1:1) .ne. ' ') THEN

      relax_time_filename = vec_relax_time_fnames(vec_id)
      if (debug .eq. 1) then
        WRITE(msgBuf,'(A,A,A)') '  Identifying relaxation timescales',
     &  ' for mask ', relax_time_filename
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C     Counting number of valid characters to trim trailing whitespaces
      mask_name_len = 0
      DO i=1, len(vec_relax_time_fnames(vec_id))
        IF (vec_relax_time_fnames(vec_id)(i:i) .ne. ' ') then
            mask_name_len = mask_name_len + 1
        ENDIF
      ENDDO

      if (mask_name_len .gt. 0) then

C       Read mask files and assign portion of mask to each process
        CALL READ_REC_XY_RL( relax_time_filename,
     &               rt_buff(vec_id,:,:,:,:), 1, 0, myThid )

C       Filling in halo regions of sub masks
        _EXCH_XY_RL(rt_buff(vec_id,:,:,:,:), myThid)

        DO bj = myByLo(myThid), myByHi(myThid)
            DO bi = myBxLo(myThid), myBxHi(myThid)
                  DO j=1-OLy,sNy+OLy
                  DO i=1-OLx,sNx+OLx
                        relax_time(vec_id,i,j,bi,bj)
     &                      = rt_buff(vec_id,i,j,bi,bj)
                  ENDDO
                  ENDDO
            ENDDO
        ENDDO
      
      endif

      ELSE

      if (debug .eq. 1) then
        WRITE(msgBuf,'(A,A)') '  No timescales provided for mask ',
     &  vec_fname_prefixes(vec_id)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
       WRITE(msgBuf,'(A)') '    ==> setting to 0 (full prescription)'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      ENDIF
      
      ENDDO



C----&------------------------------------------------------------------xxxxxxx|
C     Make a mask to detemine whether to prescribe the value or  
C          add a tendency
C----&------------------------------------------------------------------xxxxxxx|

      DO vec_id=1, nVEC_masks

      prescribe_counter = 0
      relax_counter = 0

      DO bj = myByLo(myThid), myByHi(myThid)
      DO bi = myBxLo(myThid), myBxHi(myThid)
            DO j=1-OLy,sNy+OLy
            DO i=1-OLx,sNx+OLx
                  if (vec_subMask(vec_id,i,j,bi,bj).gt.0.0) then
                  if (relax_time(vec_id,i,j,bi,bj).gt.0.0) then
                        relax_mask(vec_id,i,j,bi,bj) = 1.0
                        relax_counter = relax_counter + 1
                  else
                        prescribe_counter = prescribe_counter + 1
                  endif
                  endif
            ENDDO
            ENDDO
      ENDDO
      ENDDO

      vec_nRelaxPoints(vec_id) = relax_counter 
      vec_nPrescribePoints(vec_id) = prescribe_counter

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A,I2,A,I5,A,I5,A)') "Mask ",vec_id," has ",
     &   relax_counter," relax points and ",prescribe_counter,
     &   " prescribe points"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      ENDDO


! #ifdef ALLOW_USE_MPI
!       CALL SEND_CHILD_TO_PARENT(myThid)
! #endif


C----&------------------------------------------------------------------xxxxxxx|


      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END PRESCRIBE_VEC_INIT_FIXED DEBUG "
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










C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: IDENTIFY_VEC_POINTS

C !INTERFACE:
      SUBROUTINE IDENTIFY_VEC_POINTS(mask_buffer,vec_id, myThid)

C     !DESCRIPTION:
C     Locate vector mask points within each subtile

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "PRESCRIBE_VEC.h"

C     !INPUT PARAMETERS:
      _RL mask_buffer(nVEC_masks,1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)
      INTEGER vec_id, myThid

C     !LOCAL VARIABLES:     
      INTEGER counter, i, j, bi, bj
      INTEGER mask_val
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER, PARAMETER :: debug = 0

CEOP
C----&------------------------------------------------------------------xxxxxxx|
CBOC

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN IDENTIFY_VEC_POINTS DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

!       PRINT *,'vec_id',vec_id,'max(mask_buffer)',
!      &       MAXVAL(mask_buffer(vec_id,:,:,:,:))
!       PRINT *,'vec_id',vec_id,'max(vec_subMask)',
!      &       MAXVAL(vec_subMask(vec_id,:,:,:,:))

      counter = 1
      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1,sNy
           DO i=1,sNx
            
             if (mask_buffer(vec_id,i,j,bi,bj) .ge. 1.0 ) then

               mask_val = INT(mask_buffer(vec_id,i,j,bi,bj))

C              Save the mask index for this processor
               vec_point_ij(vec_id,1,mask_val) = i
               vec_point_ij(vec_id,2,mask_val) = j
               vec_point_ij(vec_id,3,mask_val) = bi
               vec_point_ij(vec_id,4,mask_val) = bj

               counter = counter + 1
             end if
            ENDDO
          ENDDO
        ENDDO
      ENDDO

      vec_numPnts_allproc(vec_id,mpiMyId+1) = counter-1

      WRITE(msgBuf,'(A,I5,A,I5,A,I5)') 
     &   "vec_numPnts_allproc(",vec_id,",",mpiMyId+1,
     &   ") = ",vec_numPnts_allproc(vec_id,mpiMyId+1)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &        SQUEEZE_RIGHT, myThid )

      if ((debug .eq. 1)) then
      DO i=1,vec_numPnts_allproc(vec_id,mpiMyId+1)
            WRITE(msgBuf,'(A,I5,A,I5,A,I5,A,I5)') 
     &     "vec_point_ij(",vec_id,",1:2,",i,
     &     ") = ",vec_point_ij(vec_id,1,i),',',vec_point_ij(vec_id,2,i)
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &               SQUEEZE_RIGHT, myThid )
      ENDDO
      endif



      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END IDENTIFY_VEC_POINTS DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      END

CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
