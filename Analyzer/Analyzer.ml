open BasicTypes
(* This is launch at the beginning *)
let initialize () = ();;
(* Return all the colors contained in the image *)
let get_image_colors (i:image) = [new color];;
(* Return the result of (diff_x(i) + diff_y(i))/2 *)
let get_image_diff (i:image) = new image;;
(* Return the result of diff operation on the x axis*)
let get_image_diff_x (i:image) = new image;;
(* Return the result of diff operation on the y axis*)
let get_image_diff_y (i:image) = new image;;
(* Return normalmap matching with the image*)
let get_image_normalmap (i:image) = new image;;
(* Return the height map in Black and white*)
let apply_height (h:float) (c:color) (i:image) = new image;;

