# complex
Operations with complex numbers

Usage: 
```
complex/compact [e ** (i * pi) + 1 = 0] ;== true
complex [(2,1) * (3,1)] ;== (5, 5)
complex [(1,3) + (2,2)] ;== (3, 5)
complex [(3,4) * i] ;== (-4, 3)
complex [to-complex/deg 1 90] ;== (0, 1)
complex [to-angular/deg i] ;== (1, 90) ; magnitude 1, angle 90
complex [(5,5) / (2,1)] ;== (3, 1)
complex [2 - (1,-1)] ;== (1, 1)
complex [to-polar (1,1)] ;== (0.7071068, 0.7071068, 1.414214)
complex [normalize (1,1)] ;== (0.7071068, 0.7071068)
complex [to-angular/deg e ** (i * pi / 3)] ;== (1, 60)
x: complex [e ** i] ;== (0.5403023, 0.841471)
complex [ln x] ;== (0, 1)
complex [i = ln x] ;== true
x: complex [(to-complex/deg 1 60) ** 1/3] ;== (0.9396926, 0.3420201)
complex [x ** 3] ;== (0.5000001, 0.8660253)
complex [to-angular/deg x ** 3] ;== (0.9999999, 59.99999)
ctx/rnd: 0.0001 ;== 0.0001
complex [to-angular/deg x ** 3] ;== (1, 60)
ctx/rnd: 0.0000001 ;== 1.0e-7
x: complex [root/all (to-complex/deg 1 60) 3] ;== [(0.9396926, 0.3420201) (-0.7660444, 0.6427876) (-0.1736481, -0.9848078)]
ctx/rnd: 0.0001
complex [repeat n length? x [prin [to-angular/deg x/:n ** 3 " "]] print ""] ; (1, 60)  (1, 60)  (1, 60)
x: complex [e ** (0.5,1)] ;== (0.8908079, 1.387351)
complex [ln x] ;== (0.5000001, 1)
complex [(i ** i) ~ (e ** (-pi / 2))] ;== true
x: complex/compact [(1,1) ** (1,1)] ;== (0.2739572, 0.5837007)
y: complex [(sqrt 2) * (e ** (-pi / 4)) * to-cx reduce [cos a: (pi / 4) + ((log-e 2) / 2) sin a]] ;== (0.2739573, 0.5837007)
x = y ;== true
