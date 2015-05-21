pro calculate_refilling_rate, den, ut_hr_save, n_read_max

i0=1
i1=n_read_max-1
t0 = ut_hr_save[i0] ;hrs
t1 = ut_hr_save[i1] ;hrs
dt = (t1 - t0) ;=24hrs
print,'t0=', t0,' t1=', t1,' dt=', dt

n0 = den[i0] ;cm-3
n1 = den[i1] ;cm-3
;dn = n1 - n0
print,'n0=', n0,' n1=',n1,' dn=',(n1-n0)

;refilling rate
rate = (n1-n0) / ( dt/24. )
print, 'rate [cm-3 day-1] =', rate


end ;pro calculate_refilling_rate
