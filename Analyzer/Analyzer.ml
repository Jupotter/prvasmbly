
(* This is launch at the beginning *)

let initialize () = ();;

(* Return all the colors contained in the image *)

let get_image_colors (i:BasicTypes.image) = ();;

(* Double Differential *)

let double_diff (i:BasicTypes.image) =
let out = i in
for x=0 to (i#width-1) do
	for y=0 to (i#height)-1 do
	let col =
		let pix = i#get_pixel x y in
		if ((x < (i#width-1))
		   && ((pix#get_rgb) <> (let n=i#get_pixel (x+1) y in n#get_rgb))) then
			let col = new BasicTypes.color in
				col#set_rgb 0. 0. 0.;
				col
		else
		if ((y < (i#height-1))
		   && ((pix#get_rgb) <> (let n=i#get_pixel x (y+1) in n#get_rgb))) then
			let col = new BasicTypes.color in
				col#set_rgb 0. 0. 0.;
				col
		else
			pix
	in
		(out#set_pixel col x y)
	done
done

(* Outlines on a black image *)

let outlines i =
let out = i in
for x=0 to (i#width-1) do
	for y=0 to (i#height-1) do
	let col =
		let pix = i#get_pixel x y in
		if ((x < (i#width-1))
		   && ((pix#get_rgb) <> (let n=i#get_pixel (x+1) y in n#get_rgb))) then
			let col = new BasicTypes.color in
				col#set_rgb 1. 1. 1.;
				col
		else
		if ((y < (i#height-1))
		   && ((pix#get_rgb) <> (let n=i#get_pixel x (y+1) in n#get_rgb))) then
			let col = new BasicTypes.color in
				col#set_rgb 1. 1. 1.;
				col
		else
		let col = new BasicTypes.color in
			col#set_rgb 0. 0. 0.;
			col
	in
		(out#set_pixel col x y)
	done
done

(* Put a grid of n pixel on an image *)

let grid i n =
let out = i in
for x=0 to (i#width-1) do
	for y=0 to (i#height-1) do
	let col = new BasicTypes.color in
	let _ = col#set_rgb 0. 0. 0. in
		if ((x mod n =0)||(y mod n = 0)) then
			out#set_pixel col x y
		else ()
	done
done


let grid_diag (i:BasicTypes.image) n =
let out = i in
for x=0 to (i#width-1) do
	for y=0 to (i#height-1) do
	let col = new BasicTypes.color in
	let _ = col#set_rgb 0. 0. 0. in
		if ((x mod n =0)||(y mod n = 0)||(x mod n + y mod n = n)) then
			out#set_pixel col x y
		else ()
	done
done

(* Divide an image by 2 on each axis, with priority to white pixel *)
(*errreur il faut traiter x = out#width - 1 et y = out#height à part*)
let div_two (i:BasicTypes.image) =
let out = new BasicTypes.image (i#width / 2) (i#height / 2) in
for x=0 to ((out#width ) - 1) do
	for y=0 to ((out#height) - 1) do
	let col = new BasicTypes.color in
		if ((i#get_pixel (2*x) (2*y))#is_white)
		 ||((i#get_pixel (2*x+1) (2*y))#is_white)
		 ||((i#get_pixel (2*x) (2*y+1))#is_white)
		 ||((i#get_pixel (2*x+1) (2*y+1))#is_white) then
		begin
			col#set_rgb 1.0 1.0 1.0;
			out#set_pixel col x y;
		end
		else
		begin
			out#set_pixel col x y;
		end
	done
done;
(out;)

(* Double the thickness of the outline *)

let double_outline i =
let out = i in
for x=1 to i#width-2 do
	for y=1 to i#height-2 do
		if (let n=i#get_pixel (x-1) (y-1) in n#is_white)
		 ||(let n=i#get_pixel (x) (y-1) in n#is_white)
		 ||(let n=i#get_pixel (x+1) (y-1) in n#is_white)
		 ||(let n=i#get_pixel (x+1) (y) in n#is_white)
		 ||(let n=i#get_pixel (x+1) (y+1) in n#is_white)
		 ||(let n=i#get_pixel (x) (y+1) in n#is_white)
		 ||(let n=i#get_pixel (x-1) (y+1) in n#is_white)
		 ||(let n=i#get_pixel (x-1) (y) in n#is_white)
		then
 			let col =new BasicTypes.color in
			let _ = col#set_rgb 1. 1. 1. in
				out#set_pixel col x y
		else
			out#_set_pixel (i#get_pixel x y) x y
	done
done;
out

(* Create a normal map from a heightmap *)

let get_height col =
	let (r,g,b) = col#get_rgb in
	(0.3*.r)+.(0.59*.g)+.(0.11*.b)

let normalmap i =
let out = i in
	for x=0 to i#width-2 do
	for y=0 to i#height-2 do
		let (p,px,py)=(i#get_pixel x y,
			       i#get_pixel (x+1) y,
			       i#get_pixel x (y+1)) in
		let (h,hx,hy)=(get_height p, get_height px, get_height py) in
			let v = new BasicTypes.vector3 in
				v#set_xyz ((hx-.h),1.,(hy-.h));
				v#make_uniform;
				let col = new BasicTypes.color in
				col#set_rgb_pck (v#get_xyz);
				out#set_pixel col x y
	done
	done;
	let x = i#width-1 in
	for y=0 to i#height-2 do
		let (p,px)=(i#get_pixel x y,
			    i#get_pixel (x+1) y) in
		let (h,hx)=(get_height p, get_height px) in
			let v = new BasicTypes.vector3 in
				v#set_xyz ((hx-.h),1.,0.);
				v#make_uniform;
				let col = new BasicTypes.color in
				col#set_rgb_pck (v#get_xyz);
				out#set_pixel col x y
	done;
	for x=0 to  i#width-2 do
	let y = i#height-1 in
		let (p,py)=(i#get_pixel x y,
			    i#get_pixel x (y+1)) in
		let (h,hy)=(get_height p, get_height py) in
			let v = new BasicTypes.vector3 in
				v#set_xyz (0.,1.,(hy-.h));
				v#make_uniform;
				let col = new BasicTypes.color in
				col#set_rgb_pck (v#get_xyz);
				out#set_pixel col x y
	done;
out

(* Return the height map in Black and white*)

let apply_height (c:BasicTypes.color list) (f:float list) (i:BasicTypes.image) =
	let rec set_height (cl:BasicTypes.color list) (hl:float list) (color_in:BasicTypes.color) =
	 	match (cl,hl) with
			|([],[]) -> new BasicTypes.color
			|([], _) -> new BasicTypes.color
			|(_, []) -> new BasicTypes.color
			|(col::cl, h::hl) ->
				if color_in#equal col then
					let result = new BasicTypes.color in
					result#set_rgb h h h;
					result
				else
					set_height cl hl color_in
	in
	i#foreach_pixel (set_height c f);;

(* Get Image Color *)

let rec is_not_in_list cl (c: BasicTypes.color) =
	let rec call = function
	    | [] -> true
	    | e::l when (c#equal e) -> false
	    | e::l -> call l
	in
	call !cl;;
 let get_image_colors (i:BasicTypes.image) =
	let colorlist = ref ([]:BasicTypes.color list) in
	let f1 = is_not_in_list colorlist in
	let _ = 
		i#foreach_tested_pixel f1
		(fun (c:BasicTypes.color) -> colorlist := c::!colorlist ; c)
	in !colorlist;;


(* Tesselate an HeightMap *)
let tesselate (hm:BasicTypes.image) (meshmap) = 
	begin
	outlines hm;
	let div2 = div_two hm in 
	let div4 = div_two div2 in 
	let div8 = div_two div4 in 
	let div16 = div_two div8 in
	let div32 = div_two div16 in 
	let div64 = div_two div32 in
	let div128 = div_two div64 in
	let div256 = div_two div128 in
	meshmap#apply_subdivision 256 div256;
	meshmap#apply_subdivision 128 div128;
	meshmap#apply_subdivision 64 div64;
	meshmap#apply_subdivision 32 div32;
	meshmap#apply_subdivision 16 div16;
	meshmap#apply_subdivision 8 div8;
	end

