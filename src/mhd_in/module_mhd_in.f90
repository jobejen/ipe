!this program has the variables that are passed between openggcm and ipe
!Joseph Jensen


module module_mhd_in


implicit none

PUBLIC

!!!!variables from openggcm
      character :: mhd_infile
      character :: mhd_ofile
      character :: mhd_ieprmod
      integer   :: mhd_ff107
      integer   :: mhd_nnp
      integer   :: mhd_nnt
      real*4 ,allocatable,public,save  :: mhd_e_prec_f_1(:,:)
      real*4 ,allocatable,public,save  :: mhd_e_prec_e0_1(:,:)
      real*4 ,allocatable,public,save  :: mhd_e_prec_f_2(:,:)
      real*4 ,allocatable,public,save  :: mhd_e_prec_e0_2(:,:)

!      integer,  :: sw_init_IPE !0: has not been initialized yet; 1:has been initialized; 2: needs to be finalized
      real*8    :: mhd_uttime    !current time of time step in number of seconds that have passed since Jan 1 1966
      real*8    :: mhd_basetime  !the start of the run in number of seconds that have passed since Jan 1 1966
      integer*4 :: mhd_ipotmod   !a flag that will modify the potential according to a factor (potfak) that is chosen by the user
      real*4 ,allocatable,public,save     :: mhd_pot(:,:)       !potential
      integer*4 :: mhd_ist  
      real*4 ,allocatable,public,save    :: mhd_fac_dyn(:,:)   !?
      real*4 ,allocatable,public,save    :: mhd_sigp(:,:)      !pedersen conductance
      real*4 ,allocatable,public,save    :: mhd_sigh(:,:)      !hall conductance
!      logical, PUBLIC :: sw_mhd_potential           !a switch for ipe to use openggcm highlat potential
!      logical, PUBLIC :: sw_mhd_prec           !a switch for ipe to use openggcm highlatitude precipitation
      
      
!!!!

END module module_mhd_in
