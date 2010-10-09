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
	method set_r value = r <- value;
	method set_g value = g <- value;
	method set_b value = b <- value;
	method set_a value = a <- value;

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

	method merge (c:color) = 
		self#add c;
		r <- r /. 2.0;
		g <- g /. 2.0;
		b <- b /. 2.0;
		a <- a /. 2.0;

	end;;



class file_in (f:string) = 
   object(self)
	val mutable filestream = open_in_bin f;
	method read_byte = input_byte filestream;
	method read_n_byte = function
		|0 -> []
		|n -> self#read_byte::(self#read_n_byte (n-1));
	method read_char = char_of_int(input_byte filestream);
	method read_n_char = function
		|0 -> []
		|n -> self#read_char::(self#read_n_char (n-1));

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
		
   end;;

class image (image_width:int) (image_height:int) =
   object(self) 

	val mutable h = image_height;
	val mutable w = image_width;
	val mutable raw_data = 
		Array.make (image_height * image_width * 4) 0.0;

	method get_pixel (x:int) (y:int) = 
		let c = new color in
			c#set_rgba 
				raw_data.((y * h + x) * 4)
				raw_data.((y * h + x) * 4 + 1)
				raw_data.((y * h + x) * 4 + 2)
				raw_data.((y * h + x) * 4 + 3);
			c;

	method set_pixel (c:color) (x:int) (y:int) =
		raw_data.((y * h + x) * 4) <- c#get_r;
		raw_data.((y * h + x) * 4 + 1) <- c#get_g;
		raw_data.((y * h + x) * 4 + 2) <- c#get_b;
		raw_data.((y * h + x) * 4 + 3) <- c#get_a;

	method height = h
	method width = w
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
	method foreach_pixel (func:color->color) = 
		for x = 0 to h - 1 do
			for y = 0 to w - 1 do
				self#set_pixel ( func (self#get_pixel x y ) ) x y ;
			done;
		done;

   end;;

