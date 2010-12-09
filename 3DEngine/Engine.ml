class camera = object(self)
		val mutable _x = 0.0
		val mutable _y = 9.0
		val mutable _z = -5.0
		val mutable lck_x = 0.0
		val mutable lck_y = 0.1
		val mutable lck_z = 5.0


		method move (mx,my,mz) = 
			_x<-_x+.mx;
			_y<-_y+.my;
			_z<-_z+.mz;
			lck_x<-lck_x+.mx;
			lck_y<-lck_y+.my;
			lck_z<-lck_z+.mz;
		method set_position (x,y,z) = 
			_x <- x;
			_y <- y;
			_z <- z;
		method move_forward (factor:float) =
			let vectx = (lck_x -. _x) in
			let vecty = (lck_y -. _y) in
			let vectz = (lck_z -. _z) in
			let norm = sqrt( vectx *. vectx +. vecty *. vecty +. vectz *. vectz) in
			self#move((vectx /. norm), (vecty /. norm),(vectz /. norm));
		method move_backward (factor:float) =
			let vectx = (lck_x -. _x) in
			let vecty = (lck_y -. _y) in
			let vectz = (lck_z -. _z) in
			let norm = sqrt( vectx *. vectx +. vecty *. vecty +. vectz *. vectz) in
			self#move(0.0-.(vectx /. norm), 0.0-.(vecty /. norm),0.0-.(vectz /. norm));
		method set_lookat (x,y,z) = 
			lck_x <- x;
			lck_y <- y;
			lck_z <- z;
		method draw = 
			GlMat.mode `projection;
			GlMat.load_identity();
			GluMat.perspective 
				~fovy:60.0
 				~aspect:(640.0/.480.0)
				~z:(0.01, 90.0)
				;
			GluMat.look_at 
				~center:(lck_x, lck_y, lck_z)
 				~eye:(_x,_y,_z)
 				~up:(0.0,1.0,0.0)
				;
			GlMat.mode `modelview;
			GlMat.load_identity();
end;;

class vertex = 
	object(self)
		val mutable x = 0.0
		val mutable y = 0.0
		val mutable z = 0.0
		val mutable c = new BasicTypes.color;
		method draw = 
			GlDraw.color c#get_rgb;
			GlDraw.vertex3 (x, y, z);
		method get_x = x;
		method get_y = y;
		method get_z = z;
		method get_xyz = (x,y,z);
		method test_mirror (scale:int) (img:BasicTypes.image) = 
			(img#get_pixel (int_of_float(x) / scale) (int_of_float(z) / scale))#is_white;
		method apply_height (img:BasicTypes.image) =
			y <- (img#get_pixel (int_of_float x) (int_of_float (y +. z)) )#get_sum_rg;
		method apply_color (img:BasicTypes.image) =
			c <- (img#get_pixel (int_of_float x) (int_of_float (y +. z)) );
		method apply_lightmap (img:BasicTypes.image) =
			c#mul (img#get_pixel (int_of_float x) (int_of_float (y +. z)) );
		method test_subdivision (scale:int) (img:BasicTypes.image) =
			(img#get_pixel (int_of_float(x) / scale) (int_of_float(z) / scale))#is_white;
		method move (mx,my,mz) = 
			x<-x+.mx;
			y<-y+.my;
			z<-z+.mz;

		(*used by mesh to save a polygon*)
		(*useless outside a mesh*)
		method to_string = 
			"v " ^ string_of_float(x) ^ " " ^
			string_of_float(y) ^ " " ^
			string_of_float(z) ^ "\n";

		method set_x value = x <- value;
		method set_y value = y <- value;
		method set_z value = z <- value;
		method set_xyz (x_value, y_value, z_value) = 
			x <- x_value;
			y <- y_value;
			z <- z_value;
		method map func = 
			x <- func x;
			y <- func y;
			z <- func z;
		method iter (func:(float -> unit)) =
			begin
			func x;
			func y;
			func z;
			end
		method clone = 
			let v = new vertex in 
			v#set_xyz (x,y,z);
			v;
		method flatten =
			y <- 0.0;
end;;

(*create a polygon*)
class polygon = object(self)
	val mutable v1 = new vertex;
	val mutable v2 = new vertex;
	val mutable v3 = new vertex;
	method flatten = 
		v1#flatten;
		v2#flatten;
		v3#flatten;
	method apply_height (img:BasicTypes.image) =
		v1#apply_height img;
		v2#apply_height img;
		v3#apply_height img;
	method apply_color (img:BasicTypes.image) =
		v1#apply_color img;
		v2#apply_color img;
		v3#apply_color img;
	method apply_lightmap (img:BasicTypes.image) =
		v1#apply_lightmap img;
		v2#apply_lightmap img;
		v3#apply_lightmap img;
	method apply_mirror (scale:int) (img:BasicTypes.image) =
			if(v2#test_mirror scale img) ||
			(v3#test_mirror scale img) then
			begin
				v1 <- new vertex;
				v2 <- new vertex;
				v3 <- new vertex;
			end
			else
			begin
				();
			end
		
	method set_vertex_1 value = v1 <- value; 
	method set_vertex_2 value = v2 <- value; 
	method set_vertex_3 value = v3 <- value; 
	method set_vertices (vert1,vert2,vert3) = 
		v1 <- vert1;
		v2 <- vert2;
		v3 <- vert3;
	method get_vertex_1 = v1; 
	method get_vertex_2 = v2; 
	method get_vertex_3 = v3;
	method get_vertices = (v1,v2,v3);
	(*used by mesh to save a polygon*)
	(*do not use outside a mesh*)
	method save_vertices (file:BasicTypes.file_out) =
		file#write_string (v1#to_string);
		file#write_string (v2#to_string);
		file#write_string (v3#to_string);
	(*used by mesh to save a polygon*)
	(*do not use outside a mesh*)
	method save_face off_set (file:BasicTypes.file_out) =
		file#write_string 
			("f " ^ string_of_int(!off_set) ^
			" " ^ string_of_int(!off_set + 1) ^
			" " ^ string_of_int(!off_set + 2) ^
			"\n");
		off_set := (!off_set) + 3;

	(*create a uniform polygon with the specified size*)
	method uniform size= 
		v2#move(size,0.0,0.0);
		v3#move(0.0,0.0,size);
	(*create a uniform polygon with the specified size*)
	(*and reverse the vertex 0*)
	method reverse_uniform size = 
		v2#move(0.0,0.0,size);
		v3#move(size,0.0,0.0);
		v1#move(size,0.0,size);
	method move (mx,my,mz) = 
		v1#move(mx,my,mz);
		v2#move(mx,my,mz);
		v3#move(mx,my,mz);
	method map  func = 
		v1 <- func v1;
		v2 <- func v2;
		v3 <- func v3;
	method iter (func:(vertex -> unit)) =
		func v1;
		func v2;
		func v3;
	method draw = 
		v1#draw;
		v2#draw;
		v3#draw;
	method clone = 
		let p = new polygon in 
		p#set_vertices (v1#clone,v2#clone,v3#clone);
		p;
	method reverse = 
		v1#set_x ( v2#get_x );
		v1#set_z ( v3#get_z );
	method subdivide = 
		let sv1 = new vertex in
		sv1#set_xyz(
			(v2#get_x +. v1#get_x)/.2.0,
			(v2#get_y +. v1#get_y)/.2.0,
			(v2#get_z +. v1#get_z)/.2.0);
		let sv2 = new vertex in
		sv2#set_xyz(
			(v3#get_x +. v1#get_x)/.2.0,
			(v3#get_y +. v1#get_y)/.2.0,
			(v3#get_z +. v1#get_z)/.2.0);
		let sv3 = new vertex in
		sv3#set_xyz(
			(v3#get_x +. v2#get_x)/.2.0,
			(v3#get_y +. v2#get_y)/.2.0,
			(v3#get_z +. v2#get_z)/.2.0);
		let p1 = new polygon in
		p1#set_vertices(v1, sv1, sv2);
		let p2 = new polygon in
		p2#set_vertices(sv1, v2, sv3);
		let p3 = new polygon in
		p3#set_vertices (sv2,v3,sv3);
		let p4 = new polygon in
		p4#set_vertices (sv1,sv2,sv3);
		p1::p2::p3::p4::[];

	method apply_subdivision (scale:int) (img:BasicTypes.image) =
			if ((v1#test_subdivision scale img) ||
			(v2#test_subdivision scale img) ||
			(v3#test_subdivision scale img)) then
			begin
				self#subdivide;
			end
			else
			begin
				let p = new polygon in
				p#set_vertices(v1,v2,v3);
				p::[];
			end
		
end;;


class box = object(self)
	val mutable sx = 0.0;
	val mutable sy = 0.0;
	val mutable ex = 0.5;
	val mutable ey = 0.5;
	val mutable visible = true;
	val mutable start_color = new BasicTypes.color;
	val mutable end_color = new BasicTypes.color;
	method get_position = (sx,sy);
	method get_size = (ex, ey);
	method hide = visible <- false;
	method show = visible <- true;
	method toggle_visibility =
		visible <- (if visible then false else true);
	method set_position (x,y) =
		sx <- x;
		sy <- y;
	method set_size (x,y) =
		ex <- x;
		ey <- y;
	method move (x,y) =
		sx <- sx +. x;
		sy <- sy +. y;
	method set_start_color c = start_color <- c;
	method set_start_color_rgb (r,g,b) = start_color#set_rgb_pck (r,g,b);
	method set_start_color_rgba (r,g,b,a) = start_color#set_rgba_pck (r,g,b,a);
	method set_end_color c = end_color <- c;
	method set_end_color_rgb (r,g,b) = end_color#set_rgb_pck (r,g,b);
	method set_end_color_rgba (r,g,b,a) = end_color#set_rgba_pck (r,g,b,a);
	method draw = 
			if visible then
			begin
			GlMat.push();
			GlMat.translate ~x:sy ~y:sx ~z:0.0 ();
			GlMat.scale ~x:ex ~y:ey ~z:1.0 ();
			GlDraw.begins `triangles;
				GlDraw.color ~alpha:start_color#get_a start_color#get_rgb;
				GlDraw.vertex3 (0.0, 0.0, 0.0);
				GlDraw.vertex3 (1.0, 0.0, 0.0);
				GlDraw.color ~alpha:end_color#get_a end_color#get_rgb;
				GlDraw.vertex3 (1.0, 1.0, 0.0);

				GlDraw.vertex3 (1.0, 1.0, 0.0);
				GlDraw.vertex3 (0.0, 1.0, 0.0);
				GlDraw.color ~alpha:start_color#get_a start_color#get_rgb;
				GlDraw.vertex3 (0.0, 0.0, 0.0);

			GlDraw.ends();
			GlMat.pop();
			end
			else ();
end;;
(* create a mesh *)
class mesh = object(self)
	val mutable plg_list = ([]:polygon list)
	val mutable working_list = ([]:polygon list)
	val mutable _locked = false
	val mutable x = 0.0
	val mutable y = 0.0
	val mutable z = 0.0
	val mutable sx = 0.1
	val mutable sy = 10.0
	val mutable sz = 0.1
	val mutable gllist = 
		let ls = (GlList.create `compile) in
		GlList.ends();
		ls;
	method get_polygons = plg_list;
	method merge (m:mesh) =
		plg_list<-plg_list@m#get_polygons;
	
	(*create a grild with the specified size*)
	(* step represent the resolution  and must be lower than scale *)
	method add_grild position_x position_z step scale_x scale_z =
		let sxf = float_of_int(step) in
		for x = 0 to (scale_x / step) do
			for y = 0 to (scale_z / step) do
				let plg1 = new polygon in
				plg1#uniform sxf;
				plg1#move(float_of_int(x * step + position_x), 0.0, float_of_int(y * step + position_z));
				let plg2 = new polygon in
				plg2#reverse_uniform sxf;
				plg2#move(float_of_int(x * step + position_x), 0.0, float_of_int(y * step + position_z));
				plg_list<-(plg1#subdivide)@plg_list;
				plg_list<-(plg2#subdivide)@plg_list;
			done;
		done;
	method add_square position_x position_z size =
		let sxf = float_of_int(size) in
		let plg1 = new polygon in
				plg1#uniform sxf;
				plg1#move(float_of_int(position_x), 0.0, float_of_int(position_z));
				let plg2 = new polygon in
				plg2#reverse_uniform sxf;
				plg2#move(float_of_int(position_x), 0.0, float_of_int(position_z));


	method get_position = (x,y,z);
	method get_scale = (sx,sy,sz);
	method set_position (vx,vy,vz) = 
		x <- vx;
		y <- vy;
		z <- vz;
	method set_scale (vx,vy,vz) = 
		sx <- vx;
		sy <- vy;
		sz <- vz;
	method move (mx,my,mz) = 
		x<-x+.mx;
		y<-y+.my;
		z<-z+.mz;

	method add_polygon plg = plg_list <- plg::plg_list;
 	method add_polygon_list = function
		|[] -> ()
		|e::t -> 
			begin
				plg_list <- e::plg_list;
				self#add_polygon_list t;
			end

	method map func = plg_list <- List.map func plg_list;
	method iter func = List.iter func plg_list;
	(*save the mesh into an obj file*)
	method save file = 
		let ot = new BasicTypes.file_out file in
		let off_set = ref 1 in
		self#iter (fun (p:polygon) -> (p#save_vertices ot));
		self#iter (fun (p:polygon) -> p#save_face off_set ot);
		ot#close;
		();
	method draw = 
		

		if _locked then
			begin
			GlMat.push();
			GlMat.load_identity();
			GlMat.scale ~x:sx ~y:sy ~z:sz ();
			GlMat.translate ~x:x ~y:y ~z:z ();
			GlList.call gllist;
			GlMat.pop();
			end
		else
			begin
			GlMat.push();
			GlMat.load_identity();
			GlMat.scale ~x:sx ~y:sy ~z:sz ();
			GlMat.translate ~x:x ~y:y ~z:z ();
			
			GlDraw.begins `triangles;
				let drawplg (plg:polygon) = plg#draw; in
				List.iter drawplg plg_list;
			GlDraw.ends();
			GlMat.pop();
			end
			
	method apply_height (img:BasicTypes.image) =
		let app_plg (p:polygon) = p#apply_height img in
		self#iter app_plg; 
	method apply_lightmap (img:BasicTypes.image) =
		let app_plg (p:polygon) = p#apply_lightmap img in
		self#iter app_plg; 
	method apply_color (img:BasicTypes.image) =
		let app_plg (p:polygon) = p#apply_color img in
		self#iter app_plg;	
	method flatten = 
		let rec flat = function
			|[] -> ()
			|e::l -> e#flatten
		in
		flat plg_list;

	method apply_subdivision (scale:int) (img:BasicTypes.image) =
		
		working_list <- [];
		let app_plg (p:polygon) = working_list <- (p#apply_subdivision scale img)@working_list; in
		self#iter app_plg;
		plg_list <- working_list;
	method apply_mirror (scale:int) (img:BasicTypes.image) =
		let app_plg (p:polygon) = p#apply_mirror scale img in
		self#iter app_plg;			
	(*optimize and create a GL list with the mesh*)	
	(*NOT YET TESTED ! DO NOT USE*)	
	method lock =
		gllist <- GlList.create `compile;
		GlDraw.begins `triangles;
			let drawplg (plg:polygon) = plg#draw; in
			List.iter drawplg plg_list;
		GlDraw.ends();
		GlList.ends();
		_locked <- true;
	method tesselate (img:BasicTypes.image) = 
		Analyzer.tesselate img self;
	
	method create_map (img:BasicTypes.image) (c:BasicTypes.color list) (f:float list) =
		plg_list <- [];
		self#add_grild 0 0 256 (img#width - 1) (img#height - 1);
		let colorblur = img#clone in
		self#tesselate colorblur#clone;
		
		Analyzer.blur colorblur;
		self#apply_color (colorblur);
		Analyzer.apply_height c f img;
		Analyzer.blur img;
		self#apply_height (img);
end;;


let create_grild size_x size_y step = 
	let m = new mesh in
	m#add_grild 0 0 step size_x size_y;
	m

(* create a texture *)
(* Note the image must be duplicated in order to prevent conflict*)
class texture (i:BasicTypes.image) = 
	object(self)

		(*create the openGL texture using an image*)
		val mutable id = 
				let localid = GlTex.gen_texture() in 
				GlTex.bind_texture `texture_2d localid;
				GlTex.image2d ~border:false
					(
					GlPix.of_raw i#get_bytes
					~format:`rgba
					~width: (i#width)
					~height: (i#height)
					);
				List.iter (GlTex.parameter ~target:`texture_2d)
					[ `wrap_s `clamp;
					  `wrap_t `clamp;
					  `mag_filter `linear;
					  `min_filter `linear ];

				localid;

		(* must be call to apply this texture to a polygon*)
		method draw =
			GlTex.bind_texture `texture_2d id;
			Gl.enable `texture_2d;
			GlTex.env (`mode`replace);

		(* must be call after EACH draw !!*)
		method end_draw =
			GlTex.env (`mode`replace);
			Gl.disable `texture_2d;
		

end;;

(* create a sprite *)
(* Note the image must be duplicated in order to prevent conflict*)
class sprite (i:BasicTypes.image)= object(self)
	val mutable texture = new texture i;
	val mutable sx = 0.0;
	val mutable sy = 0.0;
	val mutable ex = 1.0;
	val mutable ey = 1.0;
	val mutable _on_click = (fun _ -> (););
	val mutable _on_click_ref = ref (fun (_:unit) -> (););
	val mutable visible = true;
	method get_position = (sx,sy);
	method get_size = (ex, ey);
	method set_position (x,y) =
		sx <- x;
		sy <- y;
	method set_size (x,y) =
		ex <- x;
		ey <- y;
	method move (x,y) =
		sx <- sx +. x;
		sy <- sy +. y;
	method set_on_click func = _on_click <- func;
	method set_on_click_ref func = _on_click_ref <- func;
	method hide = visible <- false;
	method show = visible <- true;
	method raise ()=
		_on_click();
		(!_on_click_ref)();
		();
	method toggle_visibility = visible <- if(visible) then false else true;
	(* method used by the window *)
	method click (x,y) = 
		if  (visible && ( sx <= x && sy <= y  && x <= (sx +. ex) && y <= (sy +. ey) ) ) then self#raise();
	method draw = 
			if visible then
			begin
			GlMat.push();
			GlMat.translate ~x:sx ~y:sy ~z:0.0 ();
			GlMat.scale ~x:ex ~y:ey ~z:1.0 ();

			texture#draw;
			GlDraw.begins `triangles;
				GlDraw.color ~alpha:0.0 (0.0,0.0,1.0);
				GlTex.coord2 (0.0, 0.0);
				GlDraw.vertex3 (0.0, 0.0, 0.0);
				GlTex.coord2 (1.0, 0.0);
				GlDraw.vertex3 (1.0, 0.0, 0.0);
				GlTex.coord2 (1.0, 1.0);
				GlDraw.vertex3 (1.0, 1.0, 0.0);

				GlTex.coord2 (1.0, 1.0);
				GlDraw.vertex3 (1.0, 1.0, 0.0);
				GlTex.coord2 (0.0, 0.0);
				GlDraw.vertex3 (0.0, 0.0, 0.0);
				GlTex.coord2 (0.0, 1.0);
				GlDraw.vertex3 (0.0, 1.0, 0.0);
			GlDraw.ends();
			texture#end_draw;
			GlMat.pop();
			end
			else
				();
end;;


class display = 
	object(self)
		val mutable _mesh_list = ([]:mesh list)
		val mutable _sprite_list = ([]:sprite list)
		val mutable _box_list = ([]:box list)
		val mutable _mx = 0
		val mutable _my = 0
		val mutable _w = 640.0
		val mutable _h = 480.0
		val mutable _bgcolor = new BasicTypes.color;
		val mutable _wireframe = false;
		val mutable moving_up = false;
		val mutable moving_dw = false;
		val mutable moving_lf = false;
		val mutable moving_rg = false;
		val mutable c_cam = new camera;
		(*get the current camera*)
		method get_camera = c_cam;
		method toggle_wireframe =  _wireframe <- (if _wireframe then false else true)
		method set_background_color c = _bgcolor <- c;
		method draw_meshes = 
			let drawmesh (m:mesh) = m#draw in
			List.iter drawmesh _mesh_list;
		method draw_sprites = 
			let drawspr (s:sprite) = s#draw in
			List.iter drawspr _sprite_list;
		method draw_boxes = 
			let drawbox (b:box) = b#draw in
			List.iter drawbox _box_list;
		method add_mesh m = 
			_mesh_list <- m::_mesh_list;
		method add_sprite s = 
			_sprite_list <- s::_sprite_list;
		method add_box b = 
			_box_list <- b::_box_list;
		method set_size ~width ~height =
				GlDraw.viewport 0 0 width height
		(*drawing method*)
		method draw =
	
  			GlClear.color 
				(_bgcolor#get_r,
				_bgcolor#get_g,
				_bgcolor#get_b);

			(*start to draw in 3D*)
  			GlClear.clear [`color; `depth] ;
			GlDraw.polygon_mode `both (if _wireframe  then `line else `fill);
			
			c_cam#draw;
			Gl.enable `depth_test;
			GlDraw.color (0.0,0.0,1.0);
			self#draw_meshes;

			(*start to draw in 2D*)
		
			GlDraw.polygon_mode `both `fill;
			GlMat.mode `projection;
			Gl.enable `blend;
			GlDraw.color ~alpha:0.0 (0.0,0.0,1.0);
			GlFunc.blend_func `src_alpha `one_minus_src_alpha;
			GlMat.load_identity();
			GlMat.mode `modelview;
			GlMat.load_identity();
			GlMat.push();
			GlMat.scale ~x:(1.0) ~y:(-1.0) ~z:1.0 ();
			GlMat.translate ~x:(-1.0) ~y:(-1.0) ~z:0.0 ();
			GlMat.scale ~x:(2.0) ~y:2.0 ~z:1.0 ();
			self#draw_sprites;
			self#draw_boxes;
			GlMat.pop();
			Gl.disable `blend;
			(*finalize*)
			Gl.flush();


	

		method test_click (x,y) = 
			let clickspr (s:sprite)  = s#click(float_of_int(x) /. _w,float_of_int(y)/. _h) in
			List.iter clickspr _sprite_list;

end;;
		
class window =
	object(self)
		inherit display
		val mutable display = 
			Sdlvideo.set_video_mode 
				~w:640 
				~h:480 
				~bpp:0
				[`OPENGL ; `DOUBLEBUF; `RESIZABLE];
		(*get the current camera*)
		method get_camera = c_cam;

		method swap_buffers = Sdlgl.swap_buffers();
		(*useless*)
		method init = ();
		(*drawing method*)
		method draw =
			
  			GlClear.color 
				(_bgcolor#get_r,
				_bgcolor#get_g,
				_bgcolor#get_b);

			(*start to draw in 3D*)
  			GlClear.clear [`color; `depth] ;
			GlDraw.polygon_mode `both (if _wireframe  then `line else `fill);
			
			c_cam#draw;
			Gl.enable `depth_test;
			GlDraw.color (0.0,0.0,1.0);
			self#draw_meshes;

			(*start to draw in 2D*)
		
			GlDraw.polygon_mode `both `fill;
			GlMat.mode `projection;
			Gl.enable `blend;
			GlDraw.color ~alpha:0.0 (0.0,0.0,1.0);
			GlFunc.blend_func `src_alpha `one_minus_src_alpha;
			GlMat.load_identity();
			GlMat.mode `modelview;
			GlMat.load_identity();
			GlMat.push();
			GlMat.scale ~x:(1.0) ~y:(-1.0) ~z:1.0 ();
			GlMat.translate ~x:(-1.0) ~y:(-1.0) ~z:0.0 ();
			GlMat.scale ~x:(2.0) ~y:2.0 ~z:1.0 ();
			self#draw_sprites;
			self#draw_boxes;
			GlMat.pop();
			Gl.disable `blend;
			(*finalize*)
			Gl.flush();
			Sdlgl.swap_buffers();



	

		method test_click (x,y) = 
			let clickspr (s:sprite)  = s#click(float_of_int(x) /. _w,float_of_int(y)/. _h) in
			List.iter clickspr _sprite_list;
		
	
		method refresh =
			Sdlevent.add (Sdlevent.VIDEOEXPOSE::[]);
		method update =
			if moving_up then begin c_cam#move(0.0,0.0,0.2); self#refresh; end else begin (); end;
			if moving_dw then begin c_cam#move(0.0,0.0,-0.2); self#refresh; end else begin (); end;
			if moving_lf then begin c_cam#move(0.2,0.0,0.0); self#refresh; end else begin (); end;
			if moving_rg then begin c_cam#move(-0.2,0.0,0.0); self#refresh; end else begin (); end;
		(*event manager : must be call in the main*)
		method events = 
			match Sdlevent.wait_event () with
				|Sdlevent.KEYDOWN
					{Sdlevent.keysym=Sdlkey.KEY_ESCAPE} -> exit 0;
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_UP} -> moving_up <- true;
				|Sdlevent.KEYUP 
					{Sdlevent.keysym=Sdlkey.KEY_UP} -> moving_up <- false;
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_DOWN} -> moving_dw <- true;
				|Sdlevent.KEYUP 
					{Sdlevent.keysym=Sdlkey.KEY_DOWN} -> moving_dw <- false;
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_LEFT} -> moving_lf <- true;
				|Sdlevent.KEYUP 
					{Sdlevent.keysym=Sdlkey.KEY_LEFT} -> moving_lf <- false;
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_RIGHT} -> moving_rg <- true;
				|Sdlevent.KEYUP 
					{Sdlevent.keysym=Sdlkey.KEY_RIGHT} -> moving_rg <- false;
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_u} -> c_cam#move(0.0,2.0,0.0);
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_d} -> c_cam#move(0.0,-2.0,0.0);
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_w} -> self#toggle_wireframe ; self#refresh;
				|Sdlevent.MOUSEBUTTONDOWN{Sdlevent.mbe_x=x; Sdlevent.mbe_y=y}-> self#test_click(x, y); self#refresh;
				|Sdlevent.QUIT -> exit 0;
				|Sdlevent.VIDEORESIZE (x,y) -> 
					display <- Sdlvideo.set_video_mode 
					~w:x 
					~h:y 
					~bpp:0
					[`OPENGL ; `DOUBLEBUF; `RESIZABLE];
					GlDraw.viewport 0 0 x y;
					_w <- float_of_int(x); _h <- float_of_int(y);
				|_ -> ();	
end;;

let initialize () = 
()
;;
