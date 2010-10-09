open BasicTypes


(* This is launch at the beginning *)

let initialize () = ();;


(* Save an image at the specified location *)

let save_image_bmp (i:image) (s:string) = ();;


(* Open a bitmap file and return the image *)

let load_image_bmp (s:string) = 
	let file = new file_in s in
	file#read
;;


(* Save an image at the specified location *)

let save_image_png (i:image) (s:string) = ();;


(* Open a Portable Network Graphics file and return the image *)

let load_image_png (s:string) = open_in s;;
