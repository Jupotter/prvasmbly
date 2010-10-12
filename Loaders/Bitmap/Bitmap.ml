open BasicTypes


(* This is launch at the beginning *)

let initialize () = ();;


(* Save an image at the specified location *)

let save_image_bmp (i:image) (s:string) = ();;

(*(*tuple used to store the header of a bmp file*)

type bmp_header = {
        fsize : int;
        width : int;
        height : int;
        depth : int;
        compress : int;
        mapsize : int}

let load_bmp_header (f:file_in) = 
        let size = file#sum_n_byte 4 in
        let _ = file#read_n_byte 14 in
        let width = file#sum_n_byte 4 in
        let height = file#sum_n_byte 4 in
        let _ = file#read_n_byte 2 in
        let depth = file#sum_n_byte 2 in
        let compress = file#sum_n_byte 4 in
        let isize = file#sum_n_byte 4 in
        let _ = file#read_n_byte 8 in
        let mapsize = file#sum_n_byte 4 in
        let _ = file#read_n_byte 4 in
                {fsize = size;
                width = width;
                height = height;
                depth = depth;*)


(* Open a bitmap file and return the image *)
let read_bmp_32 (f:file_in) h w p = 
        let image = new image h w in
        let _ = f#seek_pos p in 
        let _ = print_int (f#get_pos ) in
        let _ = for i = h-1 downto 0 do
                for j = 0 to w-1 do
			let _ = f#read_byte in
                        let col = f#read_color_rgba in
                                begin
                                (*print_int i; print_string ", ";
                                print_int j; print_newline ();*)
                                image#set_pixel col j i;
                                end
                done
        done
        in image;;

let read_bmp_24 (f:file_in) h w p =
        let image = new image h w in
        let _ = f#seek_pos p in
        let _ = for i = h-1 downto 0 do
                begin
                for j = 0 to w-1 do
                        let col = f#read_color_rgb in
                                begin
                                (*print_int (f#get_pos); print_string ", ";
                                print_int i; print_string ", ";
                                print_int j; print_newline ();*)
                                image#set_pixel col j i;
                                end
                done;
                for j = w*3 to ((3*w/4+1)*4)-1 do
                        let _ = f#read_byte in
			();
                done
                end
        done
        in image;;

let load_image_bmp (s:string) = 
	let file = new file_in s in
        let ident = file#read_n_char 2 in
        match ident with
        'M'::'B'::_ ->
                let size = file#read_int in
                let _ = file#read_int in
                let startpos = file #read_int in
                let _ = file#read_n_byte 4 in
                let width = file#read_int in
                let height = file#read_int in
                let depth = (file#read_int)/(256*256)  in
                let compress = file#read_int in
                let isize = file#read_int in
                let _ = file#read_n_byte 8 in
                let mapsize = file#read_int in
                let _ = file#read_n_byte 4 in
                (*let _ = print_int depth ;print_newline in*)
                begin 
                match depth with 
                |24 -> read_bmp_24 file height width startpos
                |32 -> read_bmp_32 file height width startpos
                |_ -> raise (Invalid_argument "Unimplemented Depth")
                end
        |_->
                raise (Invalid_argument (s));;
                

(* Save an image at the specified location *)

let save_image_png (i:image) (s:string) = ();; 


(* Open a Portable Network Graphics file and return the image *)

let load_image_png (s:string) = open_in s;;
