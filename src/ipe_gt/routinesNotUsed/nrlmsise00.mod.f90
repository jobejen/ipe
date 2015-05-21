      subroutine gtd7(iyd,sec,alt,glat,glong,stl,f107a,f107,ap,mass,d,t) 
!                                                                       
!     nrlmsise-00                                                       
!     -----------                                                       
!        neutral atmosphere empirical model from the surface to lower   
!        exosphere                                                      
!                                                                       
!        new features:                                                  
!          *extensive satellite drag database used in model generation  
!          *revised o2 (and o) in lower thermosphere                    
!          *additional nonlinear solar activity term                    
!          *"anomalous oxygen" number density, output d(9)              
!           at high altitudes (> 500 km), hot atomic oxygen or ionized  
!           oxygen can become appreciable for some ranges of subroutine 
!           inputs, thereby affecting drag on satellites and debris. we 
!           group these species under the term "anomalous oxygen," since
!           their individual variations are not presently separable with
!           the drag data used to define this model component.          
!                                                                       
!        subroutines for special outputs:                               
!                                                                       
!        high altitude drag: effective total mass density               
!        (subroutine gtd7d, output d(6))                                
!           for atmospheric drag calculations at altitudes above 500 km,
!           call subroutine gtd7d to compute the "effective total mass  
!           density" by including contributions from "anomalous oxygen."
!           see "notes on output variables" below on d(6).              
!                                                                       
!        pressure grid (subroutine ghp7)                                
!          see subroutine ghp7 to specify outputs at a pressure level   
!          rather than at an altitude.                                  
!                                                                       
!        output in m-3 and kg/m3:   call meters(.true.)                 
!                                                                       
!     input variables:                                                  
!        iyd - year and day as yyddd (day of year from 1 to 365 (or 366)
!              (year ignored in current model)                          
!        sec - ut(sec)                                                  
!        alt - altitude(km)                                             
!        glat - geodetic latitude(deg)                                  
!        glong - geodetic longitude(deg)                                
!        stl - local apparent solar time(hrs; see note below)           
!        f107a - 81 day average of f10.7 flux (centered on day ddd)     
!        f107 - daily f10.7 flux for previous day                       
!        ap - magnetic index(daily) or when sw(9)=-1. :                 
!           - array containing:                                         
!             (1) daily ap                                              
!             (2) 3 hr ap index for current time                        
!             (3) 3 hr ap index for 3 hrs before current time           
!             (4) 3 hr ap index for 6 hrs before current time           
!             (5) 3 hr ap index for 9 hrs before current time           
!             (6) average of eight 3 hr ap indicies from 12 to 33 hrs pr
!                    to current time                                    
!             (7) average of eight 3 hr ap indicies from 36 to 57 hrs pr
!                    to current time                                    
!        mass - mass number (only density for selected gas is           
!                 calculated.  mass 0 is temperature.  mass 48 for all. 
!                 mass 17 is anomalous o only.)                         
!                                                                       
!     notes on input variables:                                         
!        ut, local time, and longitude are used independently in the    
!        model and are not of equal importance for every situation.     
!        for the most physically realistic calculation these three      
!        variables should be consistent (stl=sec/3600+glong/15).        
!        the equation of time departures from the above formula         
!        for apparent local time can be included if available but       
!        are of minor importance.                                       
!                                                                       
!        f107 and f107a values used to generate the model correspond    
!        to the 10.7 cm radio flux at the actual distance of the earth  
!        from the sun rather than the radio flux at 1 au. the following 
!        site provides both classes of values:                          
!        ftp://ftp.ngdc.noaa.gov/stp/solar_data/solar_radio/flux/       
!                                                                       
!        f107, f107a, and ap effects are neither large nor well         
!        established below 80 km and these parameters should be set to  
!        150., 150., and 4. respectively.                               
!                                                                       
!     output variables:                                                 
!        d(1) - he number density(cm-3)                                 
!        d(2) - o number density(cm-3)                                  
!        d(3) - n2 number density(cm-3)                                 
!        d(4) - o2 number density(cm-3)                                 
!        d(5) - ar number density(cm-3)                                 
!        d(6) - total mass density(gm/cm3)                              
!        d(7) - h number density(cm-3)                                  
!        d(8) - n number density(cm-3)                                  
!        d(9) - anomalous oxygen number density(cm-3)                   
!        t(1) - exospheric temperature                                  
!        t(2) - temperature at alt                                      
!                                                                       
!     notes on output variables:                                        
!        to get output in m-3 and kg/m3:   call meters(.true.)          
!                                                                       
!        o, h, and n are set to zero below 72.5 km                      
!                                                                       
!        t(1), exospheric temperature, is set to global average for     
!        altitudes below 120 km. the 120 km gradient is left at global  
!        average value for altitudes below 72 km.                       
!                                                                       
!        d(6), total mass density, is not the same for subroutines gtd7 
!        and gtd7d                                                      
!                                                                       
!          subroutine gtd7 -- d(6) is the sum of the mass densities of t
!          species labeled by indices 1-5 and 7-8 in output variable d. 
!          this includes he, o, n2, o2, ar, h, and n but does not includ
!          anomalous oxygen (species index 9).                          
!                                                                       
!          subroutine gtd7d -- d(6) is the "effective total mass density
!          for drag" and is the sum of the mass densities of all species
!          in this model, including anomalous oxygen.                   
!                                                                       
!     switches: the following is for test and special purposes:         
!                                                                       
!        to turn on and off particular variations call tselec(sw),      
!        where sw is a 25 element array containing 0. for off, 1.       
!        for on, or 2. for main effects off but cross terms on          
!        for the following variations                                   
!               1 - f10.7 effect on mean  2 - time independent          
!               3 - symmetrical annual    4 - symmetrical semiannual    
!               5 - asymmetrical annual   6 - asymmetrical semiannual   
!               7 - diurnal               8 - semidiurnal               
!               9 - daily ap             10 - all ut/long effects       
!              11 - longitudinal         12 - ut and mixed ut/long      
!              13 - mixed ap/ut/long     14 - terdiurnal                
!              15 - departures from diffusive equilibrium               
!              16 - all tinf var         17 - all tlb var               
!              18 - all tn1 var           19 - all s var                
!              20 - all tn2 var           21 - all nlb var              
!              22 - all tn3 var           23 - turbo scale height var   
!                                                                       
!        to get current values of sw: call tretrv(sw)                   
!                                                                       
      dimension d(9),t(2),ap(7),ds(9),ts(2) 
      dimension zn3(5),zn2(4),sv(25) 
      common/gts3c/tlb,s,db04,db16,db28,db32,db40,db48,db01,za,t0,z0    &
     & ,g0,rl,dd,db14,tr12                                              
      common/meso7/tn1(5),tn2(4),tn3(5),tgn1(2),tgn2(2),tgn3(2) 
      common/lower7/ptm(10),pdm(10,8) 
      common/parm7/pt(150),pd(150,9),ps(150),pdl(25,2),ptl(100,4),      &
     & pma(100,10),sam(100)                                             
      common/datim7/isd(3),ist(2),nam(2) 
      common/datime/isdate(3),istime(2),name(2) 
      common/csw/sw(25),isw,swc(25) 
      common/mavg7/pavgm(10) 
      common/dmix/dm04,dm16,dm28,dm32,dm40,dm01,dm14 
      common/parmb/gsurf,re 
      common/metsel/imr 
      save 
      external gtd7bk 
      data mn3/5/,zn3/32.5,20.,15.,10.,0./ 
      data mn2/4/,zn2/72.5,55.,45.,32.5/ 
      data zmix/62.5/,alast/99999./,mssl/-999/ 
      data sv/25*1./ 
      if(isw.ne.64999) call tselec(sv) 
!      put identification data into common/datime/                      
      do 1 i=1,3 
        isdate(i)=isd(i) 
    1 end do 
      do 2 i=1,2 
        istime(i)=ist(i) 
        name(i)=nam(i) 
    2 end do 
!                                                                       
!        test for changed input                                         
      v1=vtst7(iyd,sec,glat,glong,stl,f107a,f107,ap,1) 
!       latitude variation of gravity (none for sw(2)=0)                
      xlat=glat 
      if(sw(2).eq.0) xlat=45. 
      call glatf(xlat,gsurf,re) 
!                                                                       
      xmm=pdm(5,3) 
!                                                                       
!       thermosphere/mesosphere (above zn2(1))                          
      altt=amax1(alt,zn2(1)) 
      mss=mass 
!       only calculate n2 in thermosphere if alt in mixed region        
      if(alt.lt.zmix.and.mass.gt.0) mss=28 
!       only calculate thermosphere if input parameters changed         
!         or altitude above zn2(1) in mesosphere                        
      if(v1.eq.1..or.alt.gt.zn2(1).or.alast.gt.zn2(1).or.mss.ne.mssl)   &
     & then                                                             
        call gts7(iyd,sec,altt,glat,glong,stl,f107a,f107,ap,mss,ds,ts) 
        dm28m=dm28 
!         metric adjustment                                             
        if(imr.eq.1) dm28m=dm28*1.e6 
        mssl=mss 
      endif 
      t(1)=ts(1) 
      t(2)=ts(2) 
      if(alt.ge.zn2(1)) then 
        do 5 j=1,9 
          d(j)=ds(j) 
    5   continue 
        goto 10 
      endif 
!                                                                       
!       lower mesosphere/upper stratosphere [between zn3(1) and zn2(1)] 
!         temperature at nodes and gradients at end nodes               
!         inverse temperature a linear function of spherical harmonics  
!         only calculate nodes if input changed                         
       if(v1.eq.1..or.alast.ge.zn2(1)) then 
        tgn2(1)=tgn1(2) 
        tn2(1)=tn1(5) 
        tn2(2)=pma(1,1)*pavgm(1)/(1.-sw(20)*glob7s(pma(1,1))) 
        tn2(3)=pma(1,2)*pavgm(2)/(1.-sw(20)*glob7s(pma(1,2))) 
        tn2(4)=pma(1,3)*pavgm(3)/(1.-sw(20)*sw(22)*glob7s(pma(1,3))) 
        tgn2(2)=pavgm(9)*pma(1,10)*(1.+sw(20)*sw(22)*glob7s(pma(1,10))) &
     &  *tn2(4)*tn2(4)/(pma(1,3)*pavgm(3))**2                           
        tn3(1)=tn2(4) 
       endif 
       if(alt.ge.zn3(1)) goto 6 
!                                                                       
!       lower stratosphere and troposphere [below zn3(1)]               
!         temperature at nodes and gradients at end nodes               
!         inverse temperature a linear function of spherical harmonics  
!         only calculate nodes if input changed                         
        if(v1.eq.1..or.alast.ge.zn3(1)) then 
         tgn3(1)=tgn2(2) 
         tn3(2)=pma(1,4)*pavgm(4)/(1.-sw(22)*glob7s(pma(1,4))) 
         tn3(3)=pma(1,5)*pavgm(5)/(1.-sw(22)*glob7s(pma(1,5))) 
         tn3(4)=pma(1,6)*pavgm(6)/(1.-sw(22)*glob7s(pma(1,6))) 
         tn3(5)=pma(1,7)*pavgm(7)/(1.-sw(22)*glob7s(pma(1,7))) 
         tgn3(2)=pma(1,8)*pavgm(8)*(1.+sw(22)*glob7s(pma(1,8)))         &
     &   *tn3(5)*tn3(5)/(pma(1,7)*pavgm(7))**2                          
        endif 
    6   continue 
        if(mass.eq.0) goto 50 
!          linear transition to full mixing below zn2(1)                
        dmc=0 
        if(alt.gt.zmix) dmc=1.-(zn2(1)-alt)/(zn2(1)-zmix) 
        dz28=ds(3) 
!      ***** n2 density ****                                            
        dmr=ds(3)/dm28m-1. 
        d(3)=densm(alt,dm28m,xmm,tz,mn3,zn3,tn3,tgn3,mn2,zn2,tn2,tgn2) 
        d(3)=d(3)*(1.+dmr*dmc) 
!      ***** he density ****                                            
        d(1)=0 
        if(mass.ne.4.and.mass.ne.48) goto 204 
          dmr=ds(1)/(dz28*pdm(2,1))-1. 
          d(1)=d(3)*pdm(2,1)*(1.+dmr*dmc) 
  204   continue 
!      **** o density ****                                              
        d(2)=0 
        d(9)=0 
  216   continue 
!      ***** o2 density ****                                            
        d(4)=0 
        if(mass.ne.32.and.mass.ne.48) goto 232 
          dmr=ds(4)/(dz28*pdm(2,4))-1. 
          d(4)=d(3)*pdm(2,4)*(1.+dmr*dmc) 
  232   continue 
!      ***** ar density ****                                            
        d(5)=0 
        if(mass.ne.40.and.mass.ne.48) goto 240 
          dmr=ds(5)/(dz28*pdm(2,5))-1. 
          d(5)=d(3)*pdm(2,5)*(1.+dmr*dmc) 
  240   continue 
!      ***** hydrogen density ****                                      
        d(7)=0 
!      ***** atomic nitrogen density ****                               
        d(8)=0 
!                                                                       
!       total mass density                                              
!                                                                       
        if(mass.eq.48) then 
         d(6) = 1.66e-24*(4.*d(1)+16.*d(2)+28.*d(3)+32.*d(4)+40.*d(5)+  &
     &       d(7)+14.*d(8))                                             
         if(imr.eq.1) d(6)=d(6)/1000. 
         endif 
         t(2)=tz 
   10 continue 
      goto 90 
   50 continue 
      dd=densm(alt,1.,0,tz,mn3,zn3,tn3,tgn3,mn2,zn2,tn2,tgn2) 
      t(2)=tz 
   90 continue 
      alast=alt 
      return 
      end                                           
!-----------------------------------------------------------------------
      subroutine gtd7d(iyd,sec,alt,glat,glong,stl,f107a,f107,ap,mass,   &
     & d,t)                                                             
!                                                                       
!     nrlmsise-00                                                       
!     -----------                                                       
!        this subroutine provides effective total mass density for      
!        output d(6) which includes contributions from "anomalous       
!        oxygen" which can affect satellite drag above 500 km.  this    
!        subroutine is part of the distribution package for the         
!        neutral atmosphere empirical model from the surface to lower   
!        exosphere.  see subroutine gtd7 for more extensive comments.   
!                                                                       
!     input variables:                                                  
!        iyd - year and day as yyddd (day of year from 1 to 365 (or 366)
!              (year ignored in current model)                          
!        sec - ut(sec)                                                  
!        alt - altitude(km)                                             
!        glat - geodetic latitude(deg)                                  
!        glong - geodetic longitude(deg)                                
!        stl - local apparent solar time(hrs; see note below)           
!        f107a - 81 day average of f10.7 flux (centered on day ddd)     
!        f107 - daily f10.7 flux for previous day                       
!        ap - magnetic index(daily) or when sw(9)=-1. :                 
!           - array containing:                                         
!             (1) daily ap                                              
!             (2) 3 hr ap index for current time                        
!             (3) 3 hr ap index for 3 hrs before current time           
!             (4) 3 hr ap index for 6 hrs before current time           
!             (5) 3 hr ap index for 9 hrs before current time           
!             (6) average of eight 3 hr ap indicies from 12 to 33 hrs pr
!                    to current time                                    
!             (7) average of eight 3 hr ap indicies from 36 to 57 hrs pr
!                    to current time                                    
!        mass - mass number (only density for selected gas is           
!                 calculated.  mass 0 is temperature.  mass 48 for all. 
!                 mass 17 is anomalous o only.)                         
!                                                                       
!     notes on input variables:                                         
!        ut, local time, and longitude are used independently in the    
!        model and are not of equal importance for every situation.     
!        for the most physically realistic calculation these three      
!        variables should be consistent (stl=sec/3600+glong/15).        
!        the equation of time departures from the above formula         
!        for apparent local time can be included if available but       
!        are of minor importance.                                       
!                                                                       
!        f107 and f107a values used to generate the model correspond    
!        to the 10.7 cm radio flux at the actual distance of the earth  
!        from the sun rather than the radio flux at 1 au.               
!                                                                       
!     output variables:                                                 
!        d(1) - he number density(cm-3)                                 
!        d(2) - o number density(cm-3)                                  
!        d(3) - n2 number density(cm-3)                                 
!        d(4) - o2 number density(cm-3)                                 
!        d(5) - ar number density(cm-3)                                 
!        d(6) - total mass density(gm/cm3) [includes anomalous oxygen]  
!        d(7) - h number density(cm-3)                                  
!        d(8) - n number density(cm-3)                                  
!        d(9) - anomalous oxygen number density(cm-3)                   
!        t(1) - exospheric temperature                                  
!        t(2) - temperature at alt                                      
!                                                                       
      dimension d(9),t(2),ap(7),ds(9),ts(2) 
      common/metsel/imr 
      call gtd7(iyd,sec,alt,glat,glong,stl,f107a,f107,ap,mass,d,t) 
!       total mass density                                              
!                                                                       
        if(mass.eq.48) then 
         d(6) = 1.66e-24*(4.*d(1)+16.*d(2)+28.*d(3)+32.*d(4)+40.*d(5)+  &
     &       d(7)+14.*d(8)+16.*d(9))                                    
         if(imr.eq.1) d(6)=d(6)/1000. 
         endif 
      return 
      end                                           
!-----------------------------------------------------------------------
      subroutine ghp7(iyd,sec,alt,glat,glong,stl,f107a,f107,ap,         &
     &  d,t,press)                                                      
!       find altitude of pressure surface (press) from gtd7             
!     input:                                                            
!        iyd - year and day as yyddd                                    
!        sec - ut(sec)                                                  
!        glat - geodetic latitude(deg)                                  
!        glong - geodetic longitude(deg)                                
!        stl - local apparent solar time(hrs)                           
!        f107a - 3 month average of f10.7 flux                          
!        f107 - daily f10.7 flux for previous day                       
!        ap - magnetic index(daily) or when sw(9)=-1. :                 
!           - array containing:                                         
!             (1) daily ap                                              
!             (2) 3 hr ap index for current time                        
!             (3) 3 hr ap index for 3 hrs before current time           
!             (4) 3 hr ap index for 6 hrs before current time           
!             (5) 3 hr ap index for 9 hrs before current time           
!             (6) average of eight 3 hr ap indicies from 12 to 33 hrs pr
!                    to current time                                    
!             (7) average of eight 3 hr ap indicies from 36 to 59 hrs pr
!                    to current time                                    
!        press - pressure level(mb)                                     
!     output:                                                           
!        alt - altitude(km)                                             
!        d(1) - he number density(cm-3)                                 
!        d(2) - o number density(cm-3)                                  
!        d(3) - n2 number density(cm-3)                                 
!        d(4) - o2 number density(cm-3)                                 
!        d(5) - ar number density(cm-3)                                 
!        d(6) - total mass density(gm/cm3)                              
!        d(7) - h number density(cm-3)                                  
!        d(8) - n number density(cm-3)                                  
!        d(9) - hot o number density(cm-3)                              
!        t(1) - exospheric temperature                                  
!        t(2) - temperature at alt                                      
!                                                                       
      common/parmb/gsurf,re 
      common/metsel/imr 
      dimension d(9),t(2),ap(7) 
      save 
      data bm/1.3806e-19/,rgas/831.4/ 
      data test/.00043/,ltest/12/ 
      pl=alog10(press) 
!      initial altitude estimate                                        
      if(pl.ge.-5.) then 
         if(pl.gt.2.5) zi=18.06*(3.00-pl) 
         if(pl.gt..75.and.pl.le.2.5) zi=14.98*(3.08-pl) 
         if(pl.gt.-1..and.pl.le..75) zi=17.8*(2.72-pl) 
         if(pl.gt.-2..and.pl.le.-1.) zi=14.28*(3.64-pl) 
         if(pl.gt.-4..and.pl.le.-2.) zi=12.72*(4.32-pl) 
         if(pl.le.-4.) zi=25.3*(.11-pl) 
         iday=mod(iyd,1000) 
         cl=glat/90. 
         cl2=cl*cl 
         if(iday.lt.182) cd=1.-iday/91.25 
         if(iday.ge.182) cd=iday/91.25-3. 
         ca=0 
         if(pl.gt.-1.11.and.pl.le.-.23) ca=1.0 
         if(pl.gt.-.23) ca=(2.79-pl)/(2.79+.23) 
         if(pl.le.-1.11.and.pl.gt.-3.) ca=(-2.93-pl)/(-2.93+1.11) 
         z=zi-4.87*cl*cd*ca-1.64*cl2*ca+.31*ca*cl 
      endif 
      if(pl.lt.-5.) z=22.*(pl+4.)**2+110 
!      iteration loop                                                   
      l=0 
   10 continue 
        l=l+1 
        call gtd7(iyd,sec,z,glat,glong,stl,f107a,f107,ap,48,d,t) 
        xn=d(1)+d(2)+d(3)+d(4)+d(5)+d(7)+d(8) 
        p=bm*xn*t(2) 
        if(imr.eq.1) p=p*1.e-6 
        diff=pl-alog10(p) 
        if(abs(diff).lt.test .or. l.eq.ltest) goto 20 
        xm=d(6)/xn/1.66e-24 
        if(imr.eq.1) xm = xm*1.e3 
        g=gsurf/(1.+z/re)**2 
        sh=rgas*t(2)/(xm*g) 
!         new altitude estimate using scale height                      
        if(l.lt.6) then 
          z=z-sh*diff*2.302 
        else 
          z=z-sh*diff 
        endif 
        goto 10 
   20 continue 
      if(l.eq.ltest) write(6,100) press,diff 
  100 format(1x,29hghp7 not converging for press, 1pe12.2,e12.2) 
      alt=z 
      return 
      end                                           
!-----------------------------------------------------------------------
      subroutine glatf(lat,gv,reff) 
!      calculate latitude variable gravity (gv) and effective           
!      radius (reff)                                                    
      real lat 
      save 
      data dgtr/1.74533e-2/ 
      c2 = cos(2.*dgtr*lat) 
      gv = 980.616*(1.-.0026373*c2) 
      reff = 2.*gv/(3.085462e-6 + 2.27e-9*c2)*1.e-5 
      return 
      end                                           
!-----------------------------------------------------------------------
      function vtst7(iyd,sec,glat,glong,stl,f107a,f107,ap,ic) 
!       test if geophysical variables or switches changed and save      
!       return 0 if unchanged and 1 if changed                          
      dimension ap(7),iydl(2),secl(2),glatl(2),gll(2),stll(2) 
      dimension fal(2),fl(2),apl(7,2),swl(25,2),swcl(25,2) 
      common/csw/sw(25),isw,swc(25) 
      save 
      data iydl/2*-999/,secl/2*-999./,glatl/2*-999./,gll/2*-999./ 
      data stll/2*-999./,fal/2*-999./,fl/2*-999./,apl/14*-999./ 
      data swl/50*-999./,swcl/50*-999./ 
      vtst7=0 
      if(iyd.ne.iydl(ic)) goto 10 
      if(sec.ne.secl(ic)) goto 10 
      if(glat.ne.glatl(ic)) goto 10 
      if(glong.ne.gll(ic)) goto 10 
      if(stl.ne.stll(ic)) goto 10 
      if(f107a.ne.fal(ic)) goto 10 
      if(f107.ne.fl(ic)) goto 10 
      do 5 i=1,7 
        if(ap(i).ne.apl(i,ic)) goto 10 
    5 end do 
      do 7 i=1,25 
        if(sw(i).ne.swl(i,ic)) goto 10 
        if(swc(i).ne.swcl(i,ic)) goto 10 
    7 end do 
      goto 20 
   10 continue 
      vtst7=1 
      iydl(ic)=iyd 
      secl(ic)=sec 
      glatl(ic)=glat 
      gll(ic)=glong 
      stll(ic)=stl 
      fal(ic)=f107a 
      fl(ic)=f107 
      do 15 i=1,7 
        apl(i,ic)=ap(i) 
   15 end do 
      do 16 i=1,25 
        swl(i,ic)=sw(i) 
        swcl(i,ic)=swc(i) 
   16 end do 
   20 continue 
      return 
      end                                           
!-----------------------------------------------------------------------
      subroutine gts7(iyd,sec,alt,glat,glong,stl,f107a,f107,ap,mass,d,t) 
!                                                                       
!     thermospheric portion of nrlmsise-00                              
!     see gtd7 for more extensive comments                              
!                                                                       
!        output in m-3 and kg/m3:   call meters(.true.)                 
!                                                                       
!     input variables:                                                  
!        iyd - year and day as yyddd (day of year from 1 to 365 (or 366)
!              (year ignored in current model)                          
!        sec - ut(sec)                                                  
!        alt - altitude(km) (>72.5 km)                                  
!        glat - geodetic latitude(deg)                                  
!        glong - geodetic longitude(deg)                                
!        stl - local apparent solar time(hrs; see note below)           
!        f107a - 81 day average of f10.7 flux (centered on day ddd)     
!        f107 - daily f10.7 flux for previous day                       
!        ap - magnetic index(daily) or when sw(9)=-1. :                 
!           - array containing:                                         
!             (1) daily ap                                              
!             (2) 3 hr ap index for current time                        
!             (3) 3 hr ap index for 3 hrs before current time           
!             (4) 3 hr ap index for 6 hrs before current time           
!             (5) 3 hr ap index for 9 hrs before current time           
!             (6) average of eight 3 hr ap indicies from 12 to 33 hrs pr
!                    to current time                                    
!             (7) average of eight 3 hr ap indicies from 36 to 57 hrs pr
!                    to current time                                    
!        mass - mass number (only density for selected gas is           
!                 calculated.  mass 0 is temperature.  mass 48 for all. 
!                 mass 17 is anomalous o only.)                         
!                                                                       
!     notes on input variables:                                         
!        ut, local time, and longitude are used independently in the    
!        model and are not of equal importance for every situation.     
!        for the most physically realistic calculation these three      
!        variables should be consistent (stl=sec/3600+glong/15).        
!        the equation of time departures from the above formula         
!        for apparent local time can be included if available but       
!        are of minor importance.                                       
!                                                                       
!        f107 and f107a values used to generate the model correspond    
!        to the 10.7 cm radio flux at the actual distance of the earth  
!        from the sun rather than the radio flux at 1 au. the following 
!        site provides both classes of values:                          
!        ftp://ftp.ngdc.noaa.gov/stp/solar_data/solar_radio/flux/       
!                                                                       
!        f107, f107a, and ap effects are neither large nor well         
!        established below 80 km and these parameters should be set to  
!        150., 150., and 4. respectively.                               
!                                                                       
!     output variables:                                                 
!        d(1) - he number density(cm-3)                                 
!        d(2) - o number density(cm-3)                                  
!        d(3) - n2 number density(cm-3)                                 
!        d(4) - o2 number density(cm-3)                                 
!        d(5) - ar number density(cm-3)                                 
!        d(6) - total mass density(gm/cm3) [anomalous o not included]   
!        d(7) - h number density(cm-3)                                  
!        d(8) - n number density(cm-3)                                  
!        d(9) - anomalous oxygen number density(cm-3)                   
!        t(1) - exospheric temperature                                  
!        t(2) - temperature at alt                                      
!                                                                       
      dimension zn1(5),alpha(9) 
      common/gts3c/tlb,s,db04,db16,db28,db32,db40,db48,db01,za,t0,z0    &
     & ,g0,rl,dd,db14,tr12                                              
      common/meso7/tn1(5),tn2(4),tn3(5),tgn1(2),tgn2(2),tgn3(2) 
      dimension d(9),t(2),mt(11),ap(1),altl(8) 
      common/lower7/ptm(10),pdm(10,8) 
      common/parm7/pt(150),pd(150,9),ps(150),pdl(25,2),ptl(100,4),      &
     & pma(100,10),sam(100)                                             
      common/csw/sw(25),isw,swc(25) 
      common/ttest/tinfg,gb,rout,tt(15) 
      common/dmix/dm04,dm16,dm28,dm32,dm40,dm01,dm14 
      common/metsel/imr 
      save 
      data mt/48,0,4,16,28,32,40,1,49,14,17/ 
      data altl/200.,300.,160.,250.,240.,450.,320.,450./ 
      data mn1/5/,zn1/120.,110.,100.,90.,72.5/ 
      data dgtr/1.74533e-2/,dr/1.72142e-2/,alast/-999./ 
      data alpha/-0.38,0.,0.,0.,0.17,0.,-0.38,0.,0./ 
!        test for changed input                                         
      v2=vtst7(iyd,sec,glat,glong,stl,f107a,f107,ap,2) 
!                                                                       
      yrd=iyd 
      za=pdl(16,2) 
      zn1(1)=za 
      do 2 j=1,9 
        d(j)=0. 
    2 end do 
!        tinf variations not important below za or zn1(1)               
      if(alt.gt.zn1(1)) then 
        if(v2.eq.1..or.alast.le.zn1(1)) tinf=ptm(1)*pt(1)               &
     &  *(1.+sw(16)*globe7(yrd,sec,glat,glong,stl,f107a,f107,ap,pt))    
      else 
        tinf=ptm(1)*pt(1) 
      endif 
      t(1)=tinf 
!          gradient variations not important below zn1(5)               
      if(alt.gt.zn1(5)) then 
        if(v2.eq.1.or.alast.le.zn1(5)) g0=ptm(4)*ps(1)                  &
     &   *(1.+sw(19)*globe7(yrd,sec,glat,glong,stl,f107a,f107,ap,ps))   
      else 
        g0=ptm(4)*ps(1) 
      endif 
!      calculate these temperatures only if input changed               
      if(v2.eq.1. .or. alt.lt.300.)                                     &
     &  tlb=ptm(2)*(1.+sw(17)*globe7(yrd,sec,glat,glong,stl,            &
     &  f107a,f107,ap,pd(1,4)))*pd(1,4)                                 
       s=g0/(tinf-tlb) 
!       lower thermosphere temp variations not significant for          
!        density above 300 km                                           
       if(alt.lt.300.) then 
        if(v2.eq.1..or.alast.ge.300.) then 
         tn1(2)=ptm(7)*ptl(1,1)/(1.-sw(18)*glob7s(ptl(1,1))) 
         tn1(3)=ptm(3)*ptl(1,2)/(1.-sw(18)*glob7s(ptl(1,2))) 
         tn1(4)=ptm(8)*ptl(1,3)/(1.-sw(18)*glob7s(ptl(1,3))) 
         tn1(5)=ptm(5)*ptl(1,4)/(1.-sw(18)*sw(20)*glob7s(ptl(1,4))) 
         tgn1(2)=ptm(9)*pma(1,9)*(1.+sw(18)*sw(20)*glob7s(pma(1,9)))    &
     &   *tn1(5)*tn1(5)/(ptm(5)*ptl(1,4))**2                            
        endif 
       else 
        tn1(2)=ptm(7)*ptl(1,1) 
        tn1(3)=ptm(3)*ptl(1,2) 
        tn1(4)=ptm(8)*ptl(1,3) 
        tn1(5)=ptm(5)*ptl(1,4) 
        tgn1(2)=ptm(9)*pma(1,9)                                         &
     &  *tn1(5)*tn1(5)/(ptm(5)*ptl(1,4))**2                             
       endif 
!                                                                       
      z0=zn1(4) 
      t0=tn1(4) 
      tr12=1. 
!                                                                       
      if(mass.eq.0) go to 50 
!       n2 variation factor at zlb                                      
      g28=sw(21)*globe7(yrd,sec,glat,glong,stl,f107a,f107,              &
     & ap,pd(1,3))                                                      
      day=amod(yrd,1000.) 
!        variation of turbopause height                                 
      zhf=pdl(25,2)                                                     &
     &    *(1.+sw(5)*pdl(25,1)*sin(dgtr*glat)*cos(dr*(day-pt(14))))     
      yrd=iyd 
      t(1)=tinf 
      xmm=pdm(5,3) 
      z=alt 
!                                                                       
      do 10 j = 1,11 
      if(mass.eq.mt(j))   go to 15 
   10 end do 
      write(6,100) mass 
      go to 90 
   15 if(z.gt.altl(6).and.mass.ne.28.and.mass.ne.48) go to 17 
!                                                                       
!       **** n2 density ****                                            
!                                                                       
!      diffusive density at zlb                                         
      db28 = pdm(1,3)*exp(g28)*pd(1,3) 
!      diffusive density at alt                                         
      d(3)=densu(z,db28,tinf,tlb, 28.,alpha(3),t(2),ptm(6),s,mn1,zn1,   &
     & tn1,tgn1)                                                        
      dd=d(3) 
!      turbopause                                                       
      zh28=pdm(3,3)*zhf 
      zhm28=pdm(4,3)*pdl(6,2) 
      xmd=28.-xmm 
!      mixed density at zlb                                             
      b28=densu(zh28,db28,tinf,tlb,xmd,alpha(3)-1.,tz,ptm(6),s,mn1,     &
     & zn1,tn1,tgn1)                                                    
      if(z.gt.altl(3).or.sw(15).eq.0.) go to 17 
!      mixed density at alt                                             
      dm28=densu(z,b28,tinf,tlb,xmm,alpha(3),tz,ptm(6),s,mn1,           &
     & zn1,tn1,tgn1)                                                    
!      net density at alt                                               
      d(3)=dnet(d(3),dm28,zhm28,xmm,28.) 
   17 continue 
      go to (20,50,20,25,90,35,40,45,25,48,46),  j 
   20 continue 
!                                                                       
!       **** he density ****                                            
!                                                                       
!       density variation factor at zlb                                 
      g4 = sw(21)*globe7(yrd,sec,glat,glong,stl,f107a,f107,ap,pd(1,1)) 
!      diffusive density at zlb                                         
      db04 = pdm(1,1)*exp(g4)*pd(1,1) 
!      diffusive density at alt                                         
      d(1)=densu(z,db04,tinf,tlb, 4.,alpha(1),t(2),ptm(6),s,mn1,zn1,    &
     & tn1,tgn1)                                                        
      dd=d(1) 
      if(z.gt.altl(1).or.sw(15).eq.0.) go to 24 
!      turbopause                                                       
      zh04=pdm(3,1) 
!      mixed density at zlb                                             
      b04=densu(zh04,db04,tinf,tlb,4.-xmm,alpha(1)-1.,                  &
     &  t(2),ptm(6),s,mn1,zn1,tn1,tgn1)                                 
!      mixed density at alt                                             
      dm04=densu(z,b04,tinf,tlb,xmm,0.,t(2),ptm(6),s,mn1,zn1,tn1,tgn1) 
      zhm04=zhm28 
!      net density at alt                                               
      d(1)=dnet(d(1),dm04,zhm04,xmm,4.) 
!      correction to specified mixing ratio at ground                   
      rl=alog(b28*pdm(2,1)/b04) 
      zc04=pdm(5,1)*pdl(1,2) 
      hc04=pdm(6,1)*pdl(2,2) 
!      net density corrected at alt                                     
      d(1)=d(1)*ccor(z,rl,hc04,zc04) 
   24 continue 
      if(mass.ne.48)   go to 90 
   25 continue 
!                                                                       
!      **** o density ****                                              
!                                                                       
!       density variation factor at zlb                                 
      g16= sw(21)*globe7(yrd,sec,glat,glong,stl,f107a,f107,ap,pd(1,2)) 
!      diffusive density at zlb                                         
      db16 =  pdm(1,2)*exp(g16)*pd(1,2) 
!       diffusive density at alt                                        
      d(2)=densu(z,db16,tinf,tlb, 16.,alpha(2),t(2),ptm(6),s,mn1,       &
     & zn1,tn1,tgn1)                                                    
      dd=d(2) 
      if(z.gt.altl(2).or.sw(15).eq.0.) go to 34 
!  corrected from pdm(3,1) to pdm(3,2)  12/2/85                         
!       turbopause                                                      
      zh16=pdm(3,2) 
!      mixed density at zlb                                             
      b16=densu(zh16,db16,tinf,tlb,16-xmm,alpha(2)-1.,                  &
     &  t(2),ptm(6),s,mn1,zn1,tn1,tgn1)                                 
!      mixed density at alt                                             
      dm16=densu(z,b16,tinf,tlb,xmm,0.,t(2),ptm(6),s,mn1,zn1,tn1,tgn1) 
      zhm16=zhm28 
!      net density at alt                                               
      d(2)=dnet(d(2),dm16,zhm16,xmm,16.) 
!   3/16/99 change form to match o2 departure from diff equil near 150  
!   km and add dependence on f10.7                                      
!      rl=alog(b28*pdm(2,2)*abs(pdl(17,2))/b16)                         
      rl=pdm(2,2)*pdl(17,2)*(1.+sw(1)*pdl(24,1)*(f107a-150.)) 
      hc16=pdm(6,2)*pdl(4,2) 
      zc16=pdm(5,2)*pdl(3,2) 
      hc216=pdm(6,2)*pdl(5,2) 
      d(2)=d(2)*ccor2(z,rl,hc16,zc16,hc216) 
!       chemistry correction                                            
      hcc16=pdm(8,2)*pdl(14,2) 
      zcc16=pdm(7,2)*pdl(13,2) 
      rc16=pdm(4,2)*pdl(15,2) 
!      net density corrected at alt                                     
      d(2)=d(2)*ccor(z,rc16,hcc16,zcc16) 
   34 continue 
      if(mass.ne.48.and.mass.ne.49) go to 90 
   35 continue 
!                                                                       
!       **** o2 density ****                                            
!                                                                       
!       density variation factor at zlb                                 
      g32= sw(21)*globe7(yrd,sec,glat,glong,stl,f107a,f107,ap,pd(1,5)) 
!      diffusive density at zlb                                         
      db32 = pdm(1,4)*exp(g32)*pd(1,5) 
!       diffusive density at alt                                        
      d(4)=densu(z,db32,tinf,tlb, 32.,alpha(4),t(2),ptm(6),s,mn1,       &
     & zn1,tn1,tgn1)                                                    
      if(mass.eq.49) then 
         dd=dd+2.*d(4) 
      else 
         dd=d(4) 
      endif 
      if(sw(15).eq.0.) go to 39 
      if(z.gt.altl(4)) go to 38 
!       turbopause                                                      
      zh32=pdm(3,4) 
!      mixed density at zlb                                             
      b32=densu(zh32,db32,tinf,tlb,32.-xmm,alpha(4)-1.,                 &
     &  t(2),ptm(6),s,mn1,zn1,tn1,tgn1)                                 
!      mixed density at alt                                             
      dm32=densu(z,b32,tinf,tlb,xmm,0.,t(2),ptm(6),s,mn1,zn1,tn1,tgn1) 
      zhm32=zhm28 
!      net density at alt                                               
      d(4)=dnet(d(4),dm32,zhm32,xmm,32.) 
!       correction to specified mixing ratio at ground                  
      rl=alog(b28*pdm(2,4)/b32) 
      hc32=pdm(6,4)*pdl(8,2) 
      zc32=pdm(5,4)*pdl(7,2) 
      d(4)=d(4)*ccor(z,rl,hc32,zc32) 
   38 continue 
!      correction for general departure from diffusive equilibrium above
      hcc32=pdm(8,4)*pdl(23,2) 
      hcc232=pdm(8,4)*pdl(23,1) 
      zcc32=pdm(7,4)*pdl(22,2) 
      rc32=pdm(4,4)*pdl(24,2)*(1.+sw(1)*pdl(24,1)*(f107a-150.)) 
!      net density corrected at alt                                     
      d(4)=d(4)*ccor2(z,rc32,hcc32,zcc32,hcc232) 
   39 continue 
      if(mass.ne.48)   go to 90 
   40 continue 
!                                                                       
!       **** ar density ****                                            
!                                                                       
!       density variation factor at zlb                                 
      g40= sw(21)*globe7(yrd,sec,glat,glong,stl,f107a,f107,ap,pd(1,6)) 
!      diffusive density at zlb                                         
      db40 = pdm(1,5)*exp(g40)*pd(1,6) 
!       diffusive density at alt                                        
      d(5)=densu(z,db40,tinf,tlb, 40.,alpha(5),t(2),ptm(6),s,mn1,       &
     & zn1,tn1,tgn1)                                                    
      dd=d(5) 
      if(z.gt.altl(5).or.sw(15).eq.0.) go to 44 
!       turbopause                                                      
      zh40=pdm(3,5) 
!      mixed density at zlb                                             
      b40=densu(zh40,db40,tinf,tlb,40.-xmm,alpha(5)-1.,                 &
     &  t(2),ptm(6),s,mn1,zn1,tn1,tgn1)                                 
!      mixed density at alt                                             
      dm40=densu(z,b40,tinf,tlb,xmm,0.,t(2),ptm(6),s,mn1,zn1,tn1,tgn1) 
      zhm40=zhm28 
!      net density at alt                                               
      d(5)=dnet(d(5),dm40,zhm40,xmm,40.) 
!       correction to specified mixing ratio at ground                  
      rl=alog(b28*pdm(2,5)/b40) 
      hc40=pdm(6,5)*pdl(10,2) 
      zc40=pdm(5,5)*pdl(9,2) 
!      net density corrected at alt                                     
      d(5)=d(5)*ccor(z,rl,hc40,zc40) 
   44 continue 
      if(mass.ne.48)   go to 90 
   45 continue 
!                                                                       
!        **** hydrogen density ****                                     
!                                                                       
!       density variation factor at zlb                                 
      g1 = sw(21)*globe7(yrd,sec,glat,glong,stl,f107a,f107,ap,pd(1,7)) 
!      diffusive density at zlb                                         
      db01 = pdm(1,6)*exp(g1)*pd(1,7) 
!       diffusive density at alt                                        
      d(7)=densu(z,db01,tinf,tlb,1.,alpha(7),t(2),ptm(6),s,mn1,         &
     & zn1,tn1,tgn1)                                                    
      dd=d(7) 
      if(z.gt.altl(7).or.sw(15).eq.0.) go to 47 
!       turbopause                                                      
      zh01=pdm(3,6) 
!      mixed density at zlb                                             
      b01=densu(zh01,db01,tinf,tlb,1.-xmm,alpha(7)-1.,                  &
     &  t(2),ptm(6),s,mn1,zn1,tn1,tgn1)                                 
!      mixed density at alt                                             
      dm01=densu(z,b01,tinf,tlb,xmm,0.,t(2),ptm(6),s,mn1,zn1,tn1,tgn1) 
      zhm01=zhm28 
!      net density at alt                                               
      d(7)=dnet(d(7),dm01,zhm01,xmm,1.) 
!       correction to specified mixing ratio at ground                  
      rl=alog(b28*pdm(2,6)*abs(pdl(18,2))/b01) 
      hc01=pdm(6,6)*pdl(12,2) 
      zc01=pdm(5,6)*pdl(11,2) 
      d(7)=d(7)*ccor(z,rl,hc01,zc01) 
!       chemistry correction                                            
      hcc01=pdm(8,6)*pdl(20,2) 
      zcc01=pdm(7,6)*pdl(19,2) 
      rc01=pdm(4,6)*pdl(21,2) 
!      net density corrected at alt                                     
      d(7)=d(7)*ccor(z,rc01,hcc01,zcc01) 
   47 continue 
      if(mass.ne.48)   go to 90 
   48 continue 
!                                                                       
!        **** atomic nitrogen density ****                              
!                                                                       
!       density variation factor at zlb                                 
      g14 = sw(21)*globe7(yrd,sec,glat,glong,stl,f107a,f107,ap,pd(1,8)) 
!      diffusive density at zlb                                         
      db14 = pdm(1,7)*exp(g14)*pd(1,8) 
!       diffusive density at alt                                        
      d(8)=densu(z,db14,tinf,tlb,14.,alpha(8),t(2),ptm(6),s,mn1,        &
     & zn1,tn1,tgn1)                                                    
      dd=d(8) 
      if(z.gt.altl(8).or.sw(15).eq.0.) go to 49 
!       turbopause                                                      
      zh14=pdm(3,7) 
!      mixed density at zlb                                             
      b14=densu(zh14,db14,tinf,tlb,14.-xmm,alpha(8)-1.,                 &
     &  t(2),ptm(6),s,mn1,zn1,tn1,tgn1)                                 
!      mixed density at alt                                             
      dm14=densu(z,b14,tinf,tlb,xmm,0.,t(2),ptm(6),s,mn1,zn1,tn1,tgn1) 
      zhm14=zhm28 
!      net density at alt                                               
      d(8)=dnet(d(8),dm14,zhm14,xmm,14.) 
!       correction to specified mixing ratio at ground                  
      rl=alog(b28*pdm(2,7)*abs(pdl(3,1))/b14) 
      hc14=pdm(6,7)*pdl(2,1) 
      zc14=pdm(5,7)*pdl(1,1) 
      d(8)=d(8)*ccor(z,rl,hc14,zc14) 
!       chemistry correction                                            
      hcc14=pdm(8,7)*pdl(5,1) 
      zcc14=pdm(7,7)*pdl(4,1) 
      rc14=pdm(4,7)*pdl(6,1) 
!      net density corrected at alt                                     
      d(8)=d(8)*ccor(z,rc14,hcc14,zcc14) 
   49 continue 
      if(mass.ne.48) go to 90 
   46 continue 
!                                                                       
!        **** anomalous oxygen density ****                             
!                                                                       
      g16h = sw(21)*globe7(yrd,sec,glat,glong,stl,f107a,f107,ap,pd(1,9)) 
      db16h = pdm(1,8)*exp(g16h)*pd(1,9) 
      tho=pdm(10,8)*pdl(7,1) 
      dd=densu(z,db16h,tho,tho,16.,alpha(9),t2,ptm(6),s,mn1,            &
     & zn1,tn1,tgn1)                                                    
      zsht=pdm(6,8) 
      zmho=pdm(5,8) 
      zsho=scalh(zmho,16.,tho) 
      d(9)=dd*exp(-zsht/zsho*(exp(-(z-zmho)/zsht)-1.)) 
      if(mass.ne.48) go to 90 
!                                                                       
!       total mass density                                              
!                                                                       
      d(6) = 1.66e-24*(4.*d(1)+16.*d(2)+28.*d(3)+32.*d(4)+40.*d(5)+     &
     &       d(7)+14.*d(8))                                             
      db48=1.66e-24*(4.*db04+16.*db16+28.*db28+32.*db32+40.*db40+db01+  &
     &        14.*db14)                                                 
      go to 90 
!       temperature at altitude                                         
   50 continue 
      z=abs(alt) 
      ddum  = densu(z,1., tinf,tlb,0.,0.,t(2),ptm(6),s,mn1,zn1,tn1,tgn1) 
   90 continue 
!       adjust densities from cgs to kgm                                
      if(imr.eq.1) then 
        do 95 i=1,9 
          d(i)=d(i)*1.e6 
   95   continue 
        d(6)=d(6)/1000. 
      endif 
      alast=alt 
      return 
  100 format(1x,'mass', i5, '  not valid') 
      end                                           
!-----------------------------------------------------------------------
      subroutine meters(meter) 
!      convert outputs to kg & meters if meter true                     
      logical meter 
      common/metsel/imr 
      save 
      imr=0 
      if(meter) imr=1 
      end                                           
!-----------------------------------------------------------------------
      function scalh(alt,xm,temp) 
!      calculate scale height (km)                                      
      common/parmb/gsurf,re 
      save 
      data rgas/831.4/ 
      g=gsurf/(1.+alt/re)**2 
      scalh=rgas*temp/(g*xm) 
      return 
      end                                           
!-----------------------------------------------------------------------
      function globe7(yrd,sec,lat,long,tloc,f107a,f107,ap,p) 
!       calculate g(l) function                                         
!       upper thermosphere parameters                                   
      real lat, long 
      dimension p(1),sv(25),ap(1) 
      common/ttest/tinf,gb,rout,t(15) 
      common/csw/sw(25),isw,swc(25) 
      common/lpoly/plg(9,4),ctloc,stloc,c2tloc,s2tloc,c3tloc,s3tloc,    &
     & iyr,day,df,dfa,apd,apdf,apt(4),xlong                             
      save 
      data dgtr/1.74533e-2/,dr/1.72142e-2/, xl/1000./,tll/1000./ 
      data sw9/1./,dayl/-1./,p14/-1000./,p18/-1000./,p32/-1000./ 
      data hr/.2618/,sr/7.2722e-5/,sv/25*1./,nsw/14/,p39/-1000./ 
!       3hr magnetic activity functions                                 
!      eq. a24d                                                         
      g0(a)=(a-4.+(p(26)-1.)*(a-4.+(exp(-abs(p(25))*(a-4.))-1.)/abs(p(25&
     &))))                                                              
!       eq. a24c                                                        
       sumex(ex)=1.+(1.-ex**19)/(1.-ex)*ex**(.5) 
!       eq. a24a                                                        
      sg0(ex)=(g0(ap(2))+(g0(ap(3))*ex+g0(ap(4))*ex*ex+g0(ap(5))*ex**3  &
     & +(g0(ap(6))*ex**4+g0(ap(7))*ex**12)*(1.-ex**8)/(1.-ex))          &
     & )/sumex(ex)                                                      
      if(isw.ne.64999) call tselec(sv) 
      do 10 j=1,14 
       t(j)=0 
   10 end do 
      if(sw(9).gt.0) sw9=1. 
      if(sw(9).lt.0) sw9=-1. 
      iyr = yrd/1000. 
      day = yrd - iyr*1000. 
      xlong=long 
!      eq. a22 (remainder of code)                                      
      if(xl.eq.lat)   go to 15 
!          calculate legendre polynomials                               
      c = sin(lat*dgtr) 
      s = cos(lat*dgtr) 
      c2 = c*c 
      c4 = c2*c2 
      s2 = s*s 
      plg(2,1) = c 
      plg(3,1) = 0.5*(3.*c2 -1.) 
      plg(4,1) = 0.5*(5.*c*c2-3.*c) 
      plg(5,1) = (35.*c4 - 30.*c2 + 3.)/8. 
      plg(6,1) = (63.*c2*c2*c - 70.*c2*c + 15.*c)/8. 
      plg(7,1) = (11.*c*plg(6,1) - 5.*plg(5,1))/6. 
!     plg(8,1) = (13.*c*plg(7,1) - 6.*plg(6,1))/7.                      
      plg(2,2) = s 
      plg(3,2) = 3.*c*s 
      plg(4,2) = 1.5*(5.*c2-1.)*s 
      plg(5,2) = 2.5*(7.*c2*c-3.*c)*s 
      plg(6,2) = 1.875*(21.*c4 - 14.*c2 +1.)*s 
      plg(7,2) = (11.*c*plg(6,2)-6.*plg(5,2))/5. 
!     plg(8,2) = (13.*c*plg(7,2)-7.*plg(6,2))/6.                        
!     plg(9,2) = (15.*c*plg(8,2)-8.*plg(7,2))/7.                        
      plg(3,3) = 3.*s2 
      plg(4,3) = 15.*s2*c 
      plg(5,3) = 7.5*(7.*c2 -1.)*s2 
      plg(6,3) = 3.*c*plg(5,3)-2.*plg(4,3) 
      plg(7,3)=(11.*c*plg(6,3)-7.*plg(5,3))/4. 
      plg(8,3)=(13.*c*plg(7,3)-8.*plg(6,3))/5. 
      plg(4,4) = 15.*s2*s 
      plg(5,4) = 105.*s2*s*c 
      plg(6,4)=(9.*c*plg(5,4)-7.*plg(4,4))/2. 
      plg(7,4)=(11.*c*plg(6,4)-8.*plg(5,4))/3. 
      xl=lat 
   15 continue 
      if(tll.eq.tloc)   go to 16 
      if(sw(7).eq.0.and.sw(8).eq.0.and.sw(14).eq.0) goto 16 
      stloc = sin(hr*tloc) 
      ctloc = cos(hr*tloc) 
      s2tloc = sin(2.*hr*tloc) 
      c2tloc = cos(2.*hr*tloc) 
      s3tloc = sin(3.*hr*tloc) 
      c3tloc = cos(3.*hr*tloc) 
      tll = tloc 
   16 continue 
      if(day.ne.dayl.or.p(14).ne.p14) cd14=cos(dr*(day-p(14))) 
      if(day.ne.dayl.or.p(18).ne.p18) cd18=cos(2.*dr*(day-p(18))) 
      if(day.ne.dayl.or.p(32).ne.p32) cd32=cos(dr*(day-p(32))) 
      if(day.ne.dayl.or.p(39).ne.p39) cd39=cos(2.*dr*(day-p(39))) 
      dayl = day 
      p14 = p(14) 
      p18 = p(18) 
      p32 = p(32) 
      p39 = p(39) 
!         f10.7 effect                                                  
      df = f107 - f107a 
      dfa=f107a-150. 
      t(1) =  p(20)*df*(1.+p(60)*dfa) + p(21)*df*df + p(22)*dfa         &
     & + p(30)*dfa**2                                                   
      f1 = 1. + (p(48)*dfa +p(20)*df+p(21)*df*df)*swc(1) 
      f2 = 1. + (p(50)*dfa+p(20)*df+p(21)*df*df)*swc(1) 
!        time independent                                               
      t(2) =                                                            &
     &  (p(2)*plg(3,1) + p(3)*plg(5,1)+p(23)*plg(7,1))                  &
     & +(p(15)*plg(3,1))*dfa*swc(1)                                     &
     & +p(27)*plg(2,1)                                                  
!        symmetrical annual                                             
      t(3) =                                                            &
     & (p(19) )*cd32                                                    
!        symmetrical semiannual                                         
      t(4) =                                                            &
     & (p(16)+p(17)*plg(3,1))*cd18                                      
!        asymmetrical annual                                            
      t(5) =  f1*                                                       &
     &  (p(10)*plg(2,1)+p(11)*plg(4,1))*cd14                            
!         asymmetrical semiannual                                       
      t(6) =    p(38)*plg(2,1)*cd39 
!        diurnal                                                        
      if(sw(7).eq.0) goto 200 
      t71 = (p(12)*plg(3,2))*cd14*swc(5) 
      t72 = (p(13)*plg(3,2))*cd14*swc(5) 
      t(7) = f2*                                                        &
     & ((p(4)*plg(2,2) + p(5)*plg(4,2) + p(28)*plg(6,2)                 &
     & + t71)*ctloc                                                     &
     & + (p(7)*plg(2,2) + p(8)*plg(4,2) +p(29)*plg(6,2)                 &
     & + t72)*stloc)                                                    
  200 continue 
!        semidiurnal                                                    
      if(sw(8).eq.0) goto 210 
      t81 = (p(24)*plg(4,3)+p(36)*plg(6,3))*cd14*swc(5) 
      t82 = (p(34)*plg(4,3)+p(37)*plg(6,3))*cd14*swc(5) 
      t(8) = f2*                                                        &
     & ((p(6)*plg(3,3) + p(42)*plg(5,3) + t81)*c2tloc                   &
     & +(p(9)*plg(3,3) + p(43)*plg(5,3) + t82)*s2tloc)                  
  210 continue 
!        terdiurnal                                                     
      if(sw(14).eq.0) goto 220 
      t(14) = f2*                                                       &
     & ((p(40)*plg(4,4)+(p(94)*plg(5,4)+p(47)*plg(7,4))*cd14*swc(5))*   &
     & s3tloc                                                           &
     & +(p(41)*plg(4,4)+(p(95)*plg(5,4)+p(49)*plg(7,4))*cd14*swc(5))*   &
     & c3tloc)                                                          
  220 continue 
!          magnetic activity based on daily ap                          
                                                                        
      if(sw9.eq.-1.) go to 30 
      apd=(ap(1)-4.) 
      p44=p(44) 
      p45=p(45) 
      if(p44.lt.0) p44=1.e-5 
      apdf = apd+(p45-1.)*(apd+(exp(-p44  *apd)-1.)/p44) 
      if(sw(9).eq.0) goto 40 
      t(9)=apdf*(p(33)+p(46)*plg(3,1)+p(35)*plg(5,1)+                   &
     & (p(101)*plg(2,1)+p(102)*plg(4,1)+p(103)*plg(6,1))*cd14*swc(5)+   &
     & (p(122)*plg(2,2)+p(123)*plg(4,2)+p(124)*plg(6,2))*swc(7)*        &
     & cos(hr*(tloc-p(125))))                                           
      go to 40 
   30 continue 
      if(p(52).eq.0) go to 40 
      exp1 = exp(-10800.*abs(p(52))/(1.+p(139)*(45.-abs(lat)))) 
      if(exp1.gt..99999) exp1=.99999 
      if(p(25).lt.1.e-4) p(25)=1.e-4 
      apt(1)=sg0(exp1) 
!      apt(2)=sg2(exp1)                                                 
!      apt(3)=sg0(exp2)                                                 
!      apt(4)=sg2(exp2)                                                 
      if(sw(9).eq.0) goto 40 
      t(9) = apt(1)*(p(51)+p(97)*plg(3,1)+p(55)*plg(5,1)+               &
     & (p(126)*plg(2,1)+p(127)*plg(4,1)+p(128)*plg(6,1))*cd14*swc(5)+   &
     & (p(129)*plg(2,2)+p(130)*plg(4,2)+p(131)*plg(6,2))*swc(7)*        &
     & cos(hr*(tloc-p(132))))                                           
   40 continue 
      if(sw(10).eq.0.or.long.le.-1000.) go to 49 
!        longitudinal                                                   
      if(sw(11).eq.0) goto 230 
      t(11)= (1.+p(81)*dfa*swc(1))*                                     &
     &((p(65)*plg(3,2)+p(66)*plg(5,2)+p(67)*plg(7,2)                    &
     & +p(104)*plg(2,2)+p(105)*plg(4,2)+p(106)*plg(6,2)                 &
     & +swc(5)*(p(110)*plg(2,2)+p(111)*plg(4,2)+p(112)*plg(6,2))*cd14)* &
     &     cos(dgtr*long)                                               &
     & +(p(91)*plg(3,2)+p(92)*plg(5,2)+p(93)*plg(7,2)                   &
     & +p(107)*plg(2,2)+p(108)*plg(4,2)+p(109)*plg(6,2)                 &
     & +swc(5)*(p(113)*plg(2,2)+p(114)*plg(4,2)+p(115)*plg(6,2))*cd14)* &
     &  sin(dgtr*long))                                                 
  230 continue 
!        ut and mixed ut,longitude                                      
      if(sw(12).eq.0) goto 240 
      t(12)=(1.+p(96)*plg(2,1))*(1.+p(82)*dfa*swc(1))*                  &
     &(1.+p(120)*plg(2,1)*swc(5)*cd14)*                                 &
     &((p(69)*plg(2,1)+p(70)*plg(4,1)+p(71)*plg(6,1))*                  &
     &     cos(sr*(sec-p(72))))                                         
      t(12)=t(12)+swc(11)*                                              &
     & (p(77)*plg(4,3)+p(78)*plg(6,3)+p(79)*plg(8,3))*                  &
     &     cos(sr*(sec-p(80))+2.*dgtr*long)*(1.+p(138)*dfa*swc(1))      
  240 continue 
!        ut,longitude magnetic activity                                 
      if(sw(13).eq.0) goto 48 
      if(sw9.eq.-1.) go to 45 
      t(13)= apdf*swc(11)*(1.+p(121)*plg(2,1))*                         &
     &((p( 61)*plg(3,2)+p( 62)*plg(5,2)+p( 63)*plg(7,2))*               &
     &     cos(dgtr*(long-p( 64))))                                     &
     & +apdf*swc(11)*swc(5)*                                            &
     & (p(116)*plg(2,2)+p(117)*plg(4,2)+p(118)*plg(6,2))*               &
     &     cd14*cos(dgtr*(long-p(119)))                                 &
     & + apdf*swc(12)*                                                  &
     & (p( 84)*plg(2,1)+p( 85)*plg(4,1)+p( 86)*plg(6,1))*               &
     &     cos(sr*(sec-p( 76)))                                         
      goto 48 
   45 continue 
      if(p(52).eq.0) goto 48 
      t(13)=apt(1)*swc(11)*(1.+p(133)*plg(2,1))*                        &
     &((p(53)*plg(3,2)+p(99)*plg(5,2)+p(68)*plg(7,2))*                  &
     &     cos(dgtr*(long-p(98))))                                      &
     & +apt(1)*swc(11)*swc(5)*                                          &
     & (p(134)*plg(2,2)+p(135)*plg(4,2)+p(136)*plg(6,2))*               &
     &     cd14*cos(dgtr*(long-p(137)))                                 &
     & +apt(1)*swc(12)*                                                 &
     & (p(56)*plg(2,1)+p(57)*plg(4,1)+p(58)*plg(6,1))*                  &
     &     cos(sr*(sec-p(59)))                                          
   48 continue 
!  parms not used: 83, 90,100,140-150                                   
   49 continue 
      tinf=p(31) 
      do 50 i = 1,nsw 
   50 tinf = tinf + abs(sw(i))*t(i) 
      globe7 = tinf 
      return 
      end                                           
!-----------------------------------------------------------------------
      subroutine tselec(sv) 
!        set switches                                                   
!        output in  common/csw/sw(25),isw,swc(25)                       
!        sw for main terms, swc for cross terms                         
!                                                                       
!        to turn on and off particular variations call tselec(sv),      
!        where sv is a 25 element array containing 0. for off, 1.       
!        for on, or 2. for main effects off but cross terms on          
!                                                                       
!        to get current values of sw: call tretrv(sw)                   
!                                                                       
      dimension sv(1),sav(25),svv(1) 
      common/csw/sw(25),isw,swc(25) 
      save 
      do 100 i = 1,25 
        sav(i)=sv(i) 
        sw(i)=amod(sv(i),2.) 
        if(abs(sv(i)).eq.1.or.abs(sv(i)).eq.2.) then 
          swc(i)=1. 
        else 
          swc(i)=0. 
        endif 
  100 end do 
      isw=64999 
      return 
      entry tretrv(svv) 
      do 200 i=1,25 
        svv(i)=sav(i) 
  200 end do 
      end                                           
!-----------------------------------------------------------------------
      function glob7s(p) 
!      version of globe for lower atmosphere 10/26/99                   
      real long 
      common/lpoly/plg(9,4),ctloc,stloc,c2tloc,s2tloc,c3tloc,s3tloc,    &
     & iyr,day,df,dfa,apd,apdf,apt(4),long                              
      common/csw/sw(25),isw,swc(25) 
      dimension p(1),t(14) 
      save 
      data dr/1.72142e-2/,dgtr/1.74533e-2/,pset/2./ 
      data dayl/-1./,p32,p18,p14,p39/4*-1000./ 
!       confirm parameter set                                           
      if(p(100).eq.0) p(100)=pset 
      if(p(100).ne.pset) then 
        write(6,900) pset,p(100) 
  900   format(1x,'wrong parameter set for glob7s',3f10.1) 
        stop 
      endif 
      do 10 j=1,14 
        t(j)=0. 
   10 end do 
      if(day.ne.dayl.or.p32.ne.p(32)) cd32=cos(dr*(day-p(32))) 
      if(day.ne.dayl.or.p18.ne.p(18)) cd18=cos(2.*dr*(day-p(18))) 
      if(day.ne.dayl.or.p14.ne.p(14)) cd14=cos(dr*(day-p(14))) 
      if(day.ne.dayl.or.p39.ne.p(39)) cd39=cos(2.*dr*(day-p(39))) 
      dayl=day 
      p32=p(32) 
      p18=p(18) 
      p14=p(14) 
      p39=p(39) 
!                                                                       
!       f10.7                                                           
      t(1)=p(22)*dfa 
!       time independent                                                
      t(2)=p(2)*plg(3,1)+p(3)*plg(5,1)+p(23)*plg(7,1)                   &
     &     +p(27)*plg(2,1)+p(15)*plg(4,1)+p(60)*plg(6,1)                
!       symmetrical annual                                              
      t(3)=(p(19)+p(48)*plg(3,1)+p(30)*plg(5,1))*cd32 
!       symmetrical semiannual                                          
      t(4)=(p(16)+p(17)*plg(3,1)+p(31)*plg(5,1))*cd18 
!       asymmetrical annual                                             
      t(5)=(p(10)*plg(2,1)+p(11)*plg(4,1)+p(21)*plg(6,1))*cd14 
!       asymmetrical semiannual                                         
      t(6)=(p(38)*plg(2,1))*cd39 
!        diurnal                                                        
      if(sw(7).eq.0) goto 200 
      t71 = p(12)*plg(3,2)*cd14*swc(5) 
      t72 = p(13)*plg(3,2)*cd14*swc(5) 
      t(7) =                                                            &
     & ((p(4)*plg(2,2) + p(5)*plg(4,2)                                  &
     & + t71)*ctloc                                                     &
     & + (p(7)*plg(2,2) + p(8)*plg(4,2)                                 &
     & + t72)*stloc)                                                    
  200 continue 
!        semidiurnal                                                    
      if(sw(8).eq.0) goto 210 
      t81 = (p(24)*plg(4,3)+p(36)*plg(6,3))*cd14*swc(5) 
      t82 = (p(34)*plg(4,3)+p(37)*plg(6,3))*cd14*swc(5) 
      t(8) =                                                            &
     & ((p(6)*plg(3,3) + p(42)*plg(5,3) + t81)*c2tloc                   &
     & +(p(9)*plg(3,3) + p(43)*plg(5,3) + t82)*s2tloc)                  
  210 continue 
!        terdiurnal                                                     
      if(sw(14).eq.0) goto 220 
      t(14) = p(40)*plg(4,4)*s3tloc                                     &
     & +p(41)*plg(4,4)*c3tloc                                           
  220 continue 
!       magnetic activity                                               
      if(sw(9).eq.0) goto 40 
      if(sw(9).eq.1)                                                    &
     & t(9)=apdf*(p(33)+p(46)*plg(3,1)*swc(2))                          
      if(sw(9).eq.-1)                                                   &
     & t(9)=(p(51)*apt(1)+p(97)*plg(3,1)*apt(1)*swc(2))                 
   40 continue 
      if(sw(10).eq.0.or.sw(11).eq.0.or.long.le.-1000.) go to 49 
!        longitudinal                                                   
      t(11)= (1.+plg(2,1)*(p(81)*swc(5)*cos(dr*(day-p(82)))             &
     &           +p(86)*swc(6)*cos(2.*dr*(day-p(87))))                  &
     &        +p(84)*swc(3)*cos(dr*(day-p(85)))                         &
     &           +p(88)*swc(4)*cos(2.*dr*(day-p(89))))                  &
     & *((p(65)*plg(3,2)+p(66)*plg(5,2)+p(67)*plg(7,2)                  &
     &   +p(75)*plg(2,2)+p(76)*plg(4,2)+p(77)*plg(6,2)                  &
     &    )*cos(dgtr*long)                                              &
     &  +(p(91)*plg(3,2)+p(92)*plg(5,2)+p(93)*plg(7,2)                  &
     &   +p(78)*plg(2,2)+p(79)*plg(4,2)+p(80)*plg(6,2)                  &
     &    )*sin(dgtr*long))                                             
   49 continue 
      tt=0. 
      do 50 i=1,14 
   50 tt=tt+abs(sw(i))*t(i) 
      glob7s=tt 
      return 
      end                                           
!--------------------------------------------------------------------   
      function densu(alt,dlb,tinf,tlb,xm,alpha,tz,zlb,s2,               &
     &  mn1,zn1,tn1,tgn1)                                               
!       calculate temperature and density profiles for msis models      
!       new lower thermo polynomial 10/30/89                            
      dimension zn1(mn1),tn1(mn1),tgn1(2),xs(5),ys(5),y2out(5) 
      common/parmb/gsurf,re 
      common/lsqv/mp,ii,jg,lt,qpb(50),ierr,ifun,n,j,dv(60) 
      save 
      data rgas/831.4/ 
      zeta(zz,zl)=(zz-zl)*(re+zl)/(re+zz) 
!cccccwrite(6,*) 'db',alt,dlb,tinf,tlb,xm,alpha,zlb,s2,mn1,zn1,tn1      
      densu=1. 
!        joining altitude of bates and spline                           
      za=zn1(1) 
      z=amax1(alt,za) 
!      geopotential altitude difference from zlb                        
      zg2=zeta(z,zlb) 
!      bates temperature                                                
      tt=tinf-(tinf-tlb)*exp(-s2*zg2) 
      ta=tt 
      tz=tt 
      densu=tz 
      if(alt.ge.za) go to 10 
!                                                                       
!       calculate temperature below za                                  
!      temperature gradient at za from bates profile                    
      dta=(tinf-ta)*s2*((re+zlb)/(re+za))**2 
      tgn1(1)=dta 
      tn1(1)=ta 
      z=amax1(alt,zn1(mn1)) 
      mn=mn1 
      z1=zn1(1) 
      z2=zn1(mn) 
      t1=tn1(1) 
      t2=tn1(mn) 
!      geopotental difference from z1                                   
      zg=zeta(z,z1) 
      zgdif=zeta(z2,z1) 
!       set up spline nodes                                             
      do 20 k=1,mn 
        xs(k)=zeta(zn1(k),z1)/zgdif 
        ys(k)=1./tn1(k) 
   20 end do 
!        end node derivatives                                           
      yd1=-tgn1(1)/(t1*t1)*zgdif 
      yd2=-tgn1(2)/(t2*t2)*zgdif*((re+z2)/(re+z1))**2 
!       calculate spline coefficients                                   
      call spline(xs,ys,mn,yd1,yd2,y2out) 
      x=zg/zgdif 
      call splint(xs,ys,y2out,mn,x,y) 
!       temperature at altitude                                         
      tz=1./y 
      densu=tz 
   10 if(xm.eq.0.) go to 50 
!                                                                       
!      calculate density above za                                       
      glb=gsurf/(1.+zlb/re)**2 
      gamma=xm*glb/(s2*rgas*tinf) 
      expl=exp(-s2*gamma*zg2) 
      if(expl.gt.50.or.tt.le.0.) then 
        expl=50. 
      endif 
!       density at altitude                                             
      densa=dlb*(tlb/tt)**(1.+alpha+gamma)*expl 
      densu=densa 
      if(alt.ge.za) go to 50 
!                                                                       
!      calculate density below za                                       
      glb=gsurf/(1.+z1/re)**2 
      gamm=xm*glb*zgdif/rgas 
!       integrate spline temperatures                                   
      call splini(xs,ys,y2out,mn,x,yi) 
      expl=gamm*yi 
      if(expl.gt.50..or.tz.le.0.) then 
        expl=50. 
      endif 
!       density at altitude                                             
      densu=densu*(t1/tz)**(1.+alpha)*exp(-expl) 
   50 continue 
      return 
      end                                           
!--------------------------------------------------------------------   
      function densm(alt,d0,xm,tz,mn3,zn3,tn3,tgn3,mn2,zn2,tn2,tgn2) 
!       calculate temperature and density profiles for lower atmos.     
      dimension zn3(mn3),tn3(mn3),tgn3(2),xs(10),ys(10),y2out(10) 
      dimension zn2(mn2),tn2(mn2),tgn2(2) 
      common/parmb/gsurf,re 
      common/fit/taf 
      common/lsqv/mp,ii,jg,lt,qpb(50),ierr,ifun,n,j,dv(60) 
      save 
      data rgas/831.4/ 
      zeta(zz,zl)=(zz-zl)*(re+zl)/(re+zz) 
      densm=d0 
      if(alt.gt.zn2(1)) goto 50 
!      stratosphere/mesosphere temperature                              
      z=amax1(alt,zn2(mn2)) 
      mn=mn2 
      z1=zn2(1) 
      z2=zn2(mn) 
      t1=tn2(1) 
      t2=tn2(mn) 
      zg=zeta(z,z1) 
      zgdif=zeta(z2,z1) 
!       set up spline nodes                                             
      do 210 k=1,mn 
        xs(k)=zeta(zn2(k),z1)/zgdif 
        ys(k)=1./tn2(k) 
  210 end do 
      yd1=-tgn2(1)/(t1*t1)*zgdif 
      yd2=-tgn2(2)/(t2*t2)*zgdif*((re+z2)/(re+z1))**2 
!       calculate spline coefficients                                   
      call spline(xs,ys,mn,yd1,yd2,y2out) 
      x=zg/zgdif 
      call splint(xs,ys,y2out,mn,x,y) 
!       temperature at altitude                                         
      tz=1./y 
      if(xm.eq.0.) go to 20 
!                                                                       
!      calculate stratosphere/mesosphere density                        
      glb=gsurf/(1.+z1/re)**2 
      gamm=xm*glb*zgdif/rgas 
!       integrate temperature profile                                   
      call splini(xs,ys,y2out,mn,x,yi) 
      expl=gamm*yi 
      if(expl.gt.50.) expl=50. 
!       density at altitude                                             
      densm=densm*(t1/tz)*exp(-expl) 
   20 continue 
      if(alt.gt.zn3(1)) goto 50 
!                                                                       
!      troposphere/stratosphere temperature                             
      z=alt 
      mn=mn3 
      z1=zn3(1) 
      z2=zn3(mn) 
      t1=tn3(1) 
      t2=tn3(mn) 
      zg=zeta(z,z1) 
      zgdif=zeta(z2,z1) 
!       set up spline nodes                                             
      do 220 k=1,mn 
        xs(k)=zeta(zn3(k),z1)/zgdif 
        ys(k)=1./tn3(k) 
  220 end do 
      yd1=-tgn3(1)/(t1*t1)*zgdif 
      yd2=-tgn3(2)/(t2*t2)*zgdif*((re+z2)/(re+z1))**2 
!       calculate spline coefficients                                   
      call spline(xs,ys,mn,yd1,yd2,y2out) 
      x=zg/zgdif 
      call splint(xs,ys,y2out,mn,x,y) 
!       temperature at altitude                                         
      tz=1./y 
      if(xm.eq.0.) go to 30 
!                                                                       
!      calculate tropospheric/stratosphere density                      
!                                                                       
      glb=gsurf/(1.+z1/re)**2 
      gamm=xm*glb*zgdif/rgas 
!        integrate temperature profile                                  
      call splini(xs,ys,y2out,mn,x,yi) 
      expl=gamm*yi 
      if(expl.gt.50.) expl=50. 
!        density at altitude                                            
      densm=densm*(t1/tz)*exp(-expl) 
   30 continue 
   50 continue 
      if(xm.eq.0) densm=tz 
      return 
      end                                           
!-----------------------------------------------------------------------
      subroutine spline(x,y,n,yp1,ypn,y2) 
!        calculate 2nd derivatives of cubic spline interp function      
!        adapted from numerical recipes by press et al                  
!        x,y: arrays of tabulated function in ascending order by x      
!        n: size of arrays x,y                                          
!        yp1,ypn: specified derivatives at x(1) and x(n); values        
!                 >= 1e30 signal signal second derivative zero          
!        y2: output array of second derivatives                         
      parameter (nmax=100) 
      dimension x(n),y(n),y2(n),u(nmax) 
      save 
      if(yp1.gt..99e30) then 
        y2(1)=0 
        u(1)=0 
      else 
        y2(1)=-.5 
        u(1)=(3./(x(2)-x(1)))*((y(2)-y(1))/(x(2)-x(1))-yp1) 
      endif 
      do 11 i=2,n-1 
        sig=(x(i)-x(i-1))/(x(i+1)-x(i-1)) 
        p=sig*y2(i-1)+2. 
        y2(i)=(sig-1.)/p 
        u(i)=(6.*((y(i+1)-y(i))/(x(i+1)-x(i))-(y(i)-y(i-1))             &
     &    /(x(i)-x(i-1)))/(x(i+1)-x(i-1))-sig*u(i-1))/p                 
   11 end do 
      if(ypn.gt..99e30) then 
        qn=0 
        un=0 
      else 
        qn=.5 
        un=(3./(x(n)-x(n-1)))*(ypn-(y(n)-y(n-1))/(x(n)-x(n-1))) 
      endif 
      y2(n)=(un-qn*u(n-1))/(qn*y2(n-1)+1.) 
      do 12 k=n-1,1,-1 
        y2(k)=y2(k)*y2(k+1)+u(k) 
   12 end do 
      return 
      end                                           
!-----------------------------------------------------------------------
      subroutine splint(xa,ya,y2a,n,x,y) 
!        calculate cubic spline interp value                            
!        adapted from numerical recipes by press et al.                 
!        xa,ya: arrays of tabulated function in ascending order by x    
!        y2a: array of second derivatives                               
!        n: size of arrays xa,ya,y2a                                    
!        x: abscissa for interpolation                                  
!        y: output value                                                
      dimension xa(n),ya(n),y2a(n) 
      save 
      klo=1 
      khi=n 
    1 continue 
      if(khi-klo.gt.1) then 
        k=(khi+klo)/2 
        if(xa(k).gt.x) then 
          khi=k 
        else 
          klo=k 
        endif 
        goto 1 
      endif 
      h=xa(khi)-xa(klo) 
      if(h.eq.0) write(6,*) 'bad xa input to splint' 
      a=(xa(khi)-x)/h 
      b=(x-xa(klo))/h 
      y=a*ya(klo)+b*ya(khi)+                                            &
     &  ((a*a*a-a)*y2a(klo)+(b*b*b-b)*y2a(khi))*h*h/6.                  
      return 
      end                                           
!-----------------------------------------------------------------------
      subroutine splini(xa,ya,y2a,n,x,yi) 
!       integrate cubic spline function from xa(1) to x                 
!        xa,ya: arrays of tabulated function in ascending order by x    
!        y2a: array of second derivatives                               
!        n: size of arrays xa,ya,y2a                                    
!        x: abscissa endpoint for integration                           
!        y: output value                                                
      dimension xa(n),ya(n),y2a(n) 
      save 
      yi=0 
      klo=1 
      khi=2 
    1 continue 
      if(x.gt.xa(klo).and.khi.le.n) then 
        xx=x 
        if(khi.lt.n) xx=amin1(x,xa(khi)) 
        h=xa(khi)-xa(klo) 
        a=(xa(khi)-xx)/h 
        b=(xx-xa(klo))/h 
        a2=a*a 
        b2=b*b 
        yi=yi+((1.-a2)*ya(klo)/2.+b2*ya(khi)/2.+                        &
     &     ((-(1.+a2*a2)/4.+a2/2.)*y2a(klo)+                            &
     &     (b2*b2/4.-b2/2.)*y2a(khi))*h*h/6.)*h                         
        klo=klo+1 
        khi=khi+1 
        goto 1 
      endif 
      return 
      end                                           
!-----------------------------------------------------------------------
      function dnet(dd,dm,zhm,xmm,xm) 
!       turbopause correction for msis models                           
!         root mean density                                             
!       8/20/80                                                         
!          dd - diffusive density                                       
!          dm - full mixed density                                      
!          zhm - transition scale length                                
!          xmm - full mixed molecular weight                            
!          xm  - species molecular weight                               
!          dnet - combined density                                      
      save 
      a=zhm/(xmm-xm) 
      if(dm.gt.0.and.dd.gt.0) goto 5 
        write(6,*) 'dnet log error',dm,dd,xm 
        if(dd.eq.0.and.dm.eq.0) dd=1. 
        if(dm.eq.0) goto 10 
        if(dd.eq.0) goto 20 
    5 continue 
      ylog=a*alog(dm/dd) 
      if(ylog.lt.-10.) go to 10 
      if(ylog.gt.10.)  go to 20 
        dnet=dd*(1.+exp(ylog))**(1/a) 
        go to 50 
   10 continue 
        dnet=dd 
        go to 50 
   20 continue 
        dnet=dm 
        go to 50 
   50 continue 
      return 
      end                                           
!-----------------------------------------------------------------------
      function  ccor(alt, r,h1,zh) 
!        chemistry/dissociation correction for msis models              
!        alt - altitude                                                 
!        r - target ratio                                               
!        h1 - transition scale length                                   
!        zh - altitude of 1/2 r                                         
      save 
      e=(alt-zh)/h1 
      if(e.gt.70.) go to 20 
      if(e.lt.-70.) go to 10 
        ex=exp(e) 
        ccor=r/(1.+ex) 
        go to 50 
   10   ccor=r 
        go to 50 
   20   ccor=0. 
        go to 50 
   50 continue 
      ccor=exp(ccor) 
       return 
      end                                           
!-----------------------------------------------------------------------
      function  ccor2(alt, r,h1,zh,h2) 
!       o&o2 chemistry/dissociation correction for msis models          
      e1=(alt-zh)/h1 
      e2=(alt-zh)/h2 
      if(e1.gt.70. .or. e2.gt.70.) go to 20 
      if(e1.lt.-70. .and. e2.lt.-70) go to 10 
        ex1=exp(e1) 
        ex2=exp(e2) 
        ccor2=r/(1.+.5*(ex1+ex2)) 
        go to 50 
   10   ccor2=r 
        go to 50 
   20   ccor2=0. 
        go to 50 
   50 continue 
      ccor2=exp(ccor2) 
       return 
      end                                           
!-----------------------------------------------------------------------
      block data gtd7bk 
!          msise-00 01-feb-02                                           
      common/parm7/pt1(50),pt2(50),pt3(50),pa1(50),pa2(50),pa3(50),     &
     & pb1(50),pb2(50),pb3(50),pc1(50),pc2(50),pc3(50),                 &
     & pd1(50),pd2(50),pd3(50),pe1(50),pe2(50),pe3(50),                 &
     & pf1(50),pf2(50),pf3(50),pg1(50),pg2(50),pg3(50),                 &
     & ph1(50),ph2(50),ph3(50),pi1(50),pi2(50),pi3(50),                 &
     & pj1(50),pj2(50),pj3(50),pk1(50),pl1(50),pl2(50),                 &
     & pm1(50),pm2(50),pn1(50),pn2(50),po1(50),po2(50),                 &
     & pp1(50),pp2(50),pq1(50),pq2(50),pr1(50),pr2(50),                 &
     & ps1(50),ps2(50),pu1(50),pu2(50),pv1(50),pv2(50),                 &
     & pw1(50),pw2(50),px1(50),px2(50),py1(50),py2(50),                 &
     & pz1(50),pz2(50),paa1(50),paa2(50)                                
      common/lower7/ptm(10),pdm(10,8) 
      common/mavg7/pavgm(10) 
      common/datim7/isdate(3),istime(2),name(2) 
      common/metsel/imr 
      data imr/0/ 
!
!nm101910:      data isdate/'01-f','eb-0','2   '/,istime/'15:4','9:27'/ 
      character(len=4):: isdate=(/'01-f','eb-0','2   '/)
      character(len=4):: istime=(/'15:4','9:27'/) 
!nm101910:      data name/'msis','e-00'/ 
      character(len=4):: name=(/'msis','e-00'/) 
!
!         temperature                                                   
      data pt1/                                                         &
     &  9.86573e-01, 1.62228e-02, 1.55270e-02,-1.04323e-01,-3.75801e-03,&
     & -1.18538e-03,-1.24043e-01, 4.56820e-03, 8.76018e-03,-1.36235e-01,&
     & -3.52427e-02, 8.84181e-03,-5.92127e-03,-8.61650e+00, 0.00000e+00,&
     &  1.28492e-02, 0.00000e+00, 1.30096e+02, 1.04567e-02, 1.65686e-03,&
     & -5.53887e-06, 2.97810e-03, 0.00000e+00, 5.13122e-03, 8.66784e-02,&
     &  1.58727e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00,-7.27026e-06,&
     &  0.00000e+00, 6.74494e+00, 4.93933e-03, 2.21656e-03, 2.50802e-03,&
     &  0.00000e+00, 0.00000e+00,-2.08841e-02,-1.79873e+00, 1.45103e-03,&
     &  2.81769e-04,-1.44703e-03,-5.16394e-05, 8.47001e-02, 1.70147e-01,&
     &  5.72562e-03, 5.07493e-05, 4.36148e-03, 1.17863e-04, 4.74364e-03/
      data pt2/                                                         &
     &  6.61278e-03, 4.34292e-05, 1.44373e-03, 2.41470e-05, 2.84426e-03,&
     &  8.56560e-04, 2.04028e-03, 0.00000e+00,-3.15994e+03,-2.46423e-03,&
     &  1.13843e-03, 4.20512e-04, 0.00000e+00,-9.77214e+01, 6.77794e-03,&
     &  5.27499e-03, 1.14936e-03, 0.00000e+00,-6.61311e-03,-1.84255e-02,&
     & -1.96259e-02, 2.98618e+04, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  6.44574e+02, 8.84668e-04, 5.05066e-04, 0.00000e+00, 4.02881e+03,&
     & -1.89503e-03, 0.00000e+00, 0.00000e+00, 8.21407e-04, 2.06780e-03,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     & -1.20410e-02,-3.63963e-03, 9.92070e-05,-1.15284e-04,-6.33059e-05,&
     & -6.05545e-01, 8.34218e-03,-9.13036e+01, 3.71042e-04, 0.00000e+00/
      data pt3/                                                         &
     &  4.19000e-04, 2.70928e-03, 3.31507e-03,-4.44508e-03,-4.96334e-03,&
     & -1.60449e-03, 3.95119e-03, 2.48924e-03, 5.09815e-04, 4.05302e-03,&
     &  2.24076e-03, 0.00000e+00, 6.84256e-03, 4.66354e-04, 0.00000e+00,&
     & -3.68328e-04, 0.00000e+00, 0.00000e+00,-1.46870e+02, 0.00000e+00,&
     &  0.00000e+00, 1.09501e-03, 4.65156e-04, 5.62583e-04, 3.21596e+00,&
     &  6.43168e-04, 3.14860e-03, 3.40738e-03, 1.78481e-03, 9.62532e-04,&
     &  5.58171e-04, 3.43731e+00,-2.33195e-01, 5.10289e-04, 0.00000e+00,&
     &  0.00000e+00,-9.25347e+04, 0.00000e+00,-1.99639e-03, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
!         he density                                                    
      data pa1/                                                         &
     &  1.09979e+00,-4.88060e-02,-1.97501e-01,-9.10280e-02,-6.96558e-03,&
     &  2.42136e-02, 3.91333e-01,-7.20068e-03,-3.22718e-02, 1.41508e+00,&
     &  1.68194e-01, 1.85282e-02, 1.09384e-01,-7.24282e+00, 0.00000e+00,&
     &  2.96377e-01,-4.97210e-02, 1.04114e+02,-8.61108e-02,-7.29177e-04,&
     &  1.48998e-06, 1.08629e-03, 0.00000e+00, 0.00000e+00, 8.31090e-02,&
     &  1.12818e-01,-5.75005e-02,-1.29919e-02,-1.78849e-02,-2.86343e-06,&
     &  0.00000e+00,-1.51187e+02,-6.65902e-03, 0.00000e+00,-2.02069e-03,&
     &  0.00000e+00, 0.00000e+00, 4.32264e-02,-2.80444e+01,-3.26789e-03,&
     &  2.47461e-03, 0.00000e+00, 0.00000e+00, 9.82100e-02, 1.22714e-01,&
     & -3.96450e-02, 0.00000e+00,-2.76489e-03, 0.00000e+00, 1.87723e-03/
      data pa2/                                                         &
     & -8.09813e-03, 4.34428e-05,-7.70932e-03, 0.00000e+00,-2.28894e-03,&
     & -5.69070e-03,-5.22193e-03, 6.00692e-03,-7.80434e+03,-3.48336e-03,&
     & -6.38362e-03,-1.82190e-03, 0.00000e+00,-7.58976e+01,-2.17875e-02,&
     & -1.72524e-02,-9.06287e-03, 0.00000e+00, 2.44725e-02, 8.66040e-02,&
     &  1.05712e-01, 3.02543e+04, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     & -6.01364e+03,-5.64668e-03,-2.54157e-03, 0.00000e+00, 3.15611e+02,&
     & -5.69158e-03, 0.00000e+00, 0.00000e+00,-4.47216e-03,-4.49523e-03,&
     &  4.64428e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  4.51236e-02, 2.46520e-02, 6.17794e-03, 0.00000e+00, 0.00000e+00,&
     & -3.62944e-01,-4.80022e-02,-7.57230e+01,-1.99656e-03, 0.00000e+00/
      data pa3/                                                         &
     & -5.18780e-03,-1.73990e-02,-9.03485e-03, 7.48465e-03, 1.53267e-02,&
     &  1.06296e-02, 1.18655e-02, 2.55569e-03, 1.69020e-03, 3.51936e-02,&
     & -1.81242e-02, 0.00000e+00,-1.00529e-01,-5.10574e-03, 0.00000e+00,&
     &  2.10228e-03, 0.00000e+00, 0.00000e+00,-1.73255e+02, 5.07833e-01,&
     & -2.41408e-01, 8.75414e-03, 2.77527e-03,-8.90353e-05,-5.25148e+00,&
     & -5.83899e-03,-2.09122e-02,-9.63530e-03, 9.77164e-03, 4.07051e-03,&
     &  2.53555e-04,-5.52875e+00,-3.55993e-01,-2.49231e-03, 0.00000e+00,&
     &  0.00000e+00, 2.86026e+01, 0.00000e+00, 3.42722e-04, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
!         o density                                                     
      data pb1/                                                         &
     &  1.02315e+00,-1.59710e-01,-1.06630e-01,-1.77074e-02,-4.42726e-03,&
     &  3.44803e-02, 4.45613e-02,-3.33751e-02,-5.73598e-02, 3.50360e-01,&
     &  6.33053e-02, 2.16221e-02, 5.42577e-02,-5.74193e+00, 0.00000e+00,&
     &  1.90891e-01,-1.39194e-02, 1.01102e+02, 8.16363e-02, 1.33717e-04,&
     &  6.54403e-06, 3.10295e-03, 0.00000e+00, 0.00000e+00, 5.38205e-02,&
     &  1.23910e-01,-1.39831e-02, 0.00000e+00, 0.00000e+00,-3.95915e-06,&
     &  0.00000e+00,-7.14651e-01,-5.01027e-03, 0.00000e+00,-3.24756e-03,&
     &  0.00000e+00, 0.00000e+00, 4.42173e-02,-1.31598e+01,-3.15626e-03,&
     &  1.24574e-03,-1.47626e-03,-1.55461e-03, 6.40682e-02, 1.34898e-01,&
     & -2.42415e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00, 6.13666e-04/
      data pb2/                                                         &
     & -5.40373e-03, 2.61635e-05,-3.33012e-03, 0.00000e+00,-3.08101e-03,&
     & -2.42679e-03,-3.36086e-03, 0.00000e+00,-1.18979e+03,-5.04738e-02,&
     & -2.61547e-03,-1.03132e-03, 1.91583e-04,-8.38132e+01,-1.40517e-02,&
     & -1.14167e-02,-4.08012e-03, 1.73522e-04,-1.39644e-02,-6.64128e-02,&
     & -6.85152e-02,-1.34414e+04, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  6.07916e+02,-4.12220e-03,-2.20996e-03, 0.00000e+00, 1.70277e+03,&
     & -4.63015e-03, 0.00000e+00, 0.00000e+00,-2.25360e-03,-2.96204e-03,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  3.92786e-02, 1.31186e-02,-1.78086e-03, 0.00000e+00, 0.00000e+00,&
     & -3.90083e-01,-2.84741e-02,-7.78400e+01,-1.02601e-03, 0.00000e+00/
      data pb3/                                                         &
     & -7.26485e-04,-5.42181e-03,-5.59305e-03, 1.22825e-02, 1.23868e-02,&
     &  6.68835e-03,-1.03303e-02,-9.51903e-03, 2.70021e-04,-2.57084e-02,&
     & -1.32430e-02, 0.00000e+00,-3.81000e-02,-3.16810e-03, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-9.05762e-04,-2.14590e-03,-1.17824e-03, 3.66732e+00,&
     & -3.79729e-04,-6.13966e-03,-5.09082e-03,-1.96332e-03,-3.08280e-03,&
     & -9.75222e-04, 4.03315e+00,-2.52710e-01, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
!         n2 density                                                    
      data pc1/                                                         &
     &  1.16112e+00, 0.00000e+00, 0.00000e+00, 3.33725e-02, 0.00000e+00,&
     &  3.48637e-02,-5.44368e-03, 0.00000e+00,-6.73940e-02, 1.74754e-01,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 1.74712e+02, 0.00000e+00,&
     &  1.26733e-01, 0.00000e+00, 1.03154e+02, 5.52075e-02, 0.00000e+00,&
     &  0.00000e+00, 8.13525e-04, 0.00000e+00, 0.00000e+00, 8.66784e-02,&
     &  1.58727e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-2.50482e+01, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-2.48894e-03,&
     &  6.16053e-04,-5.79716e-04, 2.95482e-03, 8.47001e-02, 1.70147e-01,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pc2/                                                         &
     &  0.00000e+00, 2.47425e-05, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pc3/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
!         tlb                                                           
      data pd1/                                                         &
     &  9.44846e-01, 0.00000e+00, 0.00000e+00,-3.08617e-02, 0.00000e+00,&
     & -2.44019e-02, 6.48607e-03, 0.00000e+00, 3.08181e-02, 4.59392e-02,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 1.74712e+02, 0.00000e+00,&
     &  2.13260e-02, 0.00000e+00,-3.56958e+02, 0.00000e+00, 1.82278e-04,&
     &  0.00000e+00, 3.07472e-04, 0.00000e+00, 0.00000e+00, 8.66784e-02,&
     &  1.58727e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 3.83054e-03, 0.00000e+00, 0.00000e+00,&
     & -1.93065e-03,-1.45090e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-1.23493e-03, 1.36736e-03, 8.47001e-02, 1.70147e-01,&
     &  3.71469e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pd2/                                                         &
     &  5.10250e-03, 2.47425e-05, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 3.68756e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pd3/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
!         o2 density                                                    
      data pe1/                                                         &
     &  1.35580e+00, 1.44816e-01, 0.00000e+00, 6.07767e-02, 0.00000e+00,&
     &  2.94777e-02, 7.46900e-02, 0.00000e+00,-9.23822e-02, 8.57342e-02,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 2.38636e+01, 0.00000e+00,&
     &  7.71653e-02, 0.00000e+00, 8.18751e+01, 1.87736e-02, 0.00000e+00,&
     &  0.00000e+00, 1.49667e-02, 0.00000e+00, 0.00000e+00, 8.66784e-02,&
     &  1.58727e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-3.67874e+02, 5.48158e-03, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 8.47001e-02, 1.70147e-01,&
     &  1.22631e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pe2/                                                         &
     &  8.17187e-03, 3.71617e-05, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-2.10826e-03,&
     & -3.13640e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     & -7.35742e-02,-5.00266e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 1.94965e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pe3/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
!         ar density                                                    
      data pf1/                                                         &
     &  1.04761e+00, 2.00165e-01, 2.37697e-01, 3.68552e-02, 0.00000e+00,&
     &  3.57202e-02,-2.14075e-01, 0.00000e+00,-1.08018e-01,-3.73981e-01,&
     &  0.00000e+00, 3.10022e-02,-1.16305e-03,-2.07596e+01, 0.00000e+00,&
     &  8.64502e-02, 0.00000e+00, 9.74908e+01, 5.16707e-02, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 8.66784e-02,&
     &  1.58727e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 3.46193e+02, 1.34297e-02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-3.48509e-03,&
     & -1.54689e-04, 0.00000e+00, 0.00000e+00, 8.47001e-02, 1.70147e-01,&
     &  1.47753e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pf2/                                                         &
     &  1.89320e-02, 3.68181e-05, 1.32570e-02, 0.00000e+00, 0.00000e+00,&
     &  3.59719e-03, 7.44328e-03,-1.00023e-03,-6.50528e+03, 0.00000e+00,&
     &  1.03485e-02,-1.00983e-03,-4.06916e-03,-6.60864e+01,-1.71533e-02,&
     &  1.10605e-02, 1.20300e-02,-5.20034e-03, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     & -2.62769e+03, 7.13755e-03, 4.17999e-03, 0.00000e+00, 1.25910e+04,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00,-2.23595e-03, 4.60217e-03,&
     &  5.71794e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     & -3.18353e-02,-2.35526e-02,-1.36189e-02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 2.03522e-02,-6.67837e+01,-1.09724e-03, 0.00000e+00/
      data pf3/                                                         &
     & -1.38821e-02, 1.60468e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 1.51574e-02,&
     & -5.44470e-04, 0.00000e+00, 7.28224e-02, 6.59413e-02, 0.00000e+00,&
     & -5.15692e-03, 0.00000e+00, 0.00000e+00,-3.70367e+03, 0.00000e+00,&
     &  0.00000e+00, 1.36131e-02, 5.38153e-03, 0.00000e+00, 4.76285e+00,&
     & -1.75677e-02, 2.26301e-02, 0.00000e+00, 1.76631e-02, 4.77162e-03,&
     &  0.00000e+00, 5.39354e+00, 0.00000e+00,-7.51710e-03, 0.00000e+00,&
     &  0.00000e+00,-8.82736e+01, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
!          h density                                                    
      data pg1/                                                         &
     &  1.26376e+00,-2.14304e-01,-1.49984e-01, 2.30404e-01, 2.98237e-02,&
     &  2.68673e-02, 2.96228e-01, 2.21900e-02,-2.07655e-02, 4.52506e-01,&
     &  1.20105e-01, 3.24420e-02, 4.24816e-02,-9.14313e+00, 0.00000e+00,&
     &  2.47178e-02,-2.88229e-02, 8.12805e+01, 5.10380e-02,-5.80611e-03,&
     &  2.51236e-05,-1.24083e-02, 0.00000e+00, 0.00000e+00, 8.66784e-02,&
     &  1.58727e-01,-3.48190e-02, 0.00000e+00, 0.00000e+00, 2.89885e-05,&
     &  0.00000e+00, 1.53595e+02,-1.68604e-02, 0.00000e+00, 1.01015e-02,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.84552e-04,&
     & -1.22181e-03, 0.00000e+00, 0.00000e+00, 8.47001e-02, 1.70147e-01,&
     & -1.04927e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00,-5.91313e-03/
      data pg2/                                                         &
     & -2.30501e-02, 3.14758e-05, 0.00000e+00, 0.00000e+00, 1.26956e-02,&
     &  8.35489e-03, 3.10513e-04, 0.00000e+00, 3.42119e+03,-2.45017e-03,&
     & -4.27154e-04, 5.45152e-04, 1.89896e-03, 2.89121e+01,-6.49973e-03,&
     & -1.93855e-02,-1.48492e-02, 0.00000e+00,-5.10576e-02, 7.87306e-02,&
     &  9.51981e-02,-1.49422e+04, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  2.65503e+02, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 6.37110e-03, 3.24789e-04,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  6.14274e-02, 1.00376e-02,-8.41083e-04, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-1.27099e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pg3/                                                         &
     & -3.94077e-03,-1.28601e-02,-7.97616e-03, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-6.71465e-03,-1.69799e-03, 1.93772e-03, 3.81140e+00,&
     & -7.79290e-03,-1.82589e-02,-1.25860e-02,-1.04311e-02,-3.02465e-03,&
     &  2.43063e-03, 3.63237e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
!          n density                                                    
      data ph1/                                                         &
     &  7.09557e+01,-3.26740e-01, 0.00000e+00,-5.16829e-01,-1.71664e-03,&
     &  9.09310e-02,-6.71500e-01,-1.47771e-01,-9.27471e-02,-2.30862e-01,&
     & -1.56410e-01, 1.34455e-02,-1.19717e-01, 2.52151e+00, 0.00000e+00,&
     & -2.41582e-01, 5.92939e-02, 4.39756e+00, 9.15280e-02, 4.41292e-03,&
     &  0.00000e+00, 8.66807e-03, 0.00000e+00, 0.00000e+00, 8.66784e-02,&
     &  1.58727e-01, 9.74701e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 6.70217e+01,-1.31660e-03, 0.00000e+00,-1.65317e-02,&
     &  0.00000e+00, 0.00000e+00, 8.50247e-02, 2.77428e+01, 4.98658e-03,&
     &  6.15115e-03, 9.50156e-03,-2.12723e-02, 8.47001e-02, 1.70147e-01,&
     & -2.38645e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00, 1.37380e-03/
      data ph2/                                                         &
     & -8.41918e-03, 2.80145e-05, 7.12383e-03, 0.00000e+00,-1.66209e-02,&
     &  1.03533e-04,-1.68898e-02, 0.00000e+00, 3.64526e+03, 0.00000e+00,&
     &  6.54077e-03, 3.69130e-04, 9.94419e-04, 8.42803e+01,-1.16124e-02,&
     & -7.74414e-03,-1.68844e-03, 1.42809e-03,-1.92955e-03, 1.17225e-01,&
     & -2.41512e-02, 1.50521e+04, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  1.60261e+03, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00,-3.54403e-04,-1.87270e-02,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  2.76439e-02, 6.43207e-03,-3.54300e-02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-2.80221e-02, 8.11228e+01,-6.75255e-04, 0.00000e+00/
      data ph3/                                                         &
     & -1.05162e-02,-3.48292e-03,-6.97321e-03, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-1.45546e-03,-1.31970e-02,-3.57751e-03,-1.09021e+00,&
     & -1.50181e-02,-7.12841e-03,-6.64590e-03,-3.52610e-03,-1.87773e-02,&
     & -2.22432e-03,-3.93895e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
!        hot o density                                                  
      data pi1/                                                         &
     &  6.04050e-02, 1.57034e+00, 2.99387e-02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-1.51018e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00,-8.61650e+00, 1.26454e-02,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 5.50878e-03, 0.00000e+00, 0.00000e+00, 8.66784e-02,&
     &  1.58727e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 6.23881e-02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 8.47001e-02, 1.70147e-01,&
     & -9.45934e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pi2/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pi3/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
!          s param                                                      
      data pj1/                                                         &
     &  9.56827e-01, 6.20637e-02, 3.18433e-02, 0.00000e+00, 0.00000e+00,&
     &  3.94900e-02, 0.00000e+00, 0.00000e+00,-9.24882e-03,-7.94023e-03,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 1.74712e+02, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 2.74677e-03, 0.00000e+00, 1.54951e-02, 8.66784e-02,&
     &  1.58727e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00,-6.99007e-04, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 1.24362e-02,-5.28756e-03, 8.47001e-02, 1.70147e-01,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pj2/                                                         &
     &  0.00000e+00, 2.47425e-05, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pj3/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
!          turbo                                                        
      data pk1/                                                         &
     &  1.09930e+00, 3.90631e+00, 3.07165e+00, 9.86161e-01, 1.63536e+01,&
     &  4.63830e+00, 1.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 1.28840e+00, 3.10302e-02, 1.18339e-01,&
     &  1.00000e+00, 7.00000e-01, 1.15020e+00, 3.44689e+00, 1.28840e+00,&
     &  1.00000e+00, 1.08738e+00, 1.22947e+00, 1.10016e+00, 7.34129e-01,&
     &  1.15241e+00, 2.22784e+00, 7.95046e-01, 4.01612e+00, 4.47749e+00,&
     &  1.23435e+02,-7.60535e-02, 1.68986e-06, 7.44294e-01, 1.03604e+00,&
     &  1.72783e+02, 1.15020e+00, 3.44689e+00,-7.46230e-01, 9.49154e-01/
!         lower boundary                                                
      data ptm/                                                         &
     &  1.04130e+03, 3.86000e+02, 1.95000e+02, 1.66728e+01, 2.13000e+02,&
     &  1.20000e+02, 2.40000e+02, 1.87000e+02,-2.00000e+00, 0.00000e+00/
      data pdm/                                                         &
     &  2.45600e+07, 6.71072e-06, 1.00000e+02, 0.00000e+00, 1.10000e+02,&
     &  1.00000e+01, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  8.59400e+10, 1.00000e+00, 1.05000e+02,-8.00000e+00, 1.10000e+02,&
     &  1.00000e+01, 9.00000e+01, 2.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  2.81000e+11, 0.00000e+00, 1.05000e+02, 2.80000e+01, 2.89500e+01,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  3.30000e+10, 2.68270e-01, 1.05000e+02, 1.00000e+00, 1.10000e+02,&
     &  1.00000e+01, 1.10000e+02,-1.00000e+01, 0.00000e+00, 0.00000e+00,&
     &  1.33000e+09, 1.19615e-02, 1.05000e+02, 0.00000e+00, 1.10000e+02,&
     &  1.00000e+01, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  1.76100e+05, 1.00000e+00, 9.50000e+01,-8.00000e+00, 1.10000e+02,&
     &  1.00000e+01, 9.00000e+01, 2.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  1.00000e+07, 1.00000e+00, 1.05000e+02,-8.00000e+00, 1.10000e+02,&
     &  1.00000e+01, 9.00000e+01, 2.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  1.00000e+06, 1.00000e+00, 1.05000e+02,-8.00000e+00, 5.50000e+02,&
     &  7.60000e+01, 9.00000e+01, 2.00000e+00, 0.00000e+00, 4.00000e+03/
!                                                                       
!                                                                       
!                                                                       
!                                                                       
!                                                                       
!                                                                       
!                                                                       
!         tn1(2)                                                        
      data pl1/                                                         &
     &  1.00858e+00, 4.56011e-02,-2.22972e-02,-5.44388e-02, 5.23136e-04,&
     & -1.88849e-02, 5.23707e-02,-9.43646e-03, 6.31707e-03,-7.80460e-02,&
     & -4.88430e-02, 0.00000e+00, 0.00000e+00,-7.60250e+00, 0.00000e+00,&
     & -1.44635e-02,-1.76843e-02,-1.21517e+02, 2.85647e-02, 0.00000e+00,&
     &  0.00000e+00, 6.31792e-04, 0.00000e+00, 5.77197e-03, 8.66784e-02,&
     &  1.58727e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-8.90272e+03, 3.30611e-03, 3.02172e-03, 0.00000e+00,&
     & -2.13673e-03,-3.20910e-04, 0.00000e+00, 0.00000e+00, 2.76034e-03,&
     &  2.82487e-03,-2.97592e-04,-4.21534e-03, 8.47001e-02, 1.70147e-01,&
     &  8.96456e-03, 0.00000e+00,-1.08596e-02, 0.00000e+00, 0.00000e+00/
      data pl2/                                                         &
     &  5.57917e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 9.65405e-03, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!         tn1(3)                                                        
      data pm1/                                                         &
     &  9.39664e-01, 8.56514e-02,-6.79989e-03, 2.65929e-02,-4.74283e-03,&
     &  1.21855e-02,-2.14905e-02, 6.49651e-03,-2.05477e-02,-4.24952e-02,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 1.19148e+01, 0.00000e+00,&
     &  1.18777e-02,-7.28230e-02,-8.15965e+01, 1.73887e-02, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00,-1.44691e-02, 2.80259e-04, 8.66784e-02,&
     &  1.58727e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 2.16584e+02, 3.18713e-03, 7.37479e-03, 0.00000e+00,&
     & -2.55018e-03,-3.92806e-03, 0.00000e+00, 0.00000e+00,-2.89757e-03,&
     & -1.33549e-03, 1.02661e-03, 3.53775e-04, 8.47001e-02, 1.70147e-01,&
     & -9.17497e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pm2/                                                         &
     &  3.56082e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-1.00902e-02, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!         tn1(4)                                                        
      data pn1/                                                         &
     &  9.85982e-01,-4.55435e-02, 1.21106e-02, 2.04127e-02,-2.40836e-03,&
     &  1.11383e-02,-4.51926e-02, 1.35074e-02,-6.54139e-03, 1.15275e-01,&
     &  1.28247e-01, 0.00000e+00, 0.00000e+00,-5.30705e+00, 0.00000e+00,&
     & -3.79332e-02,-6.24741e-02, 7.71062e-01, 2.96315e-02, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 6.81051e-03,-4.34767e-03, 8.66784e-02,&
     &  1.58727e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 1.07003e+01,-2.76907e-03, 4.32474e-04, 0.00000e+00,&
     &  1.31497e-03,-6.47517e-04, 0.00000e+00,-2.20621e+01,-1.10804e-03,&
     & -8.09338e-04, 4.18184e-04, 4.29650e-03, 8.47001e-02, 1.70147e-01,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data pn2/                                                         &
     & -4.04337e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-9.52550e-04,&
     &  8.56253e-04, 4.33114e-04, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 1.21223e-03,&
     &  2.38694e-04, 9.15245e-04, 1.28385e-03, 8.67668e-04,-5.61425e-06,&
     &  1.04445e+00, 3.41112e+01, 0.00000e+00,-8.40704e-01,-2.39639e+02,&
     &  7.06668e-01,-2.05873e+01,-3.63696e-01, 2.39245e+01, 0.00000e+00,&
     & -1.06657e-03,-7.67292e-04, 1.54534e-04, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!         tn1(5) tn2(1)                                                 
      data po1/                                                         &
     &  1.00320e+00, 3.83501e-02,-2.38983e-03, 2.83950e-03, 4.20956e-03,&
     &  5.86619e-04, 2.19054e-02,-1.00946e-02,-3.50259e-03, 4.17392e-02,&
     & -8.44404e-03, 0.00000e+00, 0.00000e+00, 4.96949e+00, 0.00000e+00,&
     & -7.06478e-03,-1.46494e-02, 3.13258e+01,-1.86493e-03, 0.00000e+00,&
     & -1.67499e-02, 0.00000e+00, 0.00000e+00, 5.12686e-04, 8.66784e-02,&
     &  1.58727e-01,-4.64167e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  4.37353e-03,-1.99069e+02, 0.00000e+00,-5.34884e-03, 0.00000e+00,&
     &  1.62458e-03, 2.93016e-03, 2.67926e-03, 5.90449e+02, 0.00000e+00,&
     &  0.00000e+00,-1.17266e-03,-3.58890e-04, 8.47001e-02, 1.70147e-01,&
     &  0.00000e+00, 0.00000e+00, 1.38673e-02, 0.00000e+00, 0.00000e+00/
      data po2/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 1.60571e-03,&
     &  6.28078e-04, 5.05469e-05, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-1.57829e-03,&
     & -4.00855e-04, 5.04077e-05,-1.39001e-03,-2.33406e-03,-4.81197e-04,&
     &  1.46758e+00, 6.20332e+00, 0.00000e+00, 3.66476e-01,-6.19760e+01,&
     &  3.09198e-01,-1.98999e+01, 0.00000e+00,-3.29933e+02, 0.00000e+00,&
     & -1.10080e-03,-9.39310e-05, 1.39638e-04, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!          tn2(2)                                                       
      data pp1/                                                         &
     &  9.81637e-01,-1.41317e-03, 3.87323e-02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-3.58707e-02,&
     & -8.63658e-03, 0.00000e+00, 0.00000e+00,-2.02226e+00, 0.00000e+00,&
     & -8.69424e-03,-1.91397e-02, 8.76779e+01, 4.52188e-03, 0.00000e+00,&
     &  2.23760e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-7.07572e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     & -4.11210e-03, 3.50060e+01, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00,-8.36657e-03, 1.61347e+01, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00,-1.45130e-02, 0.00000e+00, 0.00000e+00/
      data pp2/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 1.24152e-03,&
     &  6.43365e-04, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 1.33255e-03,&
     &  2.42657e-03, 1.60666e-03,-1.85728e-03,-1.46874e-03,-4.79163e-06,&
     &  1.22464e+00, 3.53510e+01, 0.00000e+00, 4.49223e-01,-4.77466e+01,&
     &  4.70681e-01, 8.41861e+00,-2.88198e-01, 1.67854e+02, 0.00000e+00,&
     &  7.11493e-04, 6.05601e-04, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!          tn2(3)                                                       
      data pq1/                                                         &
     &  1.00422e+00,-7.11212e-03, 5.24480e-03, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-5.28914e-02,&
     & -2.41301e-02, 0.00000e+00, 0.00000e+00,-2.12219e+01,-1.03830e-02,&
     & -3.28077e-03, 1.65727e-02, 1.68564e+00,-6.68154e-03, 0.00000e+00,&
     &  1.45155e-02, 0.00000e+00, 8.42365e-03, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-4.34645e-03, 0.00000e+00, 0.00000e+00, 2.16780e-02,&
     &  0.00000e+00,-1.38459e+02, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 7.04573e-03,-4.73204e+01, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 1.08767e-02, 0.00000e+00, 0.00000e+00/
      data pq2/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-8.08279e-03,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 5.21769e-04,&
     & -2.27387e-04, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 3.26769e-03,&
     &  3.16901e-03, 4.60316e-04,-1.01431e-04, 1.02131e-03, 9.96601e-04,&
     &  1.25707e+00, 2.50114e+01, 0.00000e+00, 4.24472e-01,-2.77655e+01,&
     &  3.44625e-01, 2.75412e+01, 0.00000e+00, 7.94251e+02, 0.00000e+00,&
     &  2.45835e-03, 1.38871e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!          tn2(4) tn3(1)                                                
      data pr1/                                                         &
     &  1.01890e+00,-2.46603e-02, 1.00078e-02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-6.70977e-02,&
     & -4.02286e-02, 0.00000e+00, 0.00000e+00,-2.29466e+01,-7.47019e-03,&
     &  2.26580e-03, 2.63931e-02, 3.72625e+01,-6.39041e-03, 0.00000e+00,&
     &  9.58383e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-1.85291e-03, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 1.39717e+02, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 9.19771e-03,-3.69121e+02, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00,-1.57067e-02, 0.00000e+00, 0.00000e+00/
      data pr2/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-7.07265e-03,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-2.92953e-03,&
     & -2.77739e-03,-4.40092e-04, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.47280e-03,&
     &  2.95035e-04,-1.81246e-03, 2.81945e-03, 4.27296e-03, 9.78863e-04,&
     &  1.40545e+00,-6.19173e+00, 0.00000e+00, 0.00000e+00,-7.93632e+01,&
     &  4.44643e-01,-4.03085e+02, 0.00000e+00, 1.15603e+01, 0.00000e+00,&
     &  2.25068e-03, 8.48557e-04,-2.98493e-04, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!          tn3(2)                                                       
      data ps1/                                                         &
     &  9.75801e-01, 3.80680e-02,-3.05198e-02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 3.85575e-02,&
     &  5.04057e-02, 0.00000e+00, 0.00000e+00,-1.76046e+02, 1.44594e-02,&
     & -1.48297e-03,-3.68560e-03, 3.02185e+01,-3.23338e-03, 0.00000e+00,&
     &  1.53569e-02, 0.00000e+00,-1.15558e-02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 4.89620e-03, 0.00000e+00, 0.00000e+00,-1.00616e-02,&
     & -8.21324e-03,-1.57757e+02, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 6.63564e-03, 4.58410e+01, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00,-2.51280e-02, 0.00000e+00, 0.00000e+00/
      data ps2/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 9.91215e-03,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-8.73148e-04,&
     & -1.29648e-03,-7.32026e-05, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-4.68110e-03,&
     & -4.66003e-03,-1.31567e-03,-7.39390e-04, 6.32499e-04,-4.65588e-04,&
     & -1.29785e+00,-1.57139e+02, 0.00000e+00, 2.58350e-01,-3.69453e+01,&
     &  4.10672e-01, 9.78196e+00,-1.52064e-01,-3.85084e+03, 0.00000e+00,&
     & -8.52706e-04,-1.40945e-03,-7.26786e-04, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!          tn3(3)                                                       
      data pu1/                                                         &
     &  9.60722e-01, 7.03757e-02,-3.00266e-02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.22671e-02,&
     &  4.10423e-02, 0.00000e+00, 0.00000e+00,-1.63070e+02, 1.06073e-02,&
     &  5.40747e-04, 7.79481e-03, 1.44908e+02, 1.51484e-04, 0.00000e+00,&
     &  1.97547e-02, 0.00000e+00,-1.41844e-02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 5.77884e-03, 0.00000e+00, 0.00000e+00, 9.74319e-03,&
     &  0.00000e+00,-2.88015e+03, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00,-4.44902e-03,-2.92760e+01, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 2.34419e-02, 0.00000e+00, 0.00000e+00/
      data pu2/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 5.36685e-03,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-4.65325e-04,&
     & -5.50628e-04, 3.31465e-04, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-2.06179e-03,&
     & -3.08575e-03,-7.93589e-04,-1.08629e-04, 5.95511e-04,-9.05050e-04,&
     &  1.18997e+00, 4.15924e+01, 0.00000e+00,-4.72064e-01,-9.47150e+02,&
     &  3.98723e-01, 1.98304e+01, 0.00000e+00, 3.73219e+03, 0.00000e+00,&
     & -1.50040e-03,-1.14933e-03,-1.56769e-04, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!          tn3(4)                                                       
      data pv1/                                                         &
     &  1.03123e+00,-7.05124e-02, 8.71615e-03, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-3.82621e-02,&
     & -9.80975e-03, 0.00000e+00, 0.00000e+00, 2.89286e+01, 9.57341e-03,&
     &  0.00000e+00, 0.00000e+00, 8.66153e+01, 7.91938e-04, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 4.68917e-03, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 7.86638e-03, 0.00000e+00, 0.00000e+00, 9.90827e-03,&
     &  0.00000e+00, 6.55573e+01, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00,-4.00200e+01, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 7.07457e-03, 0.00000e+00, 0.00000e+00/
      data pv2/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 5.72268e-03,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-2.04970e-04,&
     &  1.21560e-03,-8.05579e-06, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-2.49941e-03,&
     & -4.57256e-04,-1.59311e-04, 2.96481e-04,-1.77318e-03,-6.37918e-04,&
     &  1.02395e+00, 1.28172e+01, 0.00000e+00, 1.49903e-01,-2.63818e+01,&
     &  0.00000e+00, 4.70628e+01,-2.22139e-01, 4.82292e-02, 0.00000e+00,&
     & -8.67075e-04,-5.86479e-04, 5.32462e-04, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!          tn3(5) surface temp tsl                                      
      data pw1/                                                         &
     &  1.00828e+00,-9.10404e-02,-2.26549e-02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-2.32420e-02,&
     & -9.08925e-03, 0.00000e+00, 0.00000e+00, 3.36105e+01, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00,-1.24957e+01,-5.87939e-03, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 2.79765e+01, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 2.01237e+03, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00,-1.75553e-02, 0.00000e+00, 0.00000e+00/
      data pw2/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 3.29699e-03,&
     &  1.26659e-03, 2.68402e-04, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 1.17894e-03,&
     &  1.48746e-03, 1.06478e-04, 1.34743e-04,-2.20939e-03,-6.23523e-04,&
     &  6.36539e-01, 1.13621e+01, 0.00000e+00,-3.93777e-01, 2.38687e+03,&
     &  0.00000e+00, 6.61865e+02,-1.21434e-01, 9.27608e+00, 0.00000e+00,&
     &  1.68478e-04, 1.24892e-03, 1.71345e-03, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!          tgn3(2) surface grad tslg                                    
      data px1/                                                         &
     &  1.57293e+00,-6.78400e-01, 6.47500e-01, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-7.62974e-02,&
     & -3.60423e-01, 0.00000e+00, 0.00000e+00, 1.28358e+02, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 4.68038e+01, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-1.67898e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 2.90994e+04, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 3.15706e+01, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data px2/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!          tgn2(1) tgn1(2)                                              
      data py1/                                                         &
     &  8.60028e-01, 3.77052e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-1.17570e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 7.77757e-03, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 1.01024e+02, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 6.54251e+02, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
      data py2/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,-1.56959e-02,&
     &  1.91001e-02, 3.15971e-02, 1.00982e-02,-6.71565e-03, 2.57693e-03,&
     &  1.38692e+00, 2.82132e-01, 0.00000e+00, 0.00000e+00, 3.81511e+02,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!          tgn3(1) tgn2(2)                                              
      data pz1/                                                         &
     &  1.06029e+00,-5.25231e-02, 3.73034e-01, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 3.31072e-02,&
     & -3.88409e-01, 0.00000e+00, 0.00000e+00,-1.65295e+02,-2.13801e-01,&
     & -4.38916e-02,-3.22716e-01,-8.82393e+01, 1.18458e-01, 0.00000e+00,&
     & -4.35863e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00,-1.19782e-01, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 2.62229e+01, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00,-5.37443e+01, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00,-4.55788e-01, 0.00000e+00, 0.00000e+00/
      data pz2/                                                         &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 3.84009e-02,&
     &  3.96733e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 5.05494e-02,&
     &  7.39617e-02, 1.92200e-02,-8.46151e-03,-1.34244e-02, 1.96338e-02,&
     &  1.50421e+00, 1.88368e+01, 0.00000e+00, 0.00000e+00,-5.13114e+01,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  5.11923e-02, 3.61225e-02, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 2.00000e+00/
!          semiannual mult sam                                          
      data paa1/                                                        &
     &  1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00,&
     &  1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00,&
     &  1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00,&
     &  1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00,&
     &  1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00,&
     &  1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00,&
     &  1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00,&
     &  1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00,&
     &  1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00,&
     &  1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00, 1.00000e+00/
      data paa2/                                                        &
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00,&
     &  0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00, 0.00000e+00/
!         middle atmosphere averages                                    
      data pavgm/                                                       &
     &  2.61000e+02, 2.64000e+02, 2.29000e+02, 2.17000e+02, 2.17000e+02,&
     &  2.23000e+02, 2.86760e+02,-2.93940e+00, 2.50000e+00, 0.00000e+00/
      end                                           


