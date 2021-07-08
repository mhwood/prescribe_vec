C------------------------------------------------------------------------------|
C                           PRESCRIBE_VEC.h
C------------------------------------------------------------------------------|

#ifdef ALLOW_PRESCRIBE_VEC

C------------------------------------------------------------------------------|
C     Define the global prescribe_vec variables
C------------------------------------------------------------------------------|

      INTEGER, PARAMETER :: nVEC_masks = 8
      INTEGER, PARAMETER :: N_VEC_FIELDS = 5 

C     These are the name of the fields to be prescribed
      CHARACTER*8 vec_flds(N_VEC_FIELDS, nVEC_masks)

C     These are the file names of the input masks
      CHARACTER*30 vec_fname_prefixes(nVEC_masks)

C     These are the file names for the relaxation option
      CHARACTER*30 vec_relax_time_fnames(nVEC_masks)
      CHARACTER*30 vec_relax_mask_fnames(nVEC_masks)

C     This is the number of vertical levels for each field 
C          (1 for surface variables, N for other variables)
      INTEGER vec_levels(N_VEC_FIELDS, nVEC_masks)

C     This is the number of fields for each mask
      INTEGER vec_nFlds(nVEC_masks)

C     This is the number of points in each mask
      INTEGER vec_nPoints(nVEC_masks)

C     This is the number of relaxation points in each mask
      INTEGER vec_nRelaxPoints(nVEC_masks)

C     This is the number of prescription points in each mask
      INTEGER vec_nPrescribePoints(nVEC_masks)

C     These are some i/o parameters to help read in the fields
      INTEGER vec_filePrec
      INTEGER nTimesteps_vec
      LOGICAL vec_fields_include_ICs

C     This an option to either prescribe inside forward_step (vs elsewhere?)
      LOGICAL prescribe_in_forward_step

C     This is where the input masks are stored after they are read in
      _RL vec_subMask(nVEC_masks,1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)

C     This is where the relaxation timescales are stored
C      - these may be provided by a file or stored as 0 by dafault 
      _RL relax_time(nVEC_masks,1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)

C     This is where the relaxation mask is stored stored
C      - this may be provided by a file or stored as 0 by dafault 
      _RL relax_mask(nVEC_masks,1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)

C     This is where the local row and col of the location in the tile are stored
      INTEGER vec_point_ij(nVEC_masks, 4, sNy*sNx)

C     These are dictionaries linking the mask counter to its proc
C           tile, and the row/col within that tile
      INTEGER vec_mask_index_list(nVEC_masks, nPx*nPy, sNy*sNx)

C     These store a list of mask points that each proc has
      INTEGER vec_numPnts_allproc(nVEC_masks, nPx*nPy)

C     This is a buffer where the main variables are stored
      _RL vec_subFields(nVEC_masks,N_VEC_FIELDS,sNy*sNx,Nr)



C------------------------------------------------------------------------------|
C     Create COMMON blocks for the diagnostics_vec variables
C------------------------------------------------------------------------------|

      COMMON / DIAG_VEC_VARS_R /
     &     vec_subFields, vec_subMask,
     &     relax_time, relax_mask

      COMMON / DIAG_VEC_VARS_I /
     &     vec_levels, vec_nPoints,
     &     vec_numPnts_allproc, 
     &     vec_nFlds,
     &     vec_filePrec,nTimeSteps_vec,
     &     vec_mask_index_list,vec_point_ij,
     &     vec_nRelaxPoints, vec_nPrescribePoints

      COMMON / DIAG_VEC_VARS_C /
     &     vec_flds, vec_fname_prefixes,
     &     vec_relax_time_fnames, vec_relax_mask_fnames

      COMMON / DIAG_VEC_VARS_L /
     &     prescribe_in_forward_step,
     &     vec_fields_include_ICs

#endif /* ALLOW_DIAGNOSTICS_VEC */
