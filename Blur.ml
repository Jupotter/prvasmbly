let gaussian i =
let out = i in
	for x=0 to i#width-1 do
	for y=2 to i#height-3 do
		let (p,p_1,p_2,p1,p2) =(
			i#get_pixel x y,
			i#get_pixel x (y-1),
			i#get_pixel x (y-2),
			i#get_pixel x (y+1),
			i#get_pixel x (y+2))in
			let (pr,pg,pb) =p#get_rgb in
			let (p_1r,p_1g,p_1b) =p_1#get_rgb in
			let (p_2r,p_2g,p_2b) =p_2#get_rgb in
			let (p2r,p2g,p2b) =p2#get_rgb in
			let (p1r,p1g,p1b) =p1#get_rgb in
			let or = 0.16*.pr+.
					0.08*.(p_1r+.p1r)+.
					0.04*.(p_2r+.p2r) in
			let og = 0.16*.pg+.
					0.08*.(p_1g+.p1g)+.
					0.04*.(p_2g+.p2g) in
			let ob = 0.16*.pb+.
					0.08*.(p_1b+.p1b)+.
					0.04*.(p_2b+.p2b) in
			let col = new BasicTypes.color in
			col#set_rgb or og ob;
			out#set_pixel col x y
	done
	done;
	for y=0 to i#height-1 do
	for x=2 to i#width-3 do
		let (p,p_1,p_2,p1,p2) =(
			i#get_pixel x y,
			i#get_pixel (x-1) y,
			i#get_pixel (x-2) y,
			i#get_pixel (x+1) y,
			i#get_pixel (x+2) y)in
			let (pr,pg,pb) =p#get_rgb in
			let (p_1r,p_1g,p_1b) =p_1#get_rgb in
			let (p_2r,p_2g,p_2b) =p_2#get_rgb in
			let (p2r,p2g,p2b) =p2#get_rgb in
			let (p1r,p1g,p1b) =p1#get_rgb in
			let or = 0.16*.pr+.
					0.08*.(p_1r+.p1r)+.
					0.04*.(p_2r+.p2r) in
			let og = 0.16*.pg+.
					0.08*.(p_1g+.p1g)+.
					0.04*.(p_2g+.p2g) in
			let ob = 0.16*.pb+.
					0.08*.(p_1b+.p1b)+.
					0.04*.(p_2b+.p2b) in
			let col = new BasicTypes.color in
			col#set_rgb or og ob;
			out#set_pixel col x y
	done
	done;
out
