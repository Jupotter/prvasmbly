open BasicTypes
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
		method apply_height (img:image) =
			y <- (img#get_pixel (int_of_float x) (int_of_float (y +. z)) )#get_r;
		method apply_color (img:image) =
			c <- (img#get_pixel (int_of_float x) (int_of_float (y +. z)) );
		method move (mx,my,mz) = 
			x<-x+.mx;
			y<-y+.my;
			z<-z+.mz;
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
end;;
class polygon = object(self)
	val mutable v1 = new vertex;
	val mutable v2 = new vertex;
	val mutable v3 = new vertex;
	method apply_height (img:image) =
		v1#apply_height img;
		v2#apply_height img;
		v3#apply_height img;
	method apply_color (img:image) =
		v1#apply_color img;
		v2#apply_color img;
		v3#apply_color img;
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
	method uniform = 
		v2#move(1.0,0.0,0.0);
		v3#move(0.0,0.0,1.0);
	method reverse_uniform = 
		v2#move(1.0,0.0,0.0);
		v3#move(0.0,0.0,1.0);
		v1#move(1.0,0.0,1.0);
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
		p#set_vertices (v1,v2,v3);
end;;



class mesh = object(self)
	val mutable plg_list = ([]:polygon list)
	val mutable _locked = false
	val mutable x = 0.0
	val mutable y = 0.0
	val mutable z = 0.0
	val mutable sx = 1.0
	val mutable sy = 10.0
	val mutable sz = 1.0
	method get_position = (x,y,z);
	method set_position (vx,vy,vz) = 
		x <- vx;
		y <- vy;
		z <- vz;

		
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
	method draw = 
		

		if _locked then
			begin
			
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
			
	method apply_height (img:image) =
		let app_plg (p:polygon) = p#apply_height img in
		self#iter app_plg; 
	method apply_color (img:image) =
		let app_plg (p:polygon) = p#apply_color img in
		self#iter app_plg;		
		
	method lock = 
		begin
		GlDraw.begins `triangles;
			let drawplg (plg:polygon) = plg#draw; in
			List.iter drawplg plg_list;
		GlDraw.ends();
		_locked = true;
		end
end;;


let create_grild size_x size_y = 
	let m = new mesh in
	for x = 0 to size_x do
		for y = 0 to size_y do
			let plg1 = new polygon in
			plg1#uniform;
			plg1#move(float_of_int(x), 0.0, float_of_int(y));
			let plg2 = new polygon in
			plg2#reverse_uniform;
			plg2#move(float_of_int(x), 0.0, float_of_int(y));
			m#add_polygon plg1;
			m#add_polygon plg2;
		done;
	done;
	m


class texture (i:image) = 
	object(self)
		val mutable id = -1

end;;
class window =
	object(self)
		val mutable _mesh_list = ([]:mesh list)
		val mutable _mx = 0
		val mutable _my = 0
		val mutable _bgcolor = new color;
		val mutable _wireframe = false;
		val mutable display = 
			Sdlvideo.set_video_mode 
				~w:640 
				~h:480 
				~bpp:0
				[`OPENGL ; `DOUBLEBUF];
		val mutable c_cam = new camera;
		method swap_buffers = Sdlgl.swap_buffers();
		method init = ();
		method set_background_color c = _bgcolor <- c;
		method draw_meshes = 
			let drawmesh (m:mesh) = m#draw in
			List.iter drawmesh _mesh_list;
		method add_mesh m = 
			_mesh_list <- m::_mesh_list;
		method draw =
  			GlClear.color 
				(_bgcolor#get_r,
				_bgcolor#get_g,
				_bgcolor#get_b);
  			GlClear.clear [`color; `depth] ;
			GlDraw.polygon_mode `both (if _wireframe then `line else `fill);
			
			c_cam#draw;
			Gl.enable `depth_test;
			GlDraw.color (0.3,0.7,0.4);
			self#draw_meshes;

			GlMat.mode `projection;
			GlMat.load_identity();
			GlMat.mode `modelview;
			GlMat.load_identity();
			GlDraw.begins `triangles;

			GlDraw.ends();
			
			Gl.flush();
			Sdlgl.swap_buffers();

		method events = 
			match Sdlevent.wait_event () with
				|Sdlevent.KEYDOWN
					{Sdlevent.keysym=Sdlkey.KEY_ESCAPE} -> exit 0;
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_UP} -> c_cam#move(0.0,0.0,0.2);
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_DOWN} -> c_cam#move(0.0,0.0,-0.2);
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_LEFT} -> c_cam#move(0.2,0.0,0.0);
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_RIGHT} -> c_cam#move(-0.2,0.0,0.0);
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_w} -> _wireframe <- (if _wireframe then false else true);
				|Sdlevent.QUIT -> exit 0;
				|_ -> ();	
end;;

let initialize () = 
()
;;
