class vector3 = object (self)
	val mutable x = 0.0
	val mutable y = 0.0
	val mutable z = 0.0
	method get_x = x;
	method get_y = y;
	method get_z = z;
	method get_xyz = (x,y,z);
	method set_xyz (vx,vy,vz) = 
		x <- vx;
		y <- vy;
		z <- vz;
	method length = 
		sqrt(x*.x +. y*.y +. z*.z);
	method reverse = 
		x <- 0.0 -. x;
		x <- 0.0 -. y;
		x <- 0.0 -. z;

	method dot (v:vector3)=
		x*.v#get_x +. y*.v#get_y +. z*.v#get_z;
	method cross (v:vector3)=
		x <- y*.v#get_z -. z*.v#get_y ;
		y <- z*.v#get_x -. x*.v#get_z ;
		z <- x*.v#get_y -. y*.v#get_x ;


	method normalize =
		let l = self#length in
			if l = 0.0 then
				begin
					x <- 0.0;
					y <- 0.0;
					z <- 0.0;
				end
			else
				begin
					x <- x /. l;
					y <- y /. l;
					z <- z /. l;
				end

	method make_uniform =
		self#normalize;
		x <- (x *. 0.5) +. 0.5;
		y <- (y *. 0.5) +. 0.5; 
		z <- (z *. 0.5) +. 0.5;
end;;

class color =
   object (self)
	val mutable r = 0.0
	val mutable g = 0.0
	val mutable b = 0.0
	val mutable a = 1.0
	method get_r = r;
	method get_g = g;
	method get_b = b;
	method get_a = a;
	method get_sum = r+.g+.b;
	method get_sum_rgba = r+.g+.b+.a;
	method get_sum_rgb = r+.g+.b;
	method get_sum_rg = r+.g;
	method get_sum_rb = r+.b;
	method get_sum_gb = g+.b;
	method get_r_int = int_of_float(r *. 255.0);
	method get_g_int = int_of_float(g *. 255.0);
	method get_b_int = int_of_float(b *. 255.0);
	method get_a_int = int_of_float(a *. 255.0);

	method get_rgba = (r,g,b,a);
	method get_rgb = (r,g,b);
	method get_rgba_byte = (
		int_of_float(r*.255.0),
		int_of_float(g*.255.0),
		int_of_float(b*.255.0),
		int_of_float(a*.255.0));
	method get_rgb_byte = (
		int_of_float(r*.255.0),
		int_of_float(g*.255.0),
		int_of_float(b*.255.0));
	method set_rgba_pck (_r,_g,_b,_a) = 
		r<-_r;
		g<-_g;
		b<-_b;
		a<-_a;
	method set_rgb_pck (_r,_g,_b) = 
		r<-_r;
		g<-_g;
		b<-_b;
	method set_rgba_pck_byte (_r,_g,_b,_a) = 
		r<-float_of_int(_r)/.255.0;
		g<-float_of_int(_g)/.255.0;
		b<-float_of_int(_b)/.255.0;
		a<-float_of_int(_a)/.255.0;
	method set_rgb_pck_byte (_r,_g,_b) = 
		r<-float_of_int(_r)/.255.0;
		g<-float_of_int(_g)/.255.0;
		b<-float_of_int(_b)/.255.0;
	method set_r value = r <- value;
	method set_g value = g <- value;
	method set_b value = b <- value;
	method set_a value = a <- value;

	method set_r_int value = r <- float_of_int(value) /. 255.0;
	method set_g_int value = g <- float_of_int(value) /. 255.0;
	method set_b_int value = b <- float_of_int(value) /. 255.0;
	method set_a_int value = a <- float_of_int(value) /. 255.0;

	method set_rgb red green blue = 
		r <- red;
		g <- green; 
		b <- blue; 
	method set_rgba red green blue alpha = 
		self#set_rgb red green blue;
		a <- alpha;

	method set_rgb_int red green blue = 
		r <- (float_of_int red) /. 255.0;
		g <- (float_of_int green) /. 255.0; 
		b <- (float_of_int blue) /. 255.0;

	method set_rgba_int red green blue alpha= 
		self#set_rgb_int red green blue;
		a <- (float_of_int alpha) /. 255.0; 

	method set_rgb_byte red green blue = 
		self#set_rgb_int 
			(int_of_char red)
			(int_of_char green)
			(int_of_char blue);

	method set_rgba_byte red green blue alpha = 
		self#set_rgb_byte red green blue;
		a <- (float_of_int (int_of_char alpha)) /. 255.0; 
	method to_list_rgba = 
		[r;g;b;a]
	method to_list_bgra = 
		[b;g;r;a]
	method to_list_rgb = 
		[r;g;b]
	method to_list_bgr = 
		[b;g;r]
	method to_array_rgba = 
		[|r;g;b;a|]
	method to_array_bgra = 
		[|b;g;r;a|]
	method to_array_rgb = 
		[|r;g;b|]
	method to_array_bgr = 
		[|b;g;r|]
	method add (c:color) =
		r <- r +. c#get_r;
		g <- g +. c#get_g;
		b <- b +. c#get_b;
		a <- a +. c#get_a;
		if r > 1.0 then r <- 1.0;
		if g > 1.0 then g <- 1.0;
		if b > 1.0 then b <- 1.0;
		if a > 1.0 then a <- 1.0;

	method mul (c:color) =
		r <- r *. c#get_r;
		g <- g *. c#get_g;
		b <- b *. c#get_b;
		a <- a *. c#get_a;

	method mul_cst (f:float) =
		r <- r *. f;
		g <- g *. f;
		b <- b *. f;
		a <- a *. f;

	method merge (c:color) = 
		r <- (c#get_r +. r) /. 2.0;
		g <- (c#get_g +. g) /. 2.0;
		b <- (c#get_b +. b) /. 2.0;
		a <- (c#get_a +. a) /. 2.0;

	method equal (c:color) = 
		(r = (c#get_r;) && g = (c#get_g;) && b = (c#get_b;) && a = (c#get_a;));
	method notequal (c:color) = 
		(r <> c#get_r || g <> c#get_g || b <> c#get_b || a <> c#get_a);
	method to_int32 = Int32.of_int( 
		int_of_float(r) +
		int_of_float(g) * 255 +
		int_of_float(b) * 255 * 255 +
		int_of_float(a) * 255 * 255 * 255);
	method is_white =
		(r > 0.8 && g > 0.8 && b > 0.8);
	method to_string =
		string_of_float(r) ^ " " ^ string_of_float(g) ^ " " ^ string_of_float(b) ^ " " ^ string_of_float(a);
end;;



class file_in (f:string) = 
   object(self)
	val mutable filestream = open_in_bin f;
	method read_byte = input_byte filestream;

	method read_n_byte = function
		|0 -> []
		|n -> self#read_byte::(self#read_n_byte (n-1));

	method read_char = char_of_int(input_byte filestream);

	method read_line = input_line filestream;

	method close = close_in filestream;

	method read_n_char = function
		|0 -> []
		|n -> self#read_char::(self#read_n_char (n-1));
	method read_int = 
		let a0 = self#read_byte in
		let a1 = self#read_byte in
		let a2 = self#read_byte in
		let a3 = self#read_byte in
		a0 + a1 * 256 + a2 * 256 * 256 + a3 * 256 * 256 * 256;

	method read_color_rgba =
		let c = new color in
		let r = self#read_byte in
		let g = self#read_byte in
		let b = self#read_byte in
		let a = self#read_byte in
		c#set_rgba_int r g b a;
		c;
	method read_color_rgb = 
		let c = new color in
		let r = self#read_byte in
		let g = self#read_byte in
		let b = self#read_byte in
		c#set_rgb_int r g b;
		c;
	method get_pos = pos_in filestream;
        method seek_pos p = seek_in filestream p;
end;;

class file_out (f:string) =
	object(self)
	val mutable filestream = open_out_bin f;

	method write_byte byte = output_byte filestream byte; ();
	method write_char chr = output_char filestream chr; ();
	method write_string strng = output_string filestream strng; ();
	method write_color_rgb (c:color) =
		self#write_byte c#get_r_int;
		self#write_byte c#get_g_int;
		self#write_byte c#get_b_int;
	method write_color_bgr (c:color) =
		self#write_byte c#get_b_int;
		self#write_byte c#get_g_int;
		self#write_byte c#get_r_int;
	method write_color_rgba (c:color) =
		self#write_byte c#get_r_int;
		self#write_byte c#get_g_int;
		self#write_byte c#get_b_int;
		self#write_byte c#get_a_int;
	method close = close_out filestream;
end;;

class image (image_width:int) (image_height:int) =
   object(self) 

	val mutable h = image_height;
	val mutable w = image_width;
	val mutable raw_data = Sdlvideo.create_RGB_surface [`SWSURFACE] image_width image_height 32  0x000000FFl  0x0000FF00l 0x00FF0000l  0xFF000000l;
		
	method get_bytes = Sdlgl.to_raw raw_data;
	method get_pixel_at_address (add:int) = 
		let c = new color in
		c#set_rgb_pck_byte((Sdlvideo.get_pixel_color raw_data (add / w) (add mod w)));
		c

	method get_pixel (x:int) (y:int) = 
		let c = new color in
		c#set_rgb_pck_byte((Sdlvideo.get_pixel_color raw_data x y));
		c

	method set_pixel_at_address (c:color) (add:int) =
		Sdlvideo.put_pixel raw_data (add / w) (add mod w) c#to_int32
	method set_pixel (c:color) (x:int) (y:int) =
		Sdlvideo.put_pixel_color raw_data x y c#get_rgb_byte
	method load_file (f:string)= 
		raw_data <- Sdlloader.load_image f;
		w<-(Sdlvideo.surface_info raw_data).Sdlvideo.w;
		h<-(Sdlvideo.surface_info raw_data).Sdlvideo.h;
	method save_file (f:string)= 
		Sdlvideo.save_BMP raw_data f;
	method height = h

	method width = w
	method clone =
		let i = new image w h in
		for x = 0 to h - 1 do
			for y = 0 to w - 1 do
				i#set_pixel (self#get_pixel x y ) x y;
			done;
		done;
		i;
	method merge (i:image) = 
		let minh = min i#height h in
		let minw = min i#width w in
		for x = 0 to minh - 1 do
			for y = 0 to minw - 1 do
				let c = self#get_pixel x y in
				c#merge(i#get_pixel x y);
				self#set_pixel c x y;
			done;
		done;
		;
	method foreach_tested_pixel (test:color->bool) (func:color->color) = 
		for x = 0 to h - 1 do
			for y = 0 to w - 1 do
				if test (self#get_pixel x y) then
				self#set_pixel 
					( func (self#get_pixel x y ) ) x y ;
			done;
		done;
	method foreach_pixel (func:color->color) = 
		for x = 0 to h - 1 do
			for y = 0 to w - 1 do
				self#set_pixel 
					( func (self#get_pixel x y ) ) x y ;
			done;
		done;

	method iter (func:color->unit) = 
		for x = 0 to h - 1 do
			for y = 0 to w - 1 do
				 func (self#get_pixel x y );
			done;
		done;

end;;

