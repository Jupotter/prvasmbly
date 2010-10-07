class color =
   object (self)
	val mutable r = 0.0
	val mutable g = 0.0
	val mutable b = 0.0
	val mutable a = 1.0
	method set_rgb red green blue = 
		r <- red;
		g <- green; 
		b <- blue; 
	method set_rgba red green blue alpha = 
		self#set_rgb red green blue;
		a <- alpha;
	method to_array_rgba = 
		[r;g;b;a]
	method to_array_bgra = 
		[b;g;r;a]
	method to_array_rgb = 
		[r;g;b]
	method to_array_bgr = 
		[b;g;r]
   end;;	
class file_in (f:string) = 
   object(self)
	val mutable filestream = open_in f;
	method read = input filestream;
   end;;
class image (image_width:int) (image_height:int) =
   object(self) 
	val mutable h = image_height;
	val mutable w = image_width;
	method get_pixel = new color
	method set_pixel (c:color) = h <- h
	method height = h
	method width = w
   end;;

