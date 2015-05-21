MODULE module_physical_constants
      USE module_precision
      IMPLICIT NONE

      REAL(KIND=real_prec), PARAMETER, PUBLIC :: earth_radius = 6371200.0 !.. Earth radius [meter]
      REAL(KIND=real_prec), PARAMETER, PUBLIC :: pi = 3.1415926536

      REAL(KIND=real_prec), PARAMETER, PUBLIC :: G0 = 9.80665        !.. strength of the Earth's gravity, nominal average value at the Earth's surface (standard gravity) [m s-2]

!note: these parameters must be somewhere in flip! I should remove the duplicate parameters in the future and contain them all in a single module!!!
      REAL(KIND=real_prec),DIMENSION(6), PARAMETER, PUBLIC :: mass_kg=(/16.,1.,28.,32.,4.,14./)
      REAL(KIND=real_prec), PARAMETER, PUBLIC :: AMU = 1.66E-27     ! Atomic Mass Unit [kg]  

END MODULE module_physical_constants
