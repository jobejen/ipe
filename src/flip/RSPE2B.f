C.................... RSPE2B.FOR ...............................
C... A program to calculate photoelectron fluxes- by Phil Richards
C... 2-stream interhemispheric photoelectron program loosely based on
C... a program by Nagy and Banks but incorporating several of my own
C... innovations. see publications. a more accurate model is available
C... on <pe2s.for> but this one is accurate enough for most purposes.
C... N= density of H+, O+, minor ions(O2+ + NO+), and He+. 
C... TI= temperature of H+, O+, electrons
C... FRPAS= fraction of flux lost in plasmasphere
C... ZWR= altitude for printing spectrum.
      SUBROUTINE PE2S(F107,F107A,N,TI,FRPAS,ZWR,EDEN,UVFAC,COLUM,
     > IHEPLS,INPLS,INNO)
      USE FIELD_LINE_GRID    !.. FLDIM JMIN JMAX FLDIM Z BM GR SL GL SZA
      !..EUVION PEXCIT PEPION OTHPR1 OTHPR2 SUMION SUMEXC PAUION PAUEXC NPLSPRD
      USE THERMOSPHERE  !.. ON HN N2N O2N HE TN UN EHT COLFAC
      USE PRODUCTION !.. EUV, photoelectron, and auroral production
      USE MINORNEUT !.. N4S N2D NNO N2P N2A O1D O1S EQN2D
      IMPLICIT NONE
      include "gptl.inc"
      INTEGER J,IE,IK,IS  !.. altitude, energy, species loop control variables
      INTEGER IDGE(201),JOE(201),JN2E(201) !.. indices for degraded electrons
      INTEGER IPAS,IPASC    !.. grid indices for pitch angle trapping
      INTEGER JMAX1,JMAXM,IEQ
      INTEGER ITS,K  !nm20110923,JTI
      INTEGER IU8,IU9,IWR,IWRC
      INTEGER IEMAX
      INTEGER M,M2,M400,ICF,ICN
      INTEGER EFLAG(11,11) 
      !.. For CMINOR. Turns He+, N+, and NO solutions on and off 
      INTEGER IHEPLS,INPLS,INNO
      integer ret
      REAL ALT,ZLB,ZPAS,ZPROD,ZWR
      REAL AVESEC,SHAPE,AVMU,FNORM
      REAL ELOSS,ELOSSN2,ELOSSO2,ELOSSOX
      REAL EMIN,EMAX,ELIM
      REAL EPOT,EBSCX,DE,EHPAS,ELEFT,ET
      REAL PHISUM,PRION
      REAL S3914,SIGO1D,SIGO1S,TSIG
      REAL SUMTSE,TABSXS,TEST
      REAL VTOT
      REAL F107,F107A,F107SV
      REAL TSIGNE(FLDIM),SECSAV(2,FLDIM),FPAS,PASK
     > ,SIGEX(3),SIGION(3),E(201),XN(3,FLDIM),FYSUM(FLDIM)
     > ,SPRD(3,6),PRED(FLDIM),PRODWN(201,FLDIM)
     > ,PRODUP(201,FLDIM),EB(201),ALTA(FLDIM),DELTE(201)
     > ,PROB(201),PARSIG(22),SIGEL(3),PEBSC(3),UVFAC(59)
      REAL PHIDWN(FLDIM),PHIUP(FLDIM),T1(FLDIM),T2(FLDIM),DS(FLDIM)
      REAL RJOX(201),RJN2(201),RJO2(201),RJHE(201)
      DOUBLE PRECISION N(4,FLDIM),TI(3,FLDIM),FRPAS,
     >  FD(9),EDEN(FLDIM),COLUM(3,FLDIM)

      DATA M, ZLB ,ZPROD,AVMU,EMIN, EMAX,IU9,IU8,ZPAS
     >  / 41, 120., 999.,.577,1.0 , 800.,166,167,1000./
      DATA IWRC /0/,IEMAX/0/,EBSCX/0.0/
      DATA M2/0/,IWR/0/,JN2E/201*0/,SIGEX/3*0.0D0/
      DATA DELTE/201*0.0/
      DATA JOE/201*0/,SIGION/3*0.0D0/,EB/201*0.0/,E/201*0.0/
     
      !.. ionization potential and excitation energy losses
      DATA EPOT,ELOSSOX,ELOSSN2,ELOSSO2,SHAPE/17.0,11.0,10.0,9.0,14.0/
      !.. Burnett&Rountree O branching ratios. O2. need revision
      !.. Shemansky and Liu N2 cross sections, JGR 2005
      DATA SPRD/.4,.56,.44, .4,.28,.44, .2,.06,.10, 0.,.05,.00, 0.,.05
     > ,.00, 0.0,0.0,0.02/
      DATA IDGE/201*0/, F107SV/0.0/

      !.. POSSIBLE speed up options - basic speed is 83 seconds
      !.. 1) lower ZPROD to 600 km - saves 2 seconds 
      !.. 2) Change Energy grid in ECELLS(30.0,800.0,3.0,99.0, saves 11 secs
      !.. 3) Store frequencies and cross sections in data statements

      !.. Setting up energy cell boundaries first time thru only
      !.. If Printing, go to 1 eV resolution  
      ret = gptlstart ('PE2S')
      ret = gptlstart ('PE2S IF1')
      IF(IEMAX.LE.0)  THEN
         ret = gptlstart ('PE2S ECELLS')
         IF(ZWR.LT.80) THEN
	     !.. can use lower resolution for the FLIP run
           CALL ECELLS(35.0,800.0,1.0,50.0,EMAX,IEMAX,EB,E,DELTE)
           !CALL ECELLS(30.0,800.0,3.0,99.0,EMAX,IEMAX,EB,E,DELTE)
         ELSE
	     !.. use high resolution for printing
           CALL ECELLS(65.0,800.0,1.0,20.0,EMAX,IEMAX,EB,E,DELTE)
         ENDIF
         ret = gptlstop  ('PE2S ECELLS')
         !.. set up bins for degraded primaries from ionizations
         ret = gptlstart ('PE2S FNDBIN')
         DO IE=IEMAX,2,-1
           !.. Calculate the average energy of the secondaries.
           ELIM=0.5*(E(IE)-EPOT)  !.. Maximum secondary energy
           !.. normalize secondary distribution
           FNORM=1.0/ATAN(ELIM/SHAPE)/SHAPE     
           AVESEC=FNORM*0.5*SHAPE**2*ALOG(1.0+(ELIM/SHAPE)**2)
           ELOSS=EPOT+AVESEC

           !.. allocate bins for degraded primaries for ionization, and
           !.. excitation of O and N2
           IF(E(IE).GT.ELOSS) CALL FNDBIN(IE,IEMAX,ELOSS,E,IDGE)
           IF(E(IE).GT.ELOSSOX) CALL FNDBIN(IE,IEMAX,ELOSSOX,E,JOE)
           IF(E(IE).GT.ELOSSN2) CALL FNDBIN(IE,IEMAX,ELOSSN2,E,JN2E)
         ENDDO
         ret = gptlstop  ('PE2S FNDBIN')

         !.. proportion of total secondary ions in energy bin E(IE). Note that 
	   !.. a running sum of secondary electrons is kept but only distributed
	   !.. immediately prior to calculating the flux at the next lowest energy. 
         !.. The apportionment is based on an empirical calculation using the 
         !.. full Opal et al. [1971] distributions
         ret = gptlstart ('PE2S calc1')
         DO IE=1,IEMAX
           PROB(IE)=0.2526*EXP(-0.2526*E(IE))
         ENDDO
         ret = gptlstop  ('PE2S calc1')
      ENDIF
      ret = gptlstop ('PE2S IF1')

!nm20110923      JTI=JTI+1

	!..IF(JTI.EQ.2) ZWR=300

      !.. Get production frequencies (RJOX,RJN2,RJO2,RJHE) for the energy cells
      ret = gptlstart ('PE2S CONVF_EUVAC')
      IF(ABS((F107-F107SV)/F107).GE.0.05) THEN
        F107SV=F107
        CALL CONVF_EUVAC(IEMAX,F107,F107A,E,DELTE,UVFAC,
     >   RJOX,RJN2,RJO2,RJHE)
      ENDIF  !.. Endif F107
      ret = gptlstop  ('PE2S CONVF_EUVAC')

      ret = gptlstart ('PE2S calc2')
      IEQ=(JMAX+1)/2

      !.. Set pitch angle trapping factor. FPAS is controlled by input
      !.. parameter FRPAS. There are several options. NOTE - to find
      !.. code related to pitch angle scattering search for string PAS
      FPAS=0.0
      !.. Standard - user specifies 0.0 <= FPAS <= 1.0 
      IF(FRPAS.GE.0.0.AND.FRPAS.LE.1.0) THEN
	  FPAS=FRPAS
      !.. If FRPAS<0, adjust fraction of trapping according to TEC
      ELSEIF(FRPAS.LT.0) THEN
	  FPAS=DMIN1(DABS(FRPAS),6.0E-6*DABS(FRPAS)*N(2,IEQ)*
     >     ((1+Z(IEQ)/6370.)**4-(1+ZPAS/6370.)**4))
      !.. If FRPAS > 1 Stop electrons in plasmasphere but no extra heating
      ELSEIF(FRPAS.GT.1.0) THEN
        FPAS=1.0
      ENDIF
      !.. Make sure 0.0 <= FPAS <= 1.0 
      IF(FPAS.GT.1.0) FPAS=1.0
      IF(FPAS.LT.0.0.OR.Z(IEQ).LE.ZPAS) FPAS=0.0

      DO J=JMIN,JMAX
      DO IK=1,12
      DO IS=1,3
        PEPION(IS,IK,J)=0.0
        PEXCIT(IS,IK,J)=0.0
      ENDDO
      ENDDO
      ENDDO

      DO J=JMIN,JMAX
      DO IE=1,IEMAX
        PRODUP(IE,J)=0.0
        PRODWN(IE,J)=0.0
      ENDDO
      ENDDO

      DO J=JMIN,JMAX
        SECSAV(1,J)=0.0
        SECSAV(2,J)=0.0
        PHIUP(J)=0
        PHIDWN(J)=0
        ALTA(J)=Z(J)
        XN(1,J)=ON(J)
        XN(2,J)=O2N(J)
        XN(3,J)=N2N(J)
        !.. EHT(3,J)=0.0D0 !.. zeroed for CTIPe 2011-09-30
      ENDDO

      !.. Calculate arc length between between points DS and bounday indices
      DO J=JMIN,JMAX
        IF(J.GT.1) DS(J)=SL(J)-SL(J-1)
        IF(Z(J).LT.ZPAS.AND.J.LT.IEQ) IPAS=J
        IF(ZWR.GT.80.AND.Z(J).LE.ZWR.AND.J.LE.IEQ) IWR=J
        IF(Z(J).LE.ZPROD) THEN
          IF(Z(J).LT.400.AND.J.LT.IEQ)  M400=J
          IF(J.LT.IEQ)  M=J
          IF(Z(J).LT.ZLB.AND.J.LT.IEQ)  M2=J
        ENDIF
      ENDDO
      DS(1)=DS(2)
      
      IF(ZLB.LE.Z(2)) M2=2
      JMAX1=2*IEQ-M2     !.. lower boundary in south
      JMAXM=JMAX+1-M     !.. upper boundary in south
      IPASC=2*IEQ-IPAS   !.. pitch angle boundary in south
      IWRC=2*IEQ-IWR     !.. Index for writing conjugate values

      IF(ZWR.GE.Z(1)) WRITE(IU9,319) 
      IF(ZWR.GE.Z(1)) WRITE(IU8,319) 
 319  FORMAT('  E      SIGEXO  SIGIONO  SIGEXN2  SIGION2  SIGEL'
     > '    PRED     FYSUM    TSIGNE   PHIUP    PHIDWN   PRODUP'
     > '   PRODWN')

      !.. Determine tube volume for heating due to pitch angle trapping
      VTOT=0.0
      DO J=IPAS,IPASC-1
        VTOT=VTOT+DS(J)/(BM(J)*2.038E+8)
      ENDDO
      IF(VTOT*BM(M2).GT.0.0) PASK=FPAS/(VTOT*2.038E+8*BM(M2))

      !.. Initial energy index set for highest energy
      IE=IEMAX

C////////////main calculations  begin here ////////////
      ret = gptlstop ('PE2S calc2')
 23   CONTINUE

      !-- Pitch angle trapping from Khazanov et al. 1992
      IF(FRPAS.LT.0) THEN
        FPAS=-FRPAS*(-0.016667*E(IE)+0.9167)
        IF(FPAS.GT.1.0) FPAS=1.0
        IF(FPAS.LT.0.0) FPAS=0.0
        IF(VTOT*BM(M2).GT.0.0) PASK=FPAS/(VTOT*2.038E+8*BM(M2))
      ENDIF

      !.. Evaluate ionization branching ratios for O+
      ret = gptlstart ('PE2S OXRAT')
      CALL OXRAT(E(IE),SPRD(1,1),SPRD(1,2),SPRD(1,3))
      ret = gptlstop  ('PE2S OXRAT')

      !.. O, O2, and N2 elastic cross sections
      ret = gptlstart ('PE2S ELASTC')
      CALL ELASTC(E(IE),PEBSC,SIGEL)
      ret = gptlstop  ('PE2S ELASTC')

      !.. Loop for calculating primary and cascade production
      ret = gptlstart ('PE2S loop1')
      DO J=JMIN,JMAX
        PRED(J)=0.0D0
        IF(Z(J).LE.ZPROD) THEN
          CALL PEPRIM(FLDIM,IE,J,XN,HE(J),PRED,E(IE),DELTE(IE),
     >      COLUM,RJOX,RJN2,RJO2,RJHE)
          !.. add electron quenching of N(2D) to primary prod
          IF(E(IE).LE.3.AND.E(IE).GT.2) THEN
            !.. Needed for updated electron heating in CTIPe
            CALL CMINOR(0,J,0,IHEPLS,INPLS,INNO,FD,7,N,TI,Z,EFLAG)
            PRED(J)=PRED(J)+EQN2D(J)
          ENDIF
          !.. Total energy deposition to photoelectrons
          EUVION(1,11,J)=EUVION(1,11,J)+PRED(J)*E(IE)*DELTE(IE)
        ENDIF
      ENDDO
      ret = gptlstop  ('PE2S loop1')

      !.. Get total cross sections
      ret = gptlstart ('PE2S SIGEXS')
      CALL SIGEXS(E(IE),SIGEX,SIGION,SIGO1D) !.. PGR cross sections
      ret = gptlstop  ('PE2S SIGEXS')

      !.. Get OX partial cross sections
      ret = gptlstart ('PE2S OXSIGS')
      CALL OXSIGS(E(IE),PARSIG,TSIG)
      ret = gptlstop  ('PE2S OXSIGS')

      ret = gptlstart ('PE2S calc3')
      !.. energy loss to thermal electrons by coulomb collisions
      DO J=JMIN,JMAX
        ET=8.618E-5*TI(3,J)
        TSIGNE(J)=((3.37E-12*EDEN(J)**0.97)/(E(IE)**0.94))
     >    *((E(IE)-ET)/(E(IE)-(0.53*ET)))**2.36/(E(IE)-E(IE-1))
        T1(J)=0.0
      ENDDO

      !.. See if energy loss exceeds bin size
	SUMTSE=0.0
      DE=0.0
      DO J=JMIN,JMAX
        TEST=TSIGNE(J)*DS(J)
        IF(Z(J).GT.ZPROD) SUMTSE=SUMTSE+TEST
        IF(Z(J).GT.Z(IPAS)) DE=DE+TEST
        IF(TEST.GT.1.0) TSIGNE(J)=1.0/DELTE(IE)/DS(J)
      ENDDO

      !.. T1,T2 are coeffs of DE. Banks and Kockarts p258
      !.. Calculate total scattering cross section
      DO J=JMIN,JMAX
        T2(J)=TSIGNE(J)
        DO IS=1,3
          T1(J)=T1(J)+XN(IS,J)*SIGEL(IS)*PEBSC(IS)
          TABSXS=SIGEX(IS)+SIGION(IS)
          T2(J)=T2(J)+XN(IS,J)*(SIGEL(IS)*PEBSC(IS)+TABSXS)
        ENDDO
      ENDDO


      !..   fluxes in local equil and set boundary conditions on fluxes
      DO ICN=JMIN,M2
        ICF=2*IEQ-ICN
        PHIDWN(ICN)=(.5*PRED(ICN)+PRODWN(IE,ICN))/(T2(ICN)-T1(ICN))
        PHIDWN(ICF)=(.5*PRED(ICF)+PRODWN(IE,ICF))/(T2(ICF)-T1(ICF))
        PHIUP(ICN)=PHIDWN(ICN)
        PHIUP(ICF)=PHIDWN(ICF)
      ENDDO
      ret = gptlstop  ('PE2S calc3')

      !.. take the adiabatic variation of pitch angle into account
      ret = gptlstart ('PE2S PITCH')
      CALL PITCH(FLDIM,IE,0,M,JMIN,JMAX,T1,T2,PRED,PRODUP,PRODWN,BM,Z)
      ret = gptlstop  ('PE2S PITCH')

      !.. calculate interhemispheric fluxes. The iteration is to adjust 
      !.. for interhemispheric fluxes.Used to be 4 times
      DO ITS=1,2
        ret = gptlstart ('PE2S TRIS1')
        CALL TRIS1(FLDIM,1,M2,M,IE,M,BM,Z,JMAX,PRED,IPAS,FPAS,PHIDWN,
     >     PHIUP,T1,T2,DS,PRODUP,PRODWN)
        ret = gptlstop  ('PE2S TRIS1')
        ret = gptlstart ('PE2S TRISM1')
        CALL TRISM1(FLDIM,-1,JMAXM,JMAX1,IE,M,BM,Z,JMAX,PRED,IPASC,FPAS,
     >     PHIDWN,PHIUP,T1,T2,DS,PRODUP,PRODWN)
        ret = gptlstop  ('PE2S TRISM1')
      ENDDO
      !.. reset the fluxes
      ret = gptlstart ('PE2S PITCH')
      CALL PITCH(FLDIM,IE,1,M,JMIN,JMAX,T1,T2,PRED,PRODUP,PRODWN,BM,Z)
      ret = gptlstop  ('PE2S PITCH')

      !.. EHPAS=heating due to pitch angle trapping: DE= normal loss in the
      !.. protonosphere to electrons. Modification made 1/29/1996 ->
      !.. EHPAS= Energy * (FPAS/VOL) * flux * delta E * area at PAS alt.

      ret = gptlstart ('PE2S calc4')
      EHPAS=E(IE)*PASK*(PHIUP(IPAS)+PHIDWN(IPASC))*DELTE(IE)*
     >       BM(M2)/BM(IPAS)
      IF(DE.GT.E(IE).OR.NINT(FRPAS).EQ.2) EHPAS=0.0

      !.. cross section for O(1S) Jackman et al. 1977
      SIGO1S=0.0
      IF(E(IE).GT.4.17) SIGO1S=6.54E-17*(1-SQRT(4.17/E(IE)))/E(IE)
      !.. Borst and Zipf 3914 cross section used to calculate the branching 
      !.. ratio to the B state. Factor 1.54 is inverse Frank-Condon
      S3914=0.0
      SPRD(3,3)=0.0
      IF(E(IE).GT.19.0) THEN
        S3914=8.83E-16*(1.0-9.0/E(IE))**7.47/E(IE)**0.7
        SPRD(3,3) = 1.54 * S3914/SIGION(3)
      ENDIF

      !.. Save total flux and fluxes for cascade calculation
      DO J=JMIN,JMAX
        FYSUM(J)=(PHIUP(J)+PHIDWN(J))
        !.. electron heating. Add extra heat from pitch angle trapping
        EHT(3,J)=EHT(3,J)+FYSUM(J)*DELTE(IE)*TSIGNE(J)
        IF(Z(J).GT.Z(IPAS)) EHT(3,J)=EHT(3,J)+EHPAS
c        IF(IABS(J-IEQ).LT.Z(IPAS)) EHT(3,J)=EHT(3,J)+EHPAS
      ENDDO
      ret = gptlstop ('PE2S calc4')

      !.. Calculate thermal electron heating and ion production rates
      ret = gptlstart ('PE2S loop2')
      DO J=JMIN,JMAX
        PHISUM=FYSUM(J)*DELTE(IE)
        IF(Z(J).LE.Z(M)) THEN
          !.. excitation of O, O2, and N2
          DO K=1,6
            PEXCIT(1,K,J)=PEXCIT(1,K,J)+PARSIG(K)*(PHISUM*XN(1,J))
          ENDDO

          !.. Total excitation rate for O minus O(1D)
          PEXCIT(1,12,J)=PEXCIT(1,12,J)+(SIGEX(1)-SIGO1D)*
     >       (PHISUM*XN(1,J))
          !.. Total excitation rate for O2
          PEXCIT(2,12,J)=PEXCIT(2,12,J)+SIGEX(2)*PHISUM*XN(2,J)
          !.. Get N2 excitation cross sections
          CALL EPN2XS(J,FLDIM,XN,PHISUM,ALTA(J),E(IE),SIGEX,SIGION,
     >      PEXCIT)

          !.. Calculate secondary ionization rate.
          DO IS=1,3
            PRION=PHISUM*SIGION(IS)*XN(IS,J)
            DO IK=1,6
              PEPION(IS,IK,J)=PEPION(IS,IK,J)+PRION*SPRD(IS,IK)
            ENDDO
          ENDDO
        ENDIF
      ENDDO
      ret = gptlstop ('PE2S loop2')

      !.. printing fluxes
      ret = gptlstart ('PE2S prints')
      IF(ZWR.GT.80) THEN
        WRITE(IU9,313) E(IE),SIGEX(1),SIGION(1),SIGEX(3),SIGION(3)
     >    ,SIGEL(1),PRED(IWR),FYSUM(IWR),TSIGNE(IWR),PHIUP(IWR)
     >    ,PHIDWN(IWR),PRODUP(IE,IWR),PRODWN(IE,IWR)
        WRITE(IU8,313) E(IE),SIGEX(1),SIGION(1),SIGEX(3),SIGION(3)
     >    ,SIGEL(1),PRED(IWRC),FYSUM(IWRC),TSIGNE(IWRC),PHIUP(IWRC)
     >    ,PHIDWN(IWRC),PRODUP(IE,IWRC),PRODWN(IE,IWRC)
      ENDIF
      ret = gptlstop  ('PE2S prints')

      !.. Calculate Cascade production ....
      ret = gptlstart ('PE2S loop3')
      DO J=JMIN,JMAX
        !.. Cascade from thermal electron collisions
        TSIGNE(J)=TSIGNE(J)*DELTE(IE)/DELTE(IE-1)
        PRODUP(IE-1,J)=PRODUP(IE-1,J)+PHIUP(J)*TSIGNE(J)*(1-EBSCX)
     >    +PHIDWN(J)*TSIGNE(J)*EBSCX
        PRODWN(IE-1,J)=PRODWN(IE-1,J)+PHIDWN(J)*TSIGNE(J)*(1-EBSCX)
     >    +PHIUP(J)*TSIGNE(J)*EBSCX

        IF(Z(J).LE.ZPROD) THEN
          !.. calculate secondary and cascade production from ionization
          IF(IE.GT.0) THEN
            CALL CASION(FLDIM,IE,J,ALT,XN,PRODUP,PHIUP(J),PHIDWN(J)
     >       ,E,DELTE,1,SECSAV,SIGION,IEMAX,IDGE(IE),ELOSS,PROB(IE))
            CALL CASION(FLDIM,IE,J,ALT,XN,PRODWN,PHIDWN(J),PHIUP(J)
     >       ,E,DELTE,2,SECSAV,SIGION,IEMAX,IDGE(IE),ELOSS,PROB(IE))
          ENDIF
          !.. calculate cascade from atomic O - O(1D)
          CALL CASEX(FLDIM,IE,1,J,ALTA(J),SIGEX,XN,PRODUP,PHIUP,PHIDWN
     >      ,E,DELTE,JOE(IE),ELOSSOX)
          CALL CASEX(FLDIM,IE,1,J,ALTA(J),SIGEX,XN,PRODWN,PHIDWN,PHIUP
     >      ,E,DELTE,JOE(IE),ELOSSOX)

          !.. cascade from N2
          CALL CASEX(FLDIM,IE,2,J,ALTA(J),SIGEX,XN,PRODUP,PHIUP,PHIDWN
     >      ,E,DELTE,JN2E(IE),ELOSSN2)
          CALL CASEX(FLDIM,IE,2,J,ALTA(J),SIGEX,XN,PRODWN,PHIDWN,PHIUP
     >      ,E,DELTE,JN2E(IE),ELOSSN2)

          !.. cascade from O2
          CALL CASEX(FLDIM,IE,3,J,ALTA(J),SIGEX,XN,PRODUP,PHIUP,PHIDWN
     >      ,E,DELTE,JN2E(IE),ELOSSN2)
          CALL CASEX(FLDIM,IE,3,J,ALTA(J),SIGEX,XN,PRODWN,PHIDWN,PHIUP
     >      ,E,DELTE,JN2E(IE),ELOSSN2)

          !.. Cascade from O(1D) and N2(v)
          CALL CASSIM(FLDIM,IE,J,ALTA(J),SIGEX,XN,PRODUP,PHIUP,PHIDWN
     >       ,E,DELTE,SIGO1D)
          CALL CASSIM(FLDIM,IE,J,ALTA(J),SIGEX,XN,PRODWN,PHIDWN,PHIUP
     >      ,E,DELTE,SIGO1D)
        ENDIF
      ENDDO
      ret = gptlstop ('PE2S loop3')

      IE=IE-1  !.. Go to next lowest energy

      IF(E(IE).LT.EMIN) GO TO 80
      IF (IE .LT. 2) GO TO 80
      GO TO 23
C=========================== END OF MAIN ENERGY LOOP ============

 80   CONTINUE

      !.. add energy from last energy bin to electron heating
      ret = gptlstart ('PE2S loop4')
      DO J=JMIN,JMAX
         ELEFT=+(PRODUP(IE,J)+PRODWN(IE,J))*E(1)
         EHT(3,J)=EHT(3,J)+ELEFT
      ENDDO
      ret = gptlstop  ('PE2S loop4')
      ret = gptlstop  ('PE2S')

      RETURN
 313  FORMAT(F6.1,1P,22E9.2)

         END
C:::::::::::::::::::::::::::::ECELLS:::::::::::::::::::::::::::::::::::
C...... Subroutine to set energy grid for the 2 stream program
C...... EMAX is the maximum energy required. IEMAX=index of max E
C...... It returns the boundaries EB, the midpoint energies E and
C...... the width of the energy cells DELTE
C......  LINEAR energy grid between energies E1 and E2
C...... where the energy steps are S1 and S2
      SUBROUTINE ECELLS(E1,E2,S1,S2,EMAX,IEMAX,EB,E,DELTE)
      IMPLICIT NONE
      INTEGER IE,IEMAX
      REAL E1,E2,S1,S2,EMAX,GRAD,ABSC
      REAL EB(201),E(201),DELTE(201)
	IEMAX=0

      !.. set up cell boundaries EB
      EB(1)=0.0
      DO IE=2,199
	  IF(EB(IE-1).GT.EMAX) GO TO 10
        !.. find gradient and abscissa of linear fit for DELTE
        GRAD=(S2-S1)/(E2-E1)
        ABSC=S1-E1*GRAD
        DELTE(IE)=(GRAD*EB(IE-1)+ABSC)
	  IF(DELTE(IE).GT.S2) DELTE(IE)=S2
        IF(DELTE(IE).LT.1.0) THEN
           GRAD=0.0
           ABSC=1.0
           DELTE(IE)=1.0
        ENDIF
        
	  !.. DELTE must not be less than 1 because the frequencies are 1 eV
        IF(DELTE(IE).LT.1.0) DELTE(IE)=1.0

        EB(IE)=(EB(IE-1)+DELTE(IE))
        !..WRITE(6,95) J,EB(IE),EB(IE-1),DELTE(IE),(GRAD*EB(IE)+ABSC)
      ENDDO

 10   CONTINUE
      IEMAX=IE-2

      !.. Set up cell midpoint energies E(IE) and width DELTE(IE)
      DO IE=1,IEMAX
        E(IE)=0.5*(EB(IE+1)+EB(IE))
        DELTE(IE)=EB(IE+1)-EB(IE)
        !..WRITE(6,95) J,E(IE),DELTE(IE)
      ENDDO
      EMAX=E(IEMAX)

 95   FORMAT(I5,9F9.1)

      RETURN
      END
C::::::::::::::::::::::::::::PITCH:::::::::::::::::::::::::::::::::::
C..... Take pitch angle into account assuming adiabatic variation
C..... along the field line. The pitch angle only varies above the upper
C..... boundary altitude for the PDE calculation Z(M). The program could
C..... be written to avoid this if necessary.
      SUBROUTINE PITCH(FLDIM,IE,IS,M,JMIN,JMAX,T1,T2,PRED,PRODUP,PRODWN,
     >  BM,Z)
      IMPLICIT NONE
      INTEGER J,FLDIM,IE,IS,M,JMIN,JMAX
      REAL T1(FLDIM),T2(FLDIM),PRED(FLDIM),PRODUP(201,FLDIM)
     > ,PRODWN(201,FLDIM)
      REAL RBM,RAVMU
      DOUBLE PRECISION BM(FLDIM),Z(FLDIM)
      !.. RBM used in pitch angle variation
      RBM=0.667/BM(M)
      DO 56 J=JMIN,JMAX
      !.. pitch angle variation above Z(M)
      IF(Z(J).GT.Z(M)) RAVMU=1.0/SQRT(1.0-BM(J)*RBM)
      IF(Z(J).LT.Z(M)) RAVMU=1.73
      !.. To reset after solution
      IF(IS.EQ.1) RAVMU=1.0/RAVMU
      T1(J)=T1(J)*RAVMU
      T2(J)=T2(J)*RAVMU
      PRED(J)=PRED(J)*RAVMU
      PRODUP(IE,J)=PRODUP(IE,J)*RAVMU
      PRODWN(IE,J)=PRODWN(IE,J)*RAVMU
 56   CONTINUE
      RETURN
      END
C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
C....to calculate cascade production rates from electrons o(1d) and n2*
      SUBROUTINE CASSIM(FLDIM,IE,IZ,ALT,SIGEX,XN,PROCAS,PHIUP,PHIDWN
     > ,E,DELTE,SIGO1D)
      IMPLICIT NONE
      INTEGER FLDIM,IE,JK,IZ
      REAL SIGEX(3),XN(3,FLDIM),PROCAS(201,FLDIM),PHIUP(FLDIM)
     > ,E(201),DELTE(201),PHIDWN(FLDIM)
      REAL BSCX,EBSCX,ALT,PREX,CORSIG,SIGO1D

      DATA BSCX,EBSCX/0.5,0.0/

      !... cascade from O(1D) and N2*
      PREX=(PHIUP(IZ)*(1-BSCX)+PHIDWN(IZ)*BSCX)*DELTE(IE)
      JK=IE-2
      IF(JK.GT.0) THEN
         IF(DELTE(IE).GT.1) JK=IE-1
         CORSIG=2.0/(E(IE)-E(JK))
         PROCAS(JK,IZ)=PROCAS(JK,IZ)+PREX*SIGO1D*CORSIG*XN(1,IZ)/
     >   DELTE(JK)
      ENDIF
      IF(E(IE).LT.6) PROCAS(IE-1,IZ)=PROCAS(IE-1,IZ)+PREX*SIGEX(3)*
     >  XN(3,IZ)
      !.. O fine structure
      IF(E(IE).LE.2) PROCAS(IE-1,IZ)=PROCAS(IE-1,IZ)+PREX*SIGEX(1)*
     >  XN(1,IZ)
        RETURN
        END
C::::::::::::::::::::::::::::CASEX:::::::::::::::::::::::::::::::::::
C..... to calculate cascade production rates from excitations
C..... JOE= index of bin for depositing degraded electrons
C..... Modified 2003-20-13 to do all 3 species
      SUBROUTINE CASEX(FLDIM,IE,ISP,IZ,ALT,SIGEX,XN,PROCAS,PHIUP,
     >  PHIDWN,E,DELTE,JOEIN,ELOSS)
      IMPLICIT NONE
      INTEGER FLDIM,IE,ISP,IZ,JOE,JOEM1,JOEM2,JOEIN
      REAL SIGEX(3),XN(3,FLDIM),PROCAS(201,FLDIM),PHIUP(FLDIM)
     > ,E(201),DELTE(201),PHIDWN(FLDIM),SIGION(3)
      REAL BSCX,ALT,PREX,CORSIG,ELOSS
      DATA BSCX/0.5/
      CALL BACKSCAT(E(IE),BSCX)     !.. inelastic backscatter coeff

      JOE=JOEIN
      IF(JOEIN.EQ.IE) JOE=JOEIN-1
      IF(E(IE).LE.ELOSS) RETURN
      JOEM1=JOE
      JOEM2=JOE
      IF(DELTE(JOE).LE.ELOSS.AND.JOE.GE.2) JOEM1=JOE-1
      IF(DELTE(JOE).LE.ELOSS.AND.JOE.GE.2) JOEM2=JOE+1
	IF(JOEM1.LT.1) JOEM1=JOE
	IF(JOEM2.LT.1.OR.JOEM2.GE.IE) JOEM2=JOE
      CORSIG=SIGEX(ISP)*ELOSS/(E(IE)-E(JOE))
      PREX=(PHIUP(IZ)*(1-BSCX)+PHIDWN(IZ)*BSCX)*DELTE(IE)/DELTE(JOE)
      !.. allocate production from bin IE in 2 adjacent bins if small bins
      PREX=0.33333*PREX*CORSIG*XN(ISP,IZ)
      PROCAS(JOE,IZ)=PROCAS(JOE,IZ)+PREX
      PROCAS(JOEM1,IZ)=PROCAS(JOEM1,IZ)+PREX
      PROCAS(JOEM2,IZ)=PROCAS(JOEM2,IZ)+PREX
        RETURN
        END
C:::::::::::::::::::::::::::::::::CASION:::::::::::::::::::::::::::::::::::::
C....... calculate secondary and cascade production from ionizing collisions
      SUBROUTINE CASION(FLDIM,IE,IZ,ALT,XN,PROCAS,PHIUP,PHIDWN
     > ,E,DELTE,ISEC,SECSAV,SIGION,IEMAX,JOE,ELOSS,PROB)
      IMPLICIT NONE
      INTEGER FLDIM,IE,IZ,ISEC,IEMAX,JOE,JOEM1,JOEP1
      REAL SECSAV(2,FLDIM),PROCAS(201,FLDIM),XN(3,FLDIM),SIGION(3),
     > E(201),DELTE(201)
      REAL BSCI,PRION,ELOSS,ALT,PHIUP,PHIDWN,PEFLUP,PROB
      DATA BSCI/0.5/
      CALL BACKSCAT(E(IE),BSCI)     !.. inelastic backscatter coeff

      !.. Total production of ions at E(IE)
      PRION=SIGION(1)*XN(1,IZ)+SIGION(2)*XN(2,IZ)+SIGION(3)*XN(3,IZ)
      PEFLUP=(PHIUP*(1.0-BSCI)+PHIDWN*BSCI)*DELTE(IE)
	!.. A running sum of secondary electrons is kept but only distributed
      !.. immediately prior to calculating the flux at the next lowest energy. 
      !.. The apportionment is based on an empirical calculation using the 
      !.. full Opal et al. [1971] distributions
      !.. total secondary ions produced to energy E(IE)
      SECSAV(ISEC,IZ)=SECSAV(ISEC,IZ)+PRION*(PEFLUP)
      PROCAS(IE-1,IZ)=PROCAS(IE-1,IZ)+SECSAV(ISEC,IZ)*PROB

      !.. Distribute degraded primaries
      IF(JOE.LE.1.OR.JOE.GE.IEMAX) RETURN
      JOEM1=JOE-1
      JOEP1=JOE+1
      IF(JOEP1.LT.IE) THEN
         PRION=0.166666666*PRION*PEFLUP
         PROCAS(JOE,IZ)=PROCAS(JOE,IZ)+2.0*PRION/DELTE(JOE)
         PROCAS(JOEM1,IZ)=PROCAS(JOEM1,IZ)+2.0*PRION/DELTE(JOEM1)
         PROCAS(JOEP1,IZ)=PROCAS(JOEP1,IZ)+2.0*PRION/DELTE(JOEP1)
      ELSE
         PRION=0.3333333*PRION*PEFLUP
         PROCAS(JOE,IZ)=PROCAS(JOE,IZ)+1.5*PRION/DELTE(JOE)
         PROCAS(JOEM1,IZ)=PROCAS(JOEM1,IZ)+1.5*PRION/DELTE(JOEM1)
      ENDIF

      RETURN
      END
C::::::::::::::::::::::::::::::PEPRIM:::::::::::::::::::::::::::::::
C...... this program evaluates  the primary + cascade production rates
C...... by using production frequencies. see richards and torr jgr 1984(5?)
C...... Production frejquencies using Samson and Pareek O X-S. Kirby et
C...... al for O2, and N2, and He
      SUBROUTINE PEPRIM(FLDIM,IE,J,XN,HE,PRED,EE,DELE,COLUM,
     >   RJOX,RJN2,RJO2,RJHE)
      IMPLICIT NONE
      INTEGER FLDIM,J,IE
      REAL EE,EP,DELE,FLXFAC,AFAC,TAU
      REAL T_XS_OX,T_XS_O2,T_XS_N2
      REAL XN(3,FLDIM),PRED(FLDIM)
      !.. Photoelectron production frequencies
      REAL RJOX(201),RJN2(201),RJO2(201),RJHE(201)
      DOUBLE PRECISION COLUM(3,FLDIM),HE

      FLXFAC=1.0
      EP=EE+17      !..  EP= photon energy
      !.. Set the same primary energy for the 20-22 eV peaks
      IF(EE.GT.20.0.AND.EE.LT.29.0) EP=41.0

      !.. total EUV absorption cross sections are T_XS_??.
      T_XS_O2=2.2*T_XS_OX(EP)    !.. O2 XS is 2.2* O XS

      !.. column densities are from subroutine PRIMPR to get attenuation
      TAU=COLUM(1,J)*T_XS_OX(EP)+COLUM(2,J)*T_XS_O2+
     >  COLUM(3,J)*T_XS_N2(EP)

      AFAC=EXP(-TAU)      !.. EUV attenuation factor
	!.. primary production rates
      PRED(J)=(RJOX(IE)*XN(1,J)+RJN2(IE)*XN(3,J)+RJO2(IE)*XN(2,J)
     > +1.0*RJHE(IE)*HE)*1.0E-9*AFAC*FLXFAC

      RETURN
      END
C::::::::::::::::::::::::::::::::FNDBIN::::::::::::::::::::::::::::
C...... A program to determine which bin to allocate a degraded electron
C...... IE= index of the primary of energy EE(IE). IEMAX is the max J, ELOSS=
C...... energy lost by primary and the index is returned in IE
      SUBROUTINE FNDBIN(IE,IEMAX,ELOSS,EE,IDGE)
      IMPLICIT NONE
      INTEGER J,IE,IEMAX,IDGE(IEMAX)
      REAL ELOSS,EE(IEMAX),EDPRIM
      !.. Energy of degraded primary
      EDPRIM=EE(IE)-ELOSS
      !IF(EDPRIM.LT.0.0) WRITE(6,*) '   ELOSS too large in FNDBIN'
      !IF(EDPRIM.LT.0.0) STOP
      !.. Test degraded energy against next lowest bin until it fits
      DO 29 J=IE,2,-1
      IF(EDPRIM.GT.EE(J)) GO TO 30
      IF(ABS(EDPRIM-EE(J)).LE.ABS(0.5*(EE(J)-EE(J-1)))) GO TO 30
 29   CONTINUE
 30   CONTINUE
      !.. store index for return
      IDGE(IE)=J
      !IF(ELOSS.LT.0) WRITE(6,'(2I5,9F8.1)') IE,IDGE(IE),EE(IE),
      !>  EE(IDGE(IE)),ELOSS,EE(IE)-EE(IE-1)
      RETURN
      END
C::::::::::::::::::::::::::::: TRIS1 ::::::::::::::::::::::::::::::
C..... This subroutine is used to solve photoelectron flux, PHIDWN, by
C..... solving the second order PDE derived from the 2-stream equations 
C..... of Nagy and Banks. This is for the Northern Hemisphere
      !.. where PRED = q, PRODUP = q+ and PRODWN = q-
      SUBROUTINE TRIS1(FLDIM,IDIR,M2,M,IE,MT,BM,Z,JMAX,PRED,IPAS,FPAS,
     >  PHIDWN,PHIUP,T1,T2,DS,PRODUP,PRODWN)
      IMPLICIT NONE
      INTEGER J,FLDIM,IDIR,M2,M,IE,MT,IPAS,JMAX,JMAXM1
      REAL FPAS,T2DS,PHI,R1
      REAL DELZ,DLB,DSLB,DLT1,DTS2,DPR1,DPR2,ALPHA,BETA
      REAL A(FLDIM),B(FLDIM),C(FLDIM),D(FLDIM),PRED(FLDIM)
     >  ,PRODWN(201,FLDIM),PRODUP(201,FLDIM) 
      REAL PHIDWN(FLDIM),PHIUP(FLDIM),T1(FLDIM),T2(FLDIM),DS(FLDIM)
      DOUBLE PRECISION Z(FLDIM),BM(FLDIM)

      JMAXM1=JMAX-1
      !.. Do loop for iterating the solutions... PHIDWN is solved using
      !.. TRIDAG solver for one hemisphere, PHIUP is solved analytically to upper
      !.. bdy in conjugate h-s, PHIUP for c.h.s is found using TRIDAG, then
      !.. PHIDWN is solved analytically back along the field line
      DO J=M2,M
        DELZ=DS(J)+DS(J+1)                            ! ds(i)+ds(i+1)
        DLB=(BM(J+1)-BM(J-1))/(BM(J)*DELZ)            ! (dB)/(B*ds)
        DSLB=2.*((BM(J+1)/DS(J+1)+BM(J-1)/DS(J))/DELZ
     &                  -BM(J)/(DS(J+1)*DS(J)))/BM(J) ! (d^2B)/(B*ds^2)
        DLT1=(T1(J+1)-T1(J-1))/(T1(J)*DELZ)           ! (dT1)/(T1*ds)
        DTS2=(T2(J+1)-T2(J-1))/DELZ                   ! (dT2)/(ds)
        DPR1=(PRED(J+1)-PRED(J-1))/(2*DELZ)           ! 0.5*(dq)/(ds)
        DPR2=(PRODWN(IE,J+1)-PRODWN(IE,J-1))/DELZ       ! (dq-)/(ds)
        PHI = 1.
        ALPHA = -(DLT1 + 2.*DLB)         ! -[(dT1)/(T1*ds)+2(dB)/(B*ds)]
        BETA = IDIR*(T2(J)*DLT1-DTS2-DSLB)-T2(J)**2+T1(J)**2-
     >    ALPHA*DLB
        A(J) = (2.*PHI/DS(J)-ALPHA)/DELZ
        B(J) = BETA-2.*PHI/(DS(J)*DS(J+1))
        C(J) = (2.*PHI/DS(J+1)+ALPHA)/DELZ
        D(J) = (.5*PRED(J)+PRODWN(IE,J))*(IDIR*(DLT1+DLB)-T2(J))
     &         -IDIR*(DPR1+DPR2)-T1(J)*(.5*PRED(J)+PRODUP(IE,J))
        !!!  where PRED = q, PRODUP = q+ and PRODWN = q-
      ENDDO
       
      !.. END OF D.E. COEFFS --- SOLUTION FOR NEAR H-S ....
      D(M2)=D(M2)-A(M2)*PHIDWN(M2-1)
      D(M)=D(M)-C(M)*PHIDWN(M+1)
      CALL TRIDAG(FLDIM,PHIDWN,M2,M,A,B,C,D)

 
      !:::::: PHIUP IS EVALUATED  ANALYTICALLY   ::::
      DO J=M2,JMAXM1
        R1=(T1(J)*PHIDWN(J)+(PRED(J)+2.*PRODUP(IE,J))/2.)/
     >     T2(J)/BM(J)
        T2DS=T2(J)*DS(J)
        IF(T2DS.GT.70.0)T2DS=70.0

        PHIUP(J)=BM(J)* (R1+(PHIUP(J-1)/BM(J-1)-R1)*EXP(-T2DS))
        IF(J.EQ.IPAS+1) PHIUP(J)=PHIUP(J)*(1.-FPAS)
      ENDDO
 
      RETURN
      END

C::::::::::::::::::::::::::::::::: TRISM1 :::::::::::::::::::::::::::::::
C..... This subroutine is used to solve photoelectron flux, PHIDWN, by
C..... solving the second order PDE derived from the 2-stream equations 
C..... of Nagy and Banks. This is for the Southern Hemisphere
      !.. where PRED = q, PRODUP = q+ and PRODWN = q-
      SUBROUTINE TRISM1(FLDIM,IDIR,M2,M,IE,MT,BM,Z,JMAX,PRED,IPASC,FPAS,
     >  PHIDWN,PHIUP,T1,T2,DS,PRODUP,PRODWN)
      IMPLICIT NONE
      INTEGER J,K,FLDIM,IDIR,M2,M,IE,MT,IPASC,JMAX,JMAXM2
      REAL DELZ,DLB,DSLB,DLT1,DTS2,DPR1,DPR2,ALPHA,BETA
      REAL FPAS,T2DS,PHI,R1
      DOUBLE PRECISION Z(FLDIM),BM(FLDIM)
      REAL A(FLDIM),B(FLDIM),C(FLDIM),D(FLDIM),PRED(FLDIM)
     > ,PRODWN(201,FLDIM),PRODUP(201,FLDIM)
      REAL PHIDWN(FLDIM),PHIUP(FLDIM),T1(FLDIM),T2(FLDIM),DS(FLDIM)
      JMAXM2=JMAX-MT-1
      !.. Do loop for iterating the solutions... PHIDWN is solved using
      !.. TRIDAG solver for one hemisphere, PHIUP is solved analytically to upper
      !.. bdy in conjugate h-s, PHIUP for c.h.s is found using TRIDAG, then
      !.. PHIDWN is solved analytically back along the field line
      DO J=M2,M
        DELZ=DS(J)+DS(J+1)                            ! ds(i)+ds(i+1)
        DLB=(BM(J+1)-BM(J-1))/(BM(J)*DELZ)            ! (dB)/(B*ds)
        DSLB=2.*((BM(J+1)/DS(J+1)+BM(J-1)/DS(J))/DELZ
     &                  -BM(J)/(DS(J+1)*DS(J)))/BM(J) ! (d^2B)/(B*ds^2)
        DLT1=(T1(J+1)-T1(J-1))/(T1(J)*DELZ)           ! (dT1)/(T1*ds)
        DTS2=(T2(J+1)-T2(J-1))/DELZ                   ! (dT2)/(ds)
        DPR1=(PRED(J+1)-PRED(J-1))/(2*DELZ)           ! 0.5*(dq)/(ds)
        DPR2=(PRODUP(IE,J+1)-PRODUP(IE,J-1))/DELZ       ! (dq+)/(ds)
        PHI = 1.
        ALPHA = -(DLT1 + 2.*DLB)         ! -[(dT1)/(T1*ds)+2(dB)/(B*ds)]
        BETA = IDIR*(T2(J)*DLT1-DTS2-DSLB)-T2(J)**2+T1(J)**2-
     >    ALPHA*DLB
        A(J) = (2.*PHI/DS(J)-ALPHA)/DELZ
        B(J) = BETA-2.*PHI/(DS(J)*DS(J+1))
        C(J) = (2.*PHI/DS(J+1)+ALPHA)/DELZ
        D(J) = (.5*PRED(J)+PRODUP(IE,J))*(IDIR*(DLT1+DLB)-T2(J))
     &         -IDIR*(DPR1+DPR2)-T1(J)*(.5*PRED(J)+PRODWN(IE,J))
      ENDDO

      !.. END OF D.E. COEFFS - CONJUGATE SOLUTIONS 
      D(M2)=D(M2)-A(M2)*PHIUP(M2-1)
      D(M)=D(M)-C(M)*PHIUP(M+1)
      CALL  TRIDAG(FLDIM,PHIUP,M2,M,A,B,C,D)

      !.. PHIDWN IS EVALUATED ANALYTICALLY   ::::
      DO J=1,JMAXM2
        K=JMAX-J
        R1=(T1(K)*PHIUP(K)+(PRED(K)+2.*PRODWN(IE,K))/2.)/T2(K)/BM(K)
        T2DS=T2(K)*DS(K+1)
        IF(T2DS.GT.70.0)T2DS=70.0
        PHIDWN(K)=BM(K)*(R1+(PHIDWN(K+1)/BM(K+1)-R1)*EXP(-T2DS))
        IF(K.EQ.IPASC-1) PHIDWN(K)=PHIDWN(K)*(1-FPAS)
      ENDDO
 
      RETURN
      END
C:::::::::::::::::::::::::: TRIDAG :::::::::::::::::::::::::::::::::::::
C...... For solving a system of linear simultaneous equations with a
C...... Tridiagonal coeff matrix. The eqns are numbered from FIRST to LAST,
C...... & their  sub-diag. , diag. ,& super-diag coeffs. Are stored
C...... In the arrays A, B, C. The right hand side of the vector is
C...... Stored in D. The computed solution vector is stored
C......  In the array DELTA. This routine comes from Carnahan, Luther,
C......  And Wilkes, Applied Numerical Methods, Wiley, 1969, page 446
      SUBROUTINE TRIDAG(FLDIM,DELTA,FIRST,LAST,A,B,C,D)
      IMPLICIT NONE
      include "gptl.inc"
      INTEGER J,FLDIM,K,NUM,LAST,FIRST,FIRSTP1,ret
      REAL A(FLDIM),B(FLDIM),C(FLDIM),D(FLDIM)
      REAL ALPHA(FLDIM),DELTA(FLDIM),GAMMA(FLDIM)
      !..  COMPUTE INTERMEDIATE ARRAYS ALPHA & GAMMA
      ret = gptlstart ('TRIDAG')
      ALPHA(FIRST)=B(FIRST)
      GAMMA(FIRST)=D(FIRST)/ALPHA(FIRST)
      FIRSTP1=FIRST+1
      DO J=FIRSTP1,LAST
        ALPHA(J)=B(J)-A(J)*C(J-1)/ALPHA(J-1)
        GAMMA(J)=(D(J)-A(J)*GAMMA(J-1))/ ALPHA(J)
      ENDDO

      !..  COMPUTE FINAL SOLUTION VECTOR V
      DELTA(LAST)=GAMMA(LAST)
      NUM=LAST-FIRST
      DO K=1,NUM
        J=LAST-K
        DELTA(J)=GAMMA(J)-C(J)*DELTA(J+1)/ALPHA(J)
      ENDDO
      ret = gptlstop  ('TRIDAG')
        RETURN
        END
C::::::::::::::::::::: T_XS_N2 :::::::::::::::::::::::::::
C.... This function calculates the N2 total photoionization
C.... cross section. P. Richards 2003-10-04
      REAL FUNCTION T_XS_N2(EP)
	IMPLICIT NONE
	REAL EP   !.. photon energy
	REAL ESAVE
	DATA ESAVE/0.0/

      !.. Wavelength < 20 A, Auger ionization
	IF(EP.GE.600.0) THEN              
        T_XS_N2=0.5E-18
      !.. Wavelength < 31 A, Auger ionization
	ELSEIF(EP.GE.400.0) THEN              
        T_XS_N2=1.0E-18
      !.. Wavelength 31.62 to 23.70 A
	ELSEIF(EP.GE.392.0) THEN
        T_XS_N2=EXP(7.9864*ALOG(EP)-91.6604)
	!.. Wavelength 225 to 125 A
	ELSEIF(EP.GE.55.09) THEN
        T_XS_N2=EXP(-2.3711*ALOG(EP)-29.8142) 
      !.. Wavelength > 225 A
	ELSE
        T_XS_N2=EXP(-1.1077*ALOG(EP)-34.8787)  
	ENDIF

      !..IF(NINT(10*EP).NE.NINT(10*ESAVE)) WRITE(6,'(2F8.1,1P,2E10.2)') 
      !..> 12394.224/EP,EP, T_XS_N2/(3.39E-17*EXP(-0.0263*EP)), T_XS_N2
	 ESAVE=EP

      !.. old parameterization
      !..T_XS_N2=3.39E-17*EXP(-0.0263*EP)

	RETURN
	END
C::::::::::::::::::::: T_XS_OX :::::::::::::::::::::::::::
C.... This function calculates the OX total photoionization
C.... cross section. P. Richards 2003-10-04
C.... Samson and Pareek Phys. Rev. A, 31, 1470, 1985

      REAL FUNCTION T_XS_OX(EP)
	IMPLICIT NONE
	REAL EP   !.. photon energy
	REAL ESAVE
	DATA ESAVE/0.0/

      !.. NEW parameterization
	IF(EP.GE.500.0) THEN                 
        !.. Wavelength shorter than 25 A, Auger ionization
        T_XS_OX=0.5E-18
	ELSEIF(EP.GE.165.26) THEN                 
        !.. Wavelength shorter than 75 A
        T_XS_OX=EXP(-2.5209*ALOG(EP)-28.8855)
	ELSEIF(EP.GE.55.09) THEN              
        !.. Wavelength between 78 and 256.26 A
        T_XS_OX=EXP(-1.7871*ALOG(EP)-32.6335)
	ELSE
        !.. Wavelength longer than 256.26 A
        T_XS_OX=EXP(-1.3077*ALOG(EP)-34.5556)   
	ENDIF

      !..IF(NINT(10*EP).NE.NINT(10*ESAVE)) WRITE(6,'(2F8.1,1P,2E10.2)') 
      !..> 12394.224/EP,EP, T_XS_OX/(27.2E-18*EXP(-3.09E-2*EP)), T_XS_OX
	 ESAVE=EP

      !.. old parameterization
      !.. T_XS_OX=27.2E-18*EXP(-3.09E-2*EP)

	RETURN
	END
C::::::::::::::::::::::::::::HE10830XS(EP)::::::::::
C.....Function to calculate the He 10830 cross section
C..... Cross section from Lara Waldrup
      REAL FUNCTION HE10830XS(EP)
	IMPLICIT NONE
	REAL EP   !.. photon energy
	REAL pc(0:7)

      !.. fitting coefficients
      data pc/-2.4466E-16,3.2766E-17,-1.7520E-18,5.0229E-20,
     >        -8.4025E-22,8.2195E-24,-4.3589E-26,9.6785E-29/ 
         
      if (EP .lt. 19.82) then
          HE10830XS=0.0
      else if (EP .ge. 19.82 .and. EP .le. 80.0) then
        HE10830XS=pc(0)+pc(1)*EP+pc(2)*EP**2+pc(3)*EP**3+pc(4)*EP**4+
     >            pc(5)*EP**5+pc(6)*EP**6+pc(7)*EP**7
      else
        HE10830XS=7.75E-19*exp(-(EP-100.)/44.)
      endif

	RETURN
	END
