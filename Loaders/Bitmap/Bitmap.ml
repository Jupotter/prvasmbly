open BasicTypes


(* This is launch at the beginning *)

let initialize () = ();;


(* Save an image at the specified location *)

let save_image_bmp (i:image) (s:string) =
	let f = new file_out s in
	let (h,w) = (i#height,i#width) in
	let size = h * w * 4 + 54 in
	let _ =
	begin
	f#write_byte 66;
	f#write_byte 77;
	f#write_byte (size mod 256);
	f#write_byte ((size / 256) mod 256);
	f#write_byte ((size / 256*256) mod(256*256));
	f#write_byte (size / (256*256*256));
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 54;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 40;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte (w mod 256);
	f#write_byte ((h / 256) mod 256);
	f#write_byte ((h / 256*256) mod(256*256));
	f#write_byte (h / (256*256*256));
	f#write_byte (h mod 256);
	f#write_byte ((w / 256) mod 256);
	f#write_byte ((w / 256*256) mod(256*256));
	f#write_byte (w / (256*256*256));
	f#write_byte 1;
	f#write_byte 0;
	f#write_byte 32;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte ((size mod 256)-54);
	f#write_byte ((size mod 256) /256);
	f#write_byte ((size mod 256*256) /(256*256));
	f#write_byte (size / (256*256*256));
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	f#write_byte 0;
	end in
        let _ = for k = h-1 downto 0 do
                for j = 0 to w-1 do
			f#write_color_rgb (i#get_pixel j k);
			f#write_byte 0
                done
	done
	in ();;

type bmp_header = {
        fsize : int;
	startpos : int;
        width : int;
        height : int;
        depth : int;
        compress : int;
	isize : int;
        mapsize : int}

let load_bmp_header (f:file_in) =
        let size = f#read_int in
        let _ = f#read_int in
        let startpos = f #read_int in
        let _ = f#read_n_byte 4 in
        let width = f#read_int in
        let height = f#read_int in
        let depth = (f#read_int)/(256*256)  in
        let compress = f#read_int in
        let isize = f#read_int in
        let _ = f#read_n_byte 8 in
        let mapsize = f#read_int in
        let _ = f#read_n_byte 4 in
        let header =
		{fsize = size;
		startpos = startpos;
                width = width;
                height = height;
                depth = depth;
		compress = compress;
		isize = isize;
		mapsize = mapsize;}
		in header;;


(* Open a bitmap file and return the image *)
let read_bmp_32 (f:file_in) head =
	let (h,w,p) =  (head.height,
			head.width,
			head.startpos) in
        let image = new image h w in
        let _ = f#seek_pos p in
        let _ = print_int (f#get_pos ) in
        let _ = for i = h-1 downto 0 do
                for j = 0 to w-1 do
                        let col = f#read_color_rgb in
			let _ = f#read_byte in
                                begin
                                (*print_int i; print_string ", ";
                                print_int j; print_newline ();*)
                                image#set_pixel col j i;
                                end
                done
        done
        in image;;

let read_bmp_24 (f:file_in) head =
	let (h,w,p) =  (head.height,
			head.width,
			head.startpos) in
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
		let max = if (w/4*4 = w)
			then w-1
			else ((3*w/4+1)*4)-1
			in
                for j = w*3 to max do
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
                (*let size = file#read_int in
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
                let _ = file#read_n_byte 4 in*)
                (*let _ = print_int depth ;print_newline in*)
		let head = load_bmp_header file in
                begin
                match head.depth with
                |24 -> read_bmp_24 file head
                |32 -> read_bmp_32 file head
                |_ -> raise (Invalid_argument "Unimplemented Color Depth")
                end
        |_->
                raise (Invalid_argument (s));;


(* Save an image at the specified location *)

let save_image_png (i:image) (s:string) = ();;


(* Open a Portable Network Graphics file and return the image *)

let load_image_png (s:string) = open_in s;;
