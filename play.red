Red [Needs: 'View]

#include %complex.red

c1: 100 ;initial
c2: 200 ;steps
c3: 1   ;real
c4: pi / 3 ;imag

get-points: function [initial steps real imag][
	complex [
		points: collect [c: to-cx reduce [initial * c1 0] repeat n c2 * steps [keep c: c * to-cx reduce [c3 * real c4 * imag]]]
	]
]

get-draw: function [s1 s2 s3 s4][
	points: get-points s1 s2 s3 s4
	p2: collect [foreach point points [keep 'circle keep point keep 1]]
	compose/deep [
		pen yellow 
		translate 300x300 [spline (points) (p2)]
	]
]

;play: function [][
	view [title "Spiral playground"
		text right "initial:" s1: slider 300x20 data 0.5 on-change [
			canvas/draw: get-draw s1/data s2/data s3/data s4/data 
			t1/data: form round/to c1 * s1/data 1
		] 
		t1: text "" return
		text right "steps:"   s2: slider 300x20 data 0.5 on-change [
			canvas/draw: get-draw s1/data s2/data s3/data s4/data 
			t2/data: form round/to c2 * s2/data 1
		] 
		t2: text "" return
		text right "real:"    s3: slider 300x20 data 0.5 on-change [
			canvas/draw: get-draw s1/data s2/data s3/data s4/data 
			t3/data: form round/to c3 * s3/data 0.001
		] 
		t3: text "" return
		text right "imag:"    s4: slider 300x20 data 0.5 on-change [
			canvas/draw: get-draw s1/data s2/data s3/data s4/data 
			t4/data: form round/to c4 * s4/data 0.001
		] 
		t4: text "" return
		below
		canvas: base with [
			size:  600x600
			color: 8.20.33 * 5
			draw: get-draw s1/data s2/data s3/data s4/data
		] 
		button "Quit" [quit]
	]
;]
