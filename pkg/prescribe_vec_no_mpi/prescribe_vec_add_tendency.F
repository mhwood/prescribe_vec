
#include "PRESCRIBE_VEC_OPTIONS.h"

CBOP
C !ROUTINE: PRESCRIBE_VEC_ADD_TENDENCY

C !INTERFACE: ==========================================================
      SUBROUTINE PRESCRIBE_VEC_ADD_TENDENCY(
     U                    gTendency,
     I                    k, bi, bj, fld_name,
     I                    myTime, myIter, myThid )

C !DESCRIPTION:
C     Add to tendency array the contribution from 3-D field relaxation

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
c#include "GRID.h"
#include "DYNVARS.h"
#include "PRESCRIBE_VEC.h"


C !INPUT/OUTPUT PARAMETERS: ============================================
C  gTendency      :: the tendency array
C  k              :: vertical level index
C  bi,bj          :: tile indices
C  myTime         :: current time
C  myIter         :: current timestep
C  myThid         :: my Thread Id number

      _RL gTendency(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      INTEGER k, bi, bj
      CHARACTER*(*) fld_name
      _RL myTime
      INTEGER myIter
      INTEGER myThid



C !LOCAL VARIABLES: ====================================================
      INTEGER bi_check, bj_check
      INTEGER, PARAMETER :: debug = 1
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER fld, vec_id
      INTEGER mask_fld_index
      INTEGER n_point, i, j
      _RL val, mask_val, vanishingTime 

CEOP

#ifdef ALLOW_PRESCRIBE_VEC

      if ((debug .eq. 1).and.(k.eq.1)) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN PRESCRIBE_VEC_ADD_TENDENCY DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C------------------------------------------------------------------------------|

C     Loop through all of the masks provided
      DO vec_id=1,nVEC_masks

            IF (vec_nRelaxPoints(vec_id).gt.0) THEN

            mask_fld_index = 0

C Here, we loop through the fld list and look for the fld that matches
C the input string (fld_name); 
C     if the match is found, then its index is stored as mask_fld_index
C     if no match is found, then no prescribing takes place

C Note that the various sections are hard-coded because there is
C a reference to the fields (which are hard-coded in FIELDS.h)



C------------------------------------------------------------------------------|
C-- THETA
      
      IF (fld_name(1:5) .eq. "THETA") THEN

        DO fld=1,vec_nFlds(vec_id)
            IF (vec_flds(fld, vec_id)(1:5) .eq. "THETA") THEN
                  mask_fld_index = fld
            ENDIF
        ENDDO

        IF (mask_fld_index .ne. 0) THEN

            if ((debug .eq. 1).and.(k.eq.1)) then
              WRITE(msgBuf,'(A,A,A,I5)') "Relaxing ",fld_name,
     &         " fields for mask ",vec_id
              CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                            SQUEEZE_RIGHT, myThid )
            endif

!             IF (myIter.eq.2) THEN
!             DO n_point=1,vec_numPnts_allproc(vec_id, mpiMyId+1)
! C                  DO i=1,Nr
!                   val = vec_subFields(vec_id,mask_fld_index,n_point,k)
!                   PRINT *,'vec_id',vec_id,', mask_fld_index',
!      &            mask_fld_index,', n_point',n_point,', k=',k,
!      &            ', val',val 
! C                  ENDDO

!             ENDDO
!             ENDIF

            DO n_point=1,vec_numPnts_allproc(vec_id, mpiMyId+1)

              i = vec_point_ij(vec_id,1,n_point)
              j = vec_point_ij(vec_id,2,n_point)
              bi_check = vec_point_ij(vec_id,3,n_point)
              bj_check = vec_point_ij(vec_id,4,n_point)

              IF ((bi.eq.bi_check).and.(bj.eq.bj_check)) THEN

              mask_val = relax_mask(vec_id,i,j,bi,bj)

              IF (mask_val.gt.0) THEN

!               if ((debug .eq. 1).and.(k.eq.1)) then
!                   WRITE(msgBuf,'(A,I5,A,F10.3,A)') 
!      &               "  For point ",n_point,
!      &                " relax_mask = ", mask_val," ==> relax point"
!                   CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!               endif
              
              vanishingTime = relax_time(vec_id,i,j,bi,bj)

              IF ( vanishingTime.EQ.0 ) THEN
                  WRITE(msgBuf,'(A)')
     &            'PRESCRIBE_VEC_ADD_TENDENCY: relax time = 0'
                  CALL PRINT_ERROR( msgBuf, myThid )
                  CALL ALL_PROC_DIE( 0 )
                  STOP 'ABNORMAL END: S/R PRESCRIBE_VEC_ADD_TENDENCY'
              ENDIF

              val = vec_subFields(vec_id,mask_fld_index,n_point,k)

              gTendency(i,j) = gTendency(i,j)
     &                - (1/vanishingTime)
     &                 *( theta(i,j,k,bi,bj)- val )

              if ((debug .eq. 1).and.(k.eq.1).and.(vec_id.eq.5)) then
              WRITE(msgBuf,'(A,A,A,F10.3)') 
     &           "     Setting ",fld_name," tendency = ",gTendency(i,j)
              CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                                   SQUEEZE_RIGHT, myThid )
              WRITE(msgBuf,'(A,F10.3,A,F10.3,A,F10.3)') 
     &           "        Using vanishingTime = ",vanishingTime,
     &           ", theta = ",theta(i,j,k,bi,bj)," theta_relax = ",val
              CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                                   SQUEEZE_RIGHT, myThid )
              WRITE(msgBuf,'(A,I5,A,I5,A,I5,A,I5,A,I5)') 
     &               "        at i =",i," j=",j,
     &               " bi =",bi," bj = ",bj," k = ",k
              CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                                   SQUEEZE_RIGHT, myThid )
              endif


C             if mask val signaled relaxation (mask_val.gt.0)     
              ELSE

!               if ((debug .eq. 1).and.(k.eq.1)) then
!                   WRITE(msgBuf,'(A,I5,A,F10.3,A,A)') 
!      &               "  For point ",n_point,
!      &                " relax_mask = ", mask_val," ==> prescribe point",
!      &              " (ignored here)"
!                   CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!               endif   

C             END IF (mask_val.gt.0)              
              ENDIF
         
C           IF ((bi.eq.bi_check) ...              
            ENDIF

C           END DO n_point=1, ...
            ENDDO

C       END IF (mask_fld_index .ne. 0) ...
        ENDIF

C     END IF (fld_name(1:5) .eq. "THETA") ...
      ENDIF




C------------------------------------------------------------------------------|
C-- SALT
      
      IF (fld_name(1:4) .eq. "SALT") THEN

      DO fld=1,vec_nFlds(vec_id)
          IF (vec_flds(fld, vec_id)(1:4) .eq. "SALT") THEN
                mask_fld_index = fld
          ENDIF
      ENDDO

      IF (mask_fld_index .ne. 0) THEN

!           if ((debug .eq. 1).and.(k.eq.1)) then
!             WRITE(msgBuf,'(A,A,A,I5)') "Relaxing ",fld_name,
!      &         " fields for mask ",vec_id
!             CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                            SQUEEZE_RIGHT, myThid )
!           endif

          DO n_point=1,vec_numPnts_allproc(vec_id, mpiMyId+1)

            i = vec_point_ij(vec_id,1,n_point)
            j = vec_point_ij(vec_id,2,n_point)
            bi = vec_point_ij(vec_id,3,n_point)
            bj = vec_point_ij(vec_id,4,n_point)

            IF ((bi.eq.bi_check).and.(bj.eq.bj_check)) THEN

            mask_val = relax_mask(vec_id,i,j,bi,bj)

            IF (mask_val.gt.0) THEN

            if ((debug .eq. 1).and.(k.eq.1)) then
                WRITE(msgBuf,'(A,I5,A,F10.3,A)') 
     &               "  For point ",n_point,
     &                " relax_mask = ", mask_val," ==> relax point"
                CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                                   SQUEEZE_RIGHT, myThid )
            endif
            
            vanishingTime = relax_time(vec_id,i,j,bi,bj)

            IF ( vanishingTime.EQ.0 ) THEN
                WRITE(msgBuf,'(A)')
     &            'PRESCRIBE_VEC_ADD_TENDENCY: relax time = 0'
                CALL PRINT_ERROR( msgBuf, myThid )
                CALL ALL_PROC_DIE( 0 )
                STOP 'ABNORMAL END: S/R PRESCRIBE_VEC_ADD_TENDENCY'
            ENDIF

            val = vec_subFields(vec_id,mask_fld_index,n_point,k)
            gTendency(i,j) = gTendency(i,j)
     &                - (1/vanishingTime)
     &                 *( salt(i,j,k,bi,bj)- val )

C             if mask val signaled relaxation (mask_val.gt.0)     
            ELSE

!             if ((debug .eq. 1).and.(k.eq.1)) then
!                 WRITE(msgBuf,'(A,I5,A,F10.3,A,A)') 
!      &               "  For point ",n_point,
!      &                " relax_mask = ", mask_val," ==> prescribe point",
!      &              " (ignored here)"
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!             endif   

C             END IF (mask_val.gt.0)              
            ENDIF
       
C           IF ((bi.eq.bi_check) ...              
          ENDIF

C           END DO n_point=1, ...
          ENDDO

C       END IF (mask_fld_index .ne. 0) ...
      ENDIF

C     END IF (fld_name(1:4) .eq. "SALT") ...
      ENDIF

C------------------------------------------------------------------------------|     
      ELSE

      if ((debug .eq. 1).and.(k.eq.1)) then
            WRITE(msgBuf,'(A,A,I2)') " Relax code skipped",
     &         " because no points were identified for mask ",vec_id
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                          SQUEEZE_RIGHT, myThid )
            endif

      ENDIF

C     Finish the loop through all masks provided
      ENDDO

C--   Make everyone wait until all procs have applied their boundaries to
C     ensure some procs do not go ahead without the prescribed values
      _BARRIER

C------------------------------------------------------------------------------|

      if ((debug .eq. 1).and.(k.eq.1)) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END PRESCRIBE_VEC_ADD_TENDENCY DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      RETURN

#endif /* ALLOW_PRESCRIBE_VEC */
      
      END