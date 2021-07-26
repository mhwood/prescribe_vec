C------------------------------------------------------------------------------|
C                           prescribe_vec_set_fields
C------------------------------------------------------------------------------|

#include "PRESCRIBE_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: PRESCRIBE_VEC

C !INTERFACE:
      SUBROUTINE PRESCRIBE_VEC_PRESCRIBE_FIELD( fld_name, 
     &                                          myTime, myIter, myThid)

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
      _RL     myTime
      INTEGER myIter
      INTEGER myThid
      

C     !LOCAL VARIABLES:
C      INTEGER i,j,k,l, bi,bj
      INTEGER, PARAMETER :: debug = 1
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER fld, vec_id
      INTEGER mask_fld_index
      INTEGER n_point, i, j, k, bi, bj, nK
      INTEGER i_add, j_add
      _RL val, mask_val 


CEOP
C------------------------------------------------------------------------------|
CBOC

#ifdef ALLOW_PRESCRIBE_VEC

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,I5)') "  BEGIN PRESCRIBE_VEC DEBUG ",myIter
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C------------------------------------------------------------------------------|

C     Loop through all of the masks provided
      DO vec_id=1,nVEC_masks

            IF (vec_nPrescribePoints(vec_id).gt.0) THEN

            mask_fld_index = 0

C Here, we loop through the fld list and look for the fld that matches
C the input string (fld_name); 
C     if the match is found, then its index is stored as mask_fld_index
C     if no match is found, then no prescribing takes place

C Note that the various sections are hard-coded because there is
C a reference to the dyanmic fields (which are hard-coded in DYNVARS.h)

C------------------------------------------------------------------------------|
C-- THETA
      
      IF (fld_name(1:5) .eq. "THETA") THEN

        DO fld=1,vec_nFlds(vec_id)
            IF (vec_flds(fld, vec_id)(1:5) .eq. "THETA") THEN
                  mask_fld_index = fld
            ENDIF
        ENDDO

        IF (mask_fld_index .ne. 0) THEN

            if (debug .eq. 1) then
              WRITE(msgBuf,'(A,A,A,I5)') "Prescribing ",fld_name,
     &         " fields for mask ",vec_id
              CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                            SQUEEZE_RIGHT, myThid )
            endif

            DO n_point=1,vec_numPnts_allproc(vec_id, mpiMyId+1)

              i = vec_point_ij(vec_id,1,n_point)
              j = vec_point_ij(vec_id,2,n_point)
              bi = vec_point_ij(vec_id,3,n_point)
              bj = vec_point_ij(vec_id,4,n_point)
              nK = vec_depth_level(vec_id, mask_fld_index, n_point)

              mask_val = relax_mask(vec_id,i,j,bi,bj)

              IF (mask_val.eq.0) THEN

!               if (debug .eq. 1) then
!                   WRITE(msgBuf,'(A,I5,A,F10.3,A)') 
!      &               "  For point ",n_point,
!      &                " relax_mask = ", mask_val," ==> prescribe point"
!                   CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!               endif    

!               if (debug .eq. 1) then
!                   WRITE(msgBuf,'(A,I5,A,I5,A,F10.3)') 
!      &               "  For point ",n_point,
!      &               " depth_level = ", 
!      &               nK,
!      &               ", surface_val = ", 
!      &               vec_subFields(vec_id,mask_fld_index,n_point,1)
!                   CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!               endif  

               DO k=1,nK
                   val = vec_subFields(vec_id,mask_fld_index,n_point,k)
                   theta(i,j,k,bi,bj) = val
!                   if ((debug .eq. 1).and.(k.eq.nK)) then
!                         WRITE(msgBuf,'(A,F10.3,A,I5)') 
!      &               "  Prescribed theta = ",val,
!      &               " at depth_level = ", k
!                         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!                   endif 

C           Fill in the halo region if the point is on the boundary
            IF (i.eq.sNx) THEN
                  DO i_add=1,OLx
                        theta(i+i_add,j,k,bi,bj) = val
                  ENDDO
            ENDIF
            IF (i.eq.1) THEN
                  DO i_add=1,OLx
                        theta(i-i_add,j,k,bi,bj) = val
                  ENDDO
            ENDIF
            IF (j.eq.sNy) THEN
                  DO j_add=1,OLy
                        theta(i,j+j_add,k,bi,bj) = val
                  ENDDO
            ENDIF 
            IF (j.eq.1) THEN
                  DO i_add=1,OLx
                        theta(i,j-j_add,k,bi,bj) = val
                  ENDDO
            ENDIF

C           Fill in the corners of the halo by dragging laterally  
C            DO j=1,Oly         
C                 Lower left 
C                  DO i_add=1,OLx
C                        theta(1-i_add,1-j_add,k,bi,bj) = 
C     &                   theta(1-i_add+1,1-j_add,k,bi,bj)
C                  ENDDO
C                 Upper left 
C                  DO i_add=1,OLx
C                        theta(1-i_add,sNy+j_add,k,bi,bj) = 
C     &                   theta(1-i_add+1,sNy+j_add,k,bi,bj)
C                  ENDDO
C                 Lower right 
C                  DO i_add=1,OLx
C                        theta(sNx+i_add,1-j_add,k,bi,bj) = 
C     &                   theta(sNx+i_add-1,1-j_add,k,bi,bj)
C                  ENDDO
C                 Upper right
C                  DO i_add=1,OLx
C                        theta(sNx+i_add,sNy+j_add,k,bi,bj) = 
C     &                   theta(sNx+i_add-1,sNy+j_add,k,bi,bj)
C                  ENDDO
C            ENDDO

C              if ((debug .eq. 1).and.(k.eq.1).and.(vec_id.eq.1)) then
C                  WRITE(msgBuf,'(A,A,A,F10.3)') 
C     &               "     Setting ",fld_name," = ",val
C                  CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
C     &                                   SQUEEZE_RIGHT, myThid )
C                  WRITE(msgBuf,'(A,I5,A,I5,A,I5,A,I5)') 
C     &               "        at i =",i," j=",j," bi =",bi," bj = ",bj
C                  CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
C     &                                   SQUEEZE_RIGHT, myThid )
C              endif

              ENDDO

              ELSE

!               if (debug .eq. 1) then
!                   WRITE(msgBuf,'(A,I5,A,F10.3,A,A)') 
!      &               "  For point ",n_point,
!      &                " relax_mask = ", mask_val," ==> relax point",
!      &              " (ignored here)"
!                   CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!               endif   

              ENDIF

            ENDDO

        ENDIF


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

          if (debug .eq. 1) then
            WRITE(msgBuf,'(A,A,A,I5)') "Prescribing ",fld_name,
     &         " fields for mask ",vec_id
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                            SQUEEZE_RIGHT, myThid )
          endif

          DO n_point=1,vec_numPnts_allproc(vec_id, mpiMyId+1)

            i = vec_point_ij(vec_id,1,n_point)
            j = vec_point_ij(vec_id,2,n_point)
            bi = vec_point_ij(vec_id,3,n_point)
            bj = vec_point_ij(vec_id,4,n_point)
            nK = vec_depth_level(vec_id, mask_fld_index, n_point)

            mask_val = relax_mask(vec_id,i,j,bi,bj)

            IF (mask_val.eq.0) THEN

!             if (debug .eq. 1) then
!                 WRITE(msgBuf,'(A,I5,A,F10.3,A)') 
!      &               "  For point ",n_point,
!      &                " relax_mask = ", mask_val," ==> prescribe point"
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!             endif    

            DO k=1,nK
                val = vec_subFields(vec_id,mask_fld_index,n_point,k)
                salt(i,j,k,bi,bj) = val

C           Fill in the halo region if the point is on the boundary
          IF (i.eq.sNx) THEN
                DO i_add=1,OLx
                      salt(i+i_add,j,k,bi,bj) = val
                ENDDO
          ENDIF
          IF (i.eq.1) THEN
                DO i_add=1,OLx
                      salt(i-i_add,j,k,bi,bj) = val
                ENDDO
          ENDIF
          IF (j.eq.sNy) THEN
                DO j_add=1,OLy
                      salt(i,j+j_add,k,bi,bj) = val
                ENDDO
          ENDIF 
          IF (j.eq.1) THEN
                DO i_add=1,OLx
                      salt(i,j-j_add,k,bi,bj) = val
                ENDDO
          ENDIF         

!             if ((debug .eq. 1).and.(k.eq.1).and.(vec_id.eq.1)) then
!                 WRITE(msgBuf,'(A,A,A,F10.3)') 
!      &               "     Setting ",fld_name," = ",val
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!                 WRITE(msgBuf,'(A,I5,A,I5,A,I5,A,I5)') 
!      &               "        at i =",i," j=",j," bi =",bi," bj = ",bj
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!             endif

            ENDDO

            ENDIF

          ENDDO

      ENDIF

      ENDIF

C------------------------------------------------------------------------------|
C-- UVEL
      
      IF (fld_name(1:4) .eq. "UVEL") THEN

      DO fld=1,vec_nFlds(vec_id)
          IF (vec_flds(fld, vec_id)(1:4) .eq. "UVEL") THEN
                mask_fld_index = fld
          ENDIF
      ENDDO

      IF (mask_fld_index .ne. 0) THEN

          if (debug .eq. 1) then
            WRITE(msgBuf,'(A,A,A,I5)') "Prescribing ",fld_name,
     &         " fields for mask ",vec_id
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                            SQUEEZE_RIGHT, myThid )
          endif

          DO n_point=1,vec_numPnts_allproc(vec_id, mpiMyId+1)

            i = vec_point_ij(vec_id,1,n_point)
            j = vec_point_ij(vec_id,2,n_point)
            bi = vec_point_ij(vec_id,3,n_point)
            bj = vec_point_ij(vec_id,4,n_point)
            nK = vec_depth_level(vec_id, mask_fld_index, n_point)

            mask_val = relax_mask(vec_id,i,j,bi,bj)

            IF (mask_val.eq.0) THEN

!             if (debug .eq. 1) then
!                 WRITE(msgBuf,'(A,I5,A,F10.3,A)') 
!      &               "  For point ",n_point,
!      &                " relax_mask = ", mask_val," ==> prescribe point"
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!             endif    

            DO k=1,nK
                val = vec_subFields(vec_id,mask_fld_index,n_point,k)
                uvel(i,j,k,bi,bj) = val

C           Fill in the halo region if the point is on the boundary
          IF (i.eq.sNx) THEN
                DO i_add=1,OLx
                  uvel(i+i_add,j,k,bi,bj) = val
                ENDDO
          ENDIF
          IF (i.eq.1) THEN
                DO i_add=1,OLx
                  uvel(i-i_add,j,k,bi,bj) = val
                ENDDO
          ENDIF
          IF (j.eq.sNy) THEN
                DO j_add=1,OLy
                  uvel(i,j+j_add,k,bi,bj) = val
                ENDDO
          ENDIF 
          IF (j.eq.1) THEN
                DO i_add=1,OLx
                  uvel(i,j-j_add,k,bi,bj) = val
                ENDDO
          ENDIF         

!             if ((debug .eq. 1).and.(k.eq.1).and.(vec_id.eq.1)) then
!                 WRITE(msgBuf,'(A,A,A,F10.3)') 
!      &               "     Setting ",fld_name," = ",val
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!                 WRITE(msgBuf,'(A,I5,A,I5,A,I5,A,I5)') 
!      &               "        at i =",i," j=",j," bi =",bi," bj = ",bj
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!             endif

            ENDDO

            ENDIF

          ENDDO

      ENDIF

      ENDIF

C------------------------------------------------------------------------------|
C-- VVEL
      
      IF (fld_name(1:4) .eq. "VVEL") THEN

      DO fld=1,vec_nFlds(vec_id)
          IF (vec_flds(fld, vec_id)(1:4) .eq. "VVEL") THEN
                mask_fld_index = fld
          ENDIF
      ENDDO

      IF (mask_fld_index .ne. 0) THEN

          if (debug .eq. 1) then
            WRITE(msgBuf,'(A,A,A,I5)') "Prescribing ",fld_name,
     &         " fields for mask ",vec_id
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                            SQUEEZE_RIGHT, myThid )
          endif

          DO n_point=1,vec_numPnts_allproc(vec_id, mpiMyId+1)

            i = vec_point_ij(vec_id,1,n_point)
            j = vec_point_ij(vec_id,2,n_point)
            bi = vec_point_ij(vec_id,3,n_point)
            bj = vec_point_ij(vec_id,4,n_point)
            nK = vec_depth_level(vec_id, mask_fld_index, n_point)

            mask_val = relax_mask(vec_id,i,j,bi,bj)

            IF (mask_val.eq.0) THEN

!             if (debug .eq. 1) then
!                 WRITE(msgBuf,'(A,I5,A,F10.3,A)') 
!      &               "  For point ",n_point,
!      &                " relax_mask = ", mask_val," ==> prescribe point"
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!             endif    

            DO k=1,nK
                val = vec_subFields(vec_id,mask_fld_index,n_point,k)
                vvel(i,j,k,bi,bj) = val

C           Fill in the halo region if the point is on the boundary
          IF (i.eq.sNx) THEN
                DO i_add=1,OLx
                  vvel(i+i_add,j,k,bi,bj) = val
                ENDDO
          ENDIF
          IF (i.eq.1) THEN
                DO i_add=1,OLx
                  vvel(i-i_add,j,k,bi,bj) = val
                ENDDO
          ENDIF
          IF (j.eq.sNy) THEN
                DO j_add=1,OLy
                  vvel(i,j+j_add,k,bi,bj) = val
                ENDDO
          ENDIF 
          IF (j.eq.1) THEN
                DO i_add=1,OLx
                  vvel(i,j-j_add,k,bi,bj) = val
                ENDDO
          ENDIF         

!             if ((debug .eq. 1).and.(k.eq.1).and.(vec_id.eq.1)) then
!                 WRITE(msgBuf,'(A,A,A,F10.3)') 
!      &               "     Setting ",fld_name," = ",val
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!                 WRITE(msgBuf,'(A,I5,A,I5,A,I5,A,I5)') 
!      &               "        at i =",i," j=",j," bi =",bi," bj = ",bj
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!             endif

            ENDDO

            ENDIF

          ENDDO

      ENDIF

      ENDIF


C------------------------------------------------------------------------------|
C-- WVEL
      
      IF (fld_name(1:4) .eq. "WVEL") THEN

      DO fld=1,vec_nFlds(vec_id)
          IF (vec_flds(fld, vec_id)(1:4) .eq. "WVEL") THEN
            mask_fld_index = fld
          ENDIF
      ENDDO

      IF (mask_fld_index .ne. 0) THEN

          if (debug .eq. 1) then
            WRITE(msgBuf,'(A,A,A,I5)') "Prescribing ",fld_name,
     &         " fields for mask ",vec_id
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                          SQUEEZE_RIGHT, myThid )
          endif

          DO n_point=1,vec_numPnts_allproc(vec_id, mpiMyId+1)
                i = vec_point_ij(vec_id,1,n_point)
                j = vec_point_ij(vec_id,2,n_point)
                bi = vec_point_ij(vec_id,3,n_point)
                bj = vec_point_ij(vec_id,4,n_point)
                
                ! print *, 'i=',i,'j=',j,'val=',val
                DO k=1,vec_levels(fld, vec_id)
                  val = vec_subFields(vec_id,mask_fld_index,n_point,k)
                  wvel(i,j,k,bi,bj) = val
                ENDDO
          ENDDO

      ENDIF

      ENDIF

C------------------------------------------------------------------------------|
C-- GU
C-- Note this bit of code is to mimic the action of OBCS in dynamics.F
C-- The prescribe_vec pkg does not currently allow for the prescription of GU
      
      IF (fld_name(1:2) .eq. "GU") THEN

      DO fld=1,vec_nFlds(vec_id)
          IF (vec_flds(fld, vec_id)(1:4) .eq. "UVEL") THEN
                mask_fld_index = fld
          ENDIF
      ENDDO

      IF (mask_fld_index .ne. 0) THEN

          if (debug .eq. 1) then
            WRITE(msgBuf,'(A,A,A,I5)') "Prescribing ",fld_name,
     &         " fields for mask ",vec_id
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                            SQUEEZE_RIGHT, myThid )
          endif

          DO n_point=1,vec_numPnts_allproc(vec_id, mpiMyId+1)

            i = vec_point_ij(vec_id,1,n_point)
            j = vec_point_ij(vec_id,2,n_point)
            bi = vec_point_ij(vec_id,3,n_point)
            bj = vec_point_ij(vec_id,4,n_point)
            nK = vec_depth_level(vec_id, mask_fld_index, n_point)

            mask_val = relax_mask(vec_id,i,j,bi,bj)

            IF (mask_val.eq.0) THEN

!             if (debug .eq. 1) then
!                 WRITE(msgBuf,'(A,I5,A,F10.3,A)') 
!      &               "  For point ",n_point,
!      &                " relax_mask = ", mask_val," ==> prescribe point"
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!             endif    

            DO k=1,nK
                val = vec_subFields(vec_id,mask_fld_index,n_point,k)
                gU(i,j,k,bi,bj) = val

C           Fill in the halo region if the point is on the boundary
          IF (i.eq.sNx) THEN
                DO i_add=1,OLx
                  gU(i+i_add,j,k,bi,bj) = val
                ENDDO
          ENDIF
          IF (i.eq.1) THEN
                DO i_add=1,OLx
                  gU(i-i_add,j,k,bi,bj) = val
                ENDDO
          ENDIF
          IF (j.eq.sNy) THEN
                DO j_add=1,OLy
                  gU(i,j+j_add,k,bi,bj) = val
                ENDDO
          ENDIF 
          IF (j.eq.1) THEN
                DO i_add=1,OLx
                  gU(i,j-j_add,k,bi,bj) = val
                ENDDO
          ENDIF         

!             if ((debug .eq. 1).and.(k.eq.1).and.(vec_id.eq.1)) then
!                 WRITE(msgBuf,'(A,A,A,F10.3)') 
!      &               "     Setting ",fld_name," = ",val
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!                 WRITE(msgBuf,'(A,I5,A,I5,A,I5,A,I5)') 
!      &               "        at i =",i," j=",j," bi =",bi," bj = ",bj
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!             endif

            ENDDO

            ENDIF

          ENDDO

      ENDIF

      ENDIF

C------------------------------------------------------------------------------|
C-- GV
      
      IF (fld_name(1:2) .eq. "GV") THEN

      DO fld=1,vec_nFlds(vec_id)
          IF (vec_flds(fld, vec_id)(1:4) .eq. "VVEL") THEN
                mask_fld_index = fld
          ENDIF
      ENDDO

      IF (mask_fld_index .ne. 0) THEN

          if (debug .eq. 1) then
            WRITE(msgBuf,'(A,A,A,I5)') "Prescribing ",fld_name,
     &         " fields for mask ",vec_id
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                            SQUEEZE_RIGHT, myThid )
          endif

          DO n_point=1,vec_numPnts_allproc(vec_id, mpiMyId+1)

            i = vec_point_ij(vec_id,1,n_point)
            j = vec_point_ij(vec_id,2,n_point)
            bi = vec_point_ij(vec_id,3,n_point)
            bj = vec_point_ij(vec_id,4,n_point)
            nK = vec_depth_level(vec_id, mask_fld_index, n_point)

            mask_val = relax_mask(vec_id,i,j,bi,bj)

            IF (mask_val.eq.0) THEN

!             if (debug .eq. 1) then
!                 WRITE(msgBuf,'(A,I5,A,F10.3,A)') 
!      &               "  For point ",n_point,
!      &                " relax_mask = ", mask_val," ==> prescribe point"
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!             endif    

            DO k=1,nK
                val = vec_subFields(vec_id,mask_fld_index,n_point,k)
                gV(i,j,k,bi,bj) = val

C           Fill in the halo region if the point is on the boundary
          IF (i.eq.sNx) THEN
                DO i_add=1,OLx
                  gV(i+i_add,j,k,bi,bj) = val
                ENDDO
          ENDIF
          IF (i.eq.1) THEN
                DO i_add=1,OLx
                  gV(i-i_add,j,k,bi,bj) = val
                ENDDO
          ENDIF
          IF (j.eq.sNy) THEN
                DO j_add=1,OLy
                  gV(i,j+j_add,k,bi,bj) = val
                ENDDO
          ENDIF 
          IF (j.eq.1) THEN
                DO i_add=1,OLx
                  gV(i,j-j_add,k,bi,bj) = val
                ENDDO
          ENDIF         

!             if ((debug .eq. 1).and.(k.eq.1).and.(vec_id.eq.1)) then
!                 WRITE(msgBuf,'(A,A,A,F10.3)') 
!      &               "     Setting ",fld_name," = ",val
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!                 WRITE(msgBuf,'(A,I5,A,I5,A,I5,A,I5)') 
!      &               "        at i =",i," j=",j," bi =",bi," bj = ",bj
!                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!      &                                   SQUEEZE_RIGHT, myThid )
!             endif

            ENDDO

            ENDIF

          ENDDO

      ENDIF

      ENDIF

C------------------------------------------------------------------------------|
C-- ETAN
      
      IF (fld_name(1:4) .eq. "ETAN") THEN

      DO fld=1,vec_nFlds(vec_id)
          IF (vec_flds(fld, vec_id)(1:4) .eq. "ETAN") THEN
                mask_fld_index = fld
          ENDIF
      ENDDO

      IF (mask_fld_index .ne. 0) THEN

          if (debug .eq. 1) then
            WRITE(msgBuf,'(A,A,A,I5)') "Prescribing ",fld_name,
     &         " fields for mask ",vec_id
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                          SQUEEZE_RIGHT, myThid )
          endif

          DO n_point=1,vec_numPnts_allproc(vec_id, mpiMyId+1)
                i = vec_point_ij(vec_id,1,n_point)
                j = vec_point_ij(vec_id,2,n_point)
                bi = vec_point_ij(vec_id,3,n_point)
                bj = vec_point_ij(vec_id,4,n_point)
                val = vec_subFields(vec_id,mask_fld_index,n_point,1)

                etaN(i,j,bi,bj) = val

C           Fill in the halo region if the point is on the boundary
C                  IF (i.eq.sNx) THEN
C                        DO i_add=1,OLx
C                              etaN(i+i_add,j,bi,bj) = val
C                        ENDDO
C                  ENDIF
C                  IF (i.eq.1) THEN
C                        DO i_add=1,OLx
C                              etaN(i-i_add,j,bi,bj) = val
C                        ENDDO
C                  ENDIF
C                  IF (j.eq.sNy) THEN
C                        DO j_add=1,OLy
C                              etaN(i,j+j_add,bi,bj) = val
C                        ENDDO
C                  ENDIF 
C                  IF (j.eq.1) THEN
C                        DO i_add=1,OLx
C                              etaN(i,j-j_add,bi,bj) = val
C                        ENDDO
C                  ENDIF     

          ENDDO

      ENDIF

      ENDIF

C------------------------------------------------------------------------------|     
      ELSE

      if (debug .eq. 1) then
            WRITE(msgBuf,'(A,A,I2)') " Prescription code skipped",
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

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END PRESCRIBE_VEC DEBUG "
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










