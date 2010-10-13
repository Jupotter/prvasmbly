open BasicTypes

(* This is launch at the beginning *)
let initialize () = ();;
(* Return all the colors contained in the image *)
let get_image_colors (i:image) = ();;
(* Return the result of (diff_x(i) + diff_y(i))/2 *)
let get_image_diff (i:image) = new image;;
(* Return the result of diff operation on the x axis*)
let get_image_diff_x (i:image) = new image;;
(* Return the result of diff operation on the y axis*)
let get_image_diff_y (i:image) = new image;;
(* Return normalmap matching with the image*)
let get_image_normalmap (i:image) = new image;;
(* Return the height map in Black and white*)
let apply_height (h:float) (c:color list) (f:float list) (i:image) = 
	let rec set_height (cl:color list) (hl:float list) (color_in:color) =
	 	match (cl,hl) with
			|([],[]) -> new color
			|([], _) -> new color
			|(_, []) -> new color
			|(col::cl, h::hl) -> 
				if color_in#equal col then
					let result = new color in
					result#set_rgb h h h;
					result
				else
					set_height cl hl color_in
	in
	i#foreach_pixel (set_height c f);;

