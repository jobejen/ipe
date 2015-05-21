
FORTRAN=ifort

FFLAGS= -132

A_OUT=ipe_gridtrans

OBJECTS= interface_for_interpolate.o IPE_ionosphere_to_thermosphere.o

$(A_OUT): $(OBJECTS)
	$(FORTRAN)  -o $(A_OUT) $(OBJECTS) $(LFLAGS) 

IPE_ionosphere_to_thermosphere.o: IPE_ionosphere_to_thermosphere.f90
	$(FORTRAN) -c $(FFLAGS) IPE_ionosphere_to_thermosphere.f90

interface_for_interpolate.o: interface_for_interpolate.f90
	$(FORTRAN) -c $(FFLAGS) interface_for_interpolate.f90


