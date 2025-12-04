point3D! is interpreted as (normalized re, normalized im, magnitude)
point2D! is interpreted as (re, im)
angular is interpreted as (magnitude, argument)

Red [
	Author: "Toomas Vooglaid"
	Date: 3-Dec-2025
	Description: {Operations with complex numbers. Complex numbers are taken to be point2D! and point3D!. See comment in the top of file.}
	File: %complex.red
]

{
Lexer is twisted to recognize rationals like 1/3, pi/2, 1/i... when calculating roots.
May be commented out. Then rationals should be entered as blocks, e.g. [1 / 2]
}
;comment [
system/lexer/pre-load: function [src len][
	digit: charset "0123456789"
	sci: [#"e" opt #"-" some digit]
	int: [some digit] 
	upper: charset [#"A" - #"Z"]
	lower: charset [#"a" - #"z"]
	alpha: union upper lower
	;word: [some alpha opt int]
	const: ["pi" | "e" | "i"]
	value: [int | const]
	ws: charset { ^/^-)]}
	ratio: [value #"/" value  ahead ws e:]
	parse src [
		some [
			ahead ratio s: 
			change only ratio (rejoin ["[" replace copy/part s e #"/" #" "  "]"]) ;:e 
		| skip
		]
	]
]
;]
ctx: context [
	compact?: false
	
	_a: select system/words '+
	_s: select system/words '-
	_m: select system/words '*
	_d: select system/words '/
	_p: select system/words '**
	
	 e: exp 1
	 i: (0, 1)
	-i: (0,-1)
	tau: 2 _m pi
	rnd: 0.000001
	
	rise-error: func [msg [block!]][cause-error 'user 'message rejoin msg]
	conj: conjugate: func [a [point2D! point3D!]][a/2: a/2 _m -1  a]
	norm: func [a [point2D! point3D!]][either point3D? a [a/3 _p 2][(a/1 _p 2) _a (a/2 _p 2)]]
	abs: modulus: magnitude: func [a [point2D! point3D!]][either point3D? a [a/3][round/to sqrt norm a self/rnd]]
	re: func [a [point2D! point3D! integer! float!]][if number? a [return a] either point2D? a [a/1][a/1 _m a/3]]
	im: func [a [point2D! point3D! integer! float!]][if number? a [return 0] either point2D? a [a/2][a/2 _m a/3]]
	arg: argument: phase: func [a [point2D! point3D!] /deg][either deg [round/to arctangent2 a/2 a/1 self/rnd][round/to atan2 a/2 a/1 self/rnd]]
	ang: angle: func [a [point2D! point3D!] /rad][either rad [round/to atan2 a/2 a/1 self/rnd][round/to arctangent2 a/2 a/1 self/rnd]]
	to-radians: func [degrees [integer! float!]][degrees * pi _d 180]
	to-degrees: func [radians [integer! float!]][radians * 180 _d pi]
	
	__comp__: __pack__: function [res][
		if self/compact? [
			case [
				all [point2D? :res  0 = res/2][return res/1]
				all [point3D? :res  0 = res/2][return res/1 _m res/3]
			]
		]
		res
	]

	almost: func [
		a [point2D! point3D! integer! float!] 
		b [point2D! point3D! integer! float!]
	][
		case [
			all [number? a number? b][self/rnd >= absolute a - b]
			all [number? a not number? b][b: to-cx b all [b/2 ~ 0  a ~ b/1]]
			all [not number? a number? b][a: to-cx a all [a/2 ~ 0  b ~ a/1]]
			true [a: to-cx a b: to-cx b all [a/1 ~ b/1  a/2 ~ b/2]]
		]
	]

	~: make op! :almost

	normalize: function [a [point2D! point3D!] return: [point2D!]][
		if point2D? a [a: to-polar a]
		to-complex reduce [a/1 a/2]
	]
	
	to-polar: function [a [point2D!] /deg /rad return: [point3D!]][
		{a is either complex number or pair of magnitude and angle in /deg or /rad}
		res: reduce case [
			rad  [[round/to cos      a/2   self/rnd  round/to sin  a/2 self/rnd  a/1]]
			deg  [[round/to cosine   a/2   self/rnd  round/to sine a/2 self/rnd  a/1]]
			true [[round/to cos ang: arg a self/rnd  round/to sin  ang self/rnd  magnitude a]]
		]
		to point3D! res 
	]
	
	to-angular: function [a [point2D! point3D!] /deg return: [point2D!]][
		ang: argument/:deg a
		mag: magnitude a
		return to-complex [mag ang]
	]

	to-cx: to-complex: function [
		a [point2D! point3D! integer! float! block!]
		/rad r [integer! float!] "Only if main argument is magnitude (int or float)"
		/deg d [integer! float!] "Only if main argument is magnitude (int or float)"
		/angular from [word!]
		return: [point2D! point3D!]
	][
		if all [any [rad deg] not number? a][rise-error ["Angle only with int or float magnitude!"]]
		case [
			all [angular point2D! a][
				switch from [
					deg [to-cx to-polar/deg a]
					rad [to-cx to-polar/rad a]
				]
			]
			point2D? :a         [a] 
			point3D? :a         [to point2D! reduce [a/1 _m a/3  a/2 _m a/3]]
			all [rad number? a] [to-cx to-polar/rad to point2D! reduce [a r]]
			all [deg number? a] [to-cx to-polar/deg to point2D! reduce [a d]]
			block? a            [
				a: reduce a
				switch/default length? a [
					2 [to point2D! a] 
					3 [to point3D! a]
				][
					rise-error ["Wrong input format for to-complex!"]
				]
			]
			true [to point2D! reduce [a 0]]
		]
	]
	
	cx-add: complex-add: function [
		a [point2D! point3D! integer! float!] 
		b [point2D! point3D! integer! float!]
		return: [point2D! number!]
	][
		if all [number? a  number? b][return a _a b]
		a: to-complex a 
		b: to-complex b 
		return __comp__ a _a b
	]
	
	cx-sub: complex-subtract: function [
		a [point2D! point3D! integer! float!] 
		b [point2D! point3D! integer! float!]
		return: [point2D! number!]
	][
		if all [number? a  number? b][return a _s b]
		return __comp__ cx-add a -1 _m b
	]
	
	cx-mult: complex-multiply: function [
		a [point2D! point3D! integer! float!] 
		b [point2D! point3D! integer! float!]
		return: [point2D! point3D! number!]
	][
		if all [number? a  number? b][return a _m b]
		if all [point3D? a  point3D? b][
			c: (acos a/1) + (acos b/1) 
			d: (asin a/2) + (asin b/2) 
			return __comp__ to-complex reduce [
				round/to cos c self/rnd  round/to sin d self/rnd  a/3 * b/3
			]
		]
		a: to-complex a 
		b: to-complex b 
		r: (a/1 _m b/1) _s (a/2 _m b/2) 
		j: (a/1 _m b/2) _a (a/2 _m b/1) 
		return __comp__ to point2D! reduce [r  j]
	]
	
	cx-div: complex-divide: function [
		a [point2D! point3D! integer! float!] 
		b [point2D! point3D! integer! float!]
		return: [point2D! point3D! number!]
	][
		if all [number? a number? b] [return a _d b]
		if all [point3D? a point3D? b][
			c: (acos a/1) - (acos b/1)
			d: (asin a/2) - (asin b/2)
			return __comp__ to-complex reduce [
				round/to cos c self/rnd  round/to sin d self/rnd  a/3 / b/3
			]
		]
		a: to-complex a
		b: to-complex b
		x: complex-multiply a conjugate b 
		y: norm b 
		return __comp__ to point2D! reduce [x/1 _d y  x/2 _d y]
	]
	
	cx-pow: complex-power: function [
		a [point2D! point3D! integer! float!] 
		b [point2D! point3D! integer! float! block!]
		return: [point2D! point3D! number!]
	][
		if all [number? a  number? b][return a _p b]
		if all [number? a  point2D? b][
			b: to-cx complex-multiply b log-e a
			r: (exp 1) _p b/1
			return __comp__ to-complex reduce [
				round/to r _m cos b/2 self/rnd  round/to r _m sin b/2 self/rnd
			]
		]
		if all [point3D? a number? b][
			return __comp__ to-complex reduce [
				round/to cos b * acos a/1 self/rnd  round/to sin b * asin a/1 self/rnd  a/3 ** b
			]
		]
		a: to-complex a
		if integer? b [
			positive: true
			if b < 0 [positive: false  b: -1 * b]
			c: a 
			loop b - 1 [c: complex-multiply c a] 
			either positive [
				return __comp__ c
			][
				n: norm c
				return __comp__ to-cx reduce [round/to c/1 / n self/rnd  round/to c/2 / n * -1 self/rnd] 
			]
		]
		if block? b [
			either find b '/ [
				b: reduce head remove find b '/
			][  b: reduce b]
			a: a ** b/1
			return root a b/2
		]
		
		b: to-complex b
		return __comp__ (norm a) ** (b / 2) * (e ** (i * b * arg a))
	]
	
	root: function [
		a [point2D! point3D!] 
		b [integer! float!]
		/angular from [word!]
		/deg 
		/rad
		/as-polar
		/as-rad
		/as-deg
		/all
		return: [point2d! number!]
	][
		if not any [angular deg rad][a: to-angular a]
		if any [deg system/words/all [angular from = 'deg]][a/2: to-radians a/2]
		
		m: a/1 _p (1 _d b)
		
		res: collect [
			repeat n b [
				k: n _s 1
				ang: k _m tau _a a/2 _d b
				res: e ** (i * ang)
				keep case [
					as-rad [to-cx reduce [m atan2 res/2 res/1]]
					as-deg [to-cx reduce [m arctangent2 res/2 res/1]]
					as-polar [to-cx reduce [res/1 res/2 m]]
					true [m * res]
				]
				if not all [break]
			]
		]
		either all [res][res/1]
	]
	
	ln: function [
		a [point2D! point3D! integer! float!] 
		return: [point2D! number!]
	][
		if number? a [return log-e a]
		a: to-angular a
		to-cx reduce [log-e a/1 a/2] 
	]
	
	+:  make op! :cx-add
	-:  make op! :cx-sub
	*:  make op! :cx-mult
	/:  make op! :cx-div
	**: make op! :cx-pow
	
	set 'complex function [ctx [block!] /compact /full][
		if compact [self/compact?: true]
		if full    [self/compact?: false]
		do bind ctx self
	]
] ()
