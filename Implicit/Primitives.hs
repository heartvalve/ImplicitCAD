-- Implicit CAD. Copyright (C) 2011, Christopher Olah (chris@colah.ca)
-- Released under the GNU GPL, see LICENSE

module Implicit.Primitives (
	sphere,
	cube,
	circle,
	cylinder,
	square,
	regularNGon,
	polygon,
	zsurface--,
	--ellipse
) where

import Implicit.Definitions
import qualified Implicit.SaneOperators as S

sphere :: ℝ -> Obj3
sphere r = \(x,y,z) -> sqrt (x**2 + y**2 + z**2) - r

cube :: ℝ -> Obj3
cube l = \(x,y,z) -> (maximum $ map abs [x,y,z]) - l/2.0

cylinder :: ℝ -> ℝ -> Obj3
cylinder r h = \(x,y,z) -> max (sqrt(x^2+y^2) - r) (abs(z) - h)

circle :: ℝ -> Obj2
circle r = \(x,y) -> sqrt (x**2 + y**2) - r

--ellipse :: ℝ -> ℝ -> Obj2
--ellipse a b = \(x,y) ->
--	if a > b 
--	then ellipse b a (y,x)
--	else sqrt ((b/a*x)*	*2 + y**2) - a

square :: ℝ -> Obj2
square l = \(x,y) -> (maximum $ map abs [x,y]) - l/2.0

polygon :: [ℝ2] -> Obj2
polygon points = 
	let
		pairs = 
		   [ (points !! n, points !! (mod (n+1) (length points) ) ) | n <- [0 .. (length points) - 1] ]
		isIn p@(p1,p2) = 
			let 
				crossing_points = 
					[x1 + (x2-x1)*y2/(y2-y1) |
					((x1,y1), (x2,y2)) <- 
						map (\((a1,a2),(b1,b2)) -> ((a1-p1,a2-p2), (b1-p1,b2-p2)) ) pairs,
					( (y2 < 0) && (y1 > 0) ) || ( (y2 > 0) && (y1 < 0) ) ]
			in 
				if odd $ length $ filter (>0) crossing_points then -1 else 1
		dist a@(a1,a2) b@(b1,b2) p@(p1,p2) =
			let
				ab = b S.- a
				nab = S.norm ab
				ap = p S.- a
				d  = ab S.⋅ ap
				closest 
					| d < 0 = a
					| d > 1 = b
					| otherwise = a S.+ d S.* ab
			in
				S.norm (closest S.- p)
		dists = \ p -> map (\(a,b) ->  dist a b p) pairs
	in 
		\ p -> isIn p * minimum (dists p)

roundRegularNGon sides n r =
	let unnormalized x y = (**(1/n)) $ sum $ map (**n) $ filter (>0) $
			[ x*cos(2*pi*m/sides) + y*sin(2*pi*m/sides) | m <- [0.. sides -1]] in 
	\(x,y) -> (unnormalized x y) / (unnormalized 1 0) - r 

regularNGon sides r =
	let unnormalized x y = maximum $
			[ x*cos(2*pi*m/sides) + y*sin(2*pi*m/sides) | m <- [0.. sides -1]] in 
	\(x,y) -> (unnormalized x y) / (unnormalized 1 0) - r 


zsurface :: (ℝ2 -> ℝ) -> Obj3
zsurface f = \(x,y,z) -> f (x,y) - z
