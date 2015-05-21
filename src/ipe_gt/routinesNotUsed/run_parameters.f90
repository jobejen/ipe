       MODULE RUN_PARAMETERS

       IMPLICIT NONE

       !PUBLIC :: 

       SAVE

      !CHARACTER*100 :: GT_input_dataset , GT_output_dataset
      !character*100 :: static_file_location

      !REAL*8 :: ampl22 , ampl11 , ampl25
      !REAL*8 :: ampl23 , ampl24
      !REAL*8 :: lt22, lt23, lt24, lt11, lt25
      !REAL*8 :: tmpmin  NOT BEING USED  ***
      !REAL*8 :: windmx NOT BEING USED ***
      !INTEGER :: i_smoothing_frequency ,  &


      !INTEGER ::  i_neutral_composition_calling_frequency


      !INTEGER :: i_total_no_days  NOT BEING USED ***
       !INTEGER :: nnstop , nnstrt
       !INTEGER :: nday
       !INTEGER :: GT_timestep_in_seconds
       !REAL*8  :: f107


      !CONTAINS



      !subroutine read_in_run_parameters_from_unit_5

      !IMPLICIT NONE
 

      !READ(5,'(A)') GT_input_dataset
      !READ(5,'(A)') GT_output_dataset

      !READ(5, '(A)' ) static_file_location

      !READ(5,*) nday
      !READ(5,*) f107
 
      !READ(5,*) GT_timestep_in_seconds

      !READ(5,*) nnstrt
      !READ(5,*) nnstop

      !READ(5,*) i_total_no_days

      !READ(5,*) i_smoothing_frequency
      !READ(5,*) i_neutral_composition_calling_frequency
      !READ(5,*) windmx
      !READ(5,*) tmpmin

      !READ(5,*) ampl11, ampl22 , ampl23 , ampl24 , ampl25
      !READ(5,*) lt11 , lt22 , lt23 , lt24 , lt25

      !return

      !end subroutine read_in_run_parameters_from_unit_5


      END MODULE RUN_PARAMETERS
