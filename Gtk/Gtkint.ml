
class colorlist = object(self)
	val mutable clist = ([]:BasicTypes.color list)
	val mutable flist = ([]:float list)
	val mutable slist = ([]:string list)
	val mutable img = new BasicTypes.image 1 1
	val mutable columnlist = new GTree.column_list
	val mutable scrolled_panel = GBin.scrolled_window
    			~hpolicy:`AUTOMATIC ~vpolicy:`AUTOMATIC ~height: 400()
	val mutable list_view = GTree.view ()
	val mutable col_list = [];
	method get_img = img;
	method set_img i = img <- i;
	method reset = 
		clist <- [];
		flist <- [];
		slist <- [];

	method refresh = ();
		let rec rem = function
			|[] -> ()
			|e::l ->
				scrolled_panel#remove e;
				rem l
		in
		rem scrolled_panel#children;

		columnlist <- new GTree.column_list;
		let str_col = columnlist#add Gobject.Data.string in
		col_list <- str_col::[];
		let fl_col = columnlist#add Gobject.Data.float in
		let model = GTree.list_store columnlist in
		list_view  <- GTree.view ~model ~packing:scrolled_panel#add ();
		let rec put_list = function
			|([],[]) -> ()
			|(hf::tf,hs::ts) ->
				let pos = model#append () in
				model#set ~row:pos ~column:fl_col hf;
				model#set ~row:pos ~column:str_col hs;
				put_list (tf,ts)
			|_ -> ()
		in put_list (flist,slist);

		let renderer=GTree.cell_renderer_text [] in
		let scolumn=GTree.view_column ~title:"Color"
			~renderer:(renderer, ["text",str_col;"background", str_col]) () in
		let fcolumn=GTree.view_column ~title:"Height"
			~renderer:(renderer, ["text",fl_col]) () in
		let _ = list_view#append_column scolumn in
		let _ = list_view#append_column fcolumn in

		();

	method add_color (c:BasicTypes.color) (f:float) =
		 clist <- c::clist;
		 flist <- f::flist;
		 slist <- (c#get_HTML_code)::slist; (*("R[" ^ string_of_float(c#get_trunc_r) ^ "]:G[" ^
				string_of_float(c#get_trunc_g) ^ "]:B[" ^
				string_of_float(c#get_trunc_b) ^ "]")::slist; *)
		();
	method get_color_list = clist;
	method get_height_list = flist;
	method create_color_list (img:BasicTypes.image) =
		self#reset;
		let clist = Analyzer.get_image_colors img in
		let rec foreach = function
			|[] -> ()
			|e::l -> 	self#add_color e ((e#get_r /. 2.) +. (e#get_g /. 2.));
					foreach l
		in
		foreach clist;
		self#refresh;
		();
	method create=
		self#refresh;
		scrolled_panel#coerce;

	method get_color_height (c:string) =
		let rec scol = function
			|(_, []) |  ([], _) -> 0.0
			|(h::hlist,strng::_)  when strng = c -> h
			|(_::hlist,_::slist) -> scol (hlist, slist)
		in
		 scol (flist, slist)

	method set_color_height (c:string) (f:float) =
		let rec scol = function
			|(_, []) |  ([], _) -> []
			|(_::hlist,strng::_)  when strng = c -> f::hlist
			|(height::hlist,_::slist) -> height::(scol (hlist, slist))
		in
		flist <- (scol (flist, slist));
		self#refresh;
		();

	method get_string ()=
		let selection = list_view#selection in
		let model = list_view#model in
		match (selection#get_selected_rows,col_list) with
			|(r::_,c::_) ->
				let row = model#get_iter r in
				let col = model#get ~row ~column:c in
				col
			|_ -> ""


end;;

let engine_load_map file display map3D clist =
	print_string ("Chargement du fichier : " ^ file ^ "\n"); flush stdout;
	let img = new BasicTypes.image 1 1 in
	img#load_file file;
	clist#set_img img#clone;
	clist#create_color_list img#clone;
	
	display#clear_sprites;
	let minimap = new Engine.sprite img#clone in
	display#add_sprite minimap;
	minimap#set_size (0.2,0.2);
	minimap#set_position (0.75, 0.05);
	display#get_camera#reset_position;
	display#get_camera#set_cursor 
		(0.75, 0.05)
		((2.0 /.  float_of_int(img#width)),(2.0 /.  float_of_int(img#height)));
	map3D#create_map img#clone clist#get_color_list clist#get_height_list


let gtk_apply_color_height (openGLArea) map3D clist =
	map3D#create_map (clist#get_img#clone)
			 (clist#get_color_list)
			 (clist#get_height_list);
	openGLArea#misc#draw None;
	()
let gtk_selector (startup) (func) =
	let sel = GWindow.window 
	~border_width:10
	~allow_grow:false
	~allow_shrink:false
	~resizable:false
	~width:400
	 () in
	let slidedata = GData.adjustment ~value:startup ~lower:0.0 ~upper:1.0
	~step_incr:0.05 ~page_incr:0.2 ~page_size: 0.0 () in
		let destroy () = () in
		let select () = ( func slidedata#value );sel#destroy (); in

	let _ = sel#connect#destroy ~callback:destroy in
	let hpaned = GPack.paned `HORIZONTAL ~width:400
				~packing:sel#add () in
	let ok = GButton.button ~label:"ok" ~packing:hpaned#add2 () in
	let _ = ok#connect#clicked ~callback:select in
	let box = GPack.hbox ~border_width:10 ~packing:hpaned#add1 ~width:340 () in
	
	let hslide = GRange.scale  `HORIZONTAL ~packing:box#add ~adjustment:slidedata () in
	
	sel#show();
	()


let gtk_select_height glade clist =
		let color = (clist#get_string ()) in
		let _ = 
		(		
		if color = "" then
			()
		else
			let _ = gtk_selector (clist#get_color_height color)
				(fun value ->
					(clist#set_color_height color value)
				) in ()
		)
		in

		()

let gtk_help glade clist = ()


let gtk_open_file_dialog (parent_window) (func) = 
	let filesel = GWindow.file_selection
	~title:"Open File"
	~show_fileops:true
	~select_multiple:false
	~parent:parent_window	
	~destroy_with_parent:true
	~allow_grow:false
	~allow_shrink:false
	~resizable:false () in


		let destroy () = () in
		let destroyf () = filesel#destroy () in
		let load () = ( func filesel#filename );filesel#destroy (); in


	let _ = filesel#connect#destroy ~callback:destroy in
	let _ = filesel#cancel_button#connect#clicked ~callback:destroyf in
	let _ = filesel#ok_button#connect#clicked ~callback:load  in
	filesel#show()

let gtk_open_bitmap (openGLArea) (parent_window) (display) (map3D) (clist)=
	gtk_open_file_dialog parent_window 
		(
			fun file ->
			engine_load_map file display map3D clist;
			openGLArea#misc#draw None;
		)

let gtk_correct_image openGLArea parent_window display map3D clist = 
	let correct file = (
	let img = new BasicTypes.image 1 1 in
	img#load_file file;
	Analyzer.correct_image img;
	img#save_file "corrected_image.bmp";
	engine_load_map "corrected_image.bmp" display map3D clist;
	openGLArea#misc#draw None;) in
	gtk_open_file_dialog parent_window (correct);
	
	()
let gtk_lightmap openGLArea map3D clist =
	let lightmap = clist#get_img#clone in
	Analyzer.apply_height  clist#get_color_list clist#get_height_list lightmap;
	Analyzer.blur lightmap;
	let _ = Analyzer.normalmap lightmap in
	
	let lightpos = new BasicTypes.vector3 in
	lightpos#set_xyz(0.5, 1.1, 0.2);
	lightpos#normalize;
	Analyzer.lightmap lightmap lightpos;
	Analyzer.blur lightmap;
	map3D#apply_lightmap lightmap;
	openGLArea#misc#draw None;
	()

let gtk_export_all map3D clist =
	clist#get_img#save_file "out.bmp";
	let hmap = clist#get_img#clone in
	Analyzer.apply_height  clist#get_color_list clist#get_height_list hmap;
	Analyzer.blur hmap;
	hmap#save_file "out.heightmap.bmp";
	map3D#save "out.mesh.obj";
	let lightmap = clist#get_img#clone in
	Analyzer.apply_height  clist#get_color_list clist#get_height_list lightmap;
	Analyzer.blur lightmap;
	let _ =  Analyzer.normalmap lightmap in
	lightmap#save_file "out.normalmap.bmp";	
	let lightpos = new BasicTypes.vector3 in
	lightpos#set_xyz(0.5, 1.1, 0.2);
	lightpos#normalize;
	Analyzer.lightmap lightmap lightpos;
	Analyzer.blur lightmap;
	lightmap#save_file "out.lightmap.bmp";
	()

let destroy () = GMain.Main.quit ()


let refresh3D area window ()=
	let _ = window#draw in
	let _ = area#swap_buffers () in ()



let right_bar openGLArea clist glade map3D () =
	let vpaned = GPack.paned `VERTICAL
			~border_width:4
			~height:200
			~width:200() in

		vpaned#add1 clist#create;
		let hpaned = GPack.paned `HORIZONTAL
			~border_width:0
			~height:50
			~width:100
			~packing: vpaned#add2 () in
		let button_apply = GButton.button ~label:"Appliquer" ~packing:hpaned#add2 () in
			let _ = button_apply#connect#clicked ~callback:(fun _ -> (gtk_apply_color_height openGLArea map3D clist)) in

		let button_set = GButton.button ~label:"Définir" ~packing:hpaned#add1 () in
			let _ = button_set#connect#clicked ~callback:(fun _ -> (gtk_select_height glade clist)) in
		(*FIX ME : la création de tout sauf de la liste de couleur*)
		vpaned#coerce

let on_area_key_press display openGLArea (key:GdkEvent.Key.t) =
	let keystr = GdkEvent.Key.string key in
	let update = function
		|"z" ->begin display#camera_up; (); end
		|"s" ->begin display#camera_down; ();end
		|"d" ->begin display#camera_right; ();end
		|"q" ->begin display#camera_left; ();end
		|"u" ->begin display#camera_forward; ();end
		|"j" ->begin display#camera_backward; ();end
		|"w" ->begin display#toggle_wireframe; ();end
		|"m" ->begin display#toggle_sprites; ();end
		|"a" -> begin display#toggle_camera; (); end
		| _ ->();
	in
	let _ = update keystr in
		openGLArea#misc#draw None;
		true


let default_map openGLArea file window display map3D clist =
	if file = "" then
		gtk_open_bitmap openGLArea window display map3D clist
	else
		begin
		engine_load_map file display map3D clist;
		openGLArea#misc#draw None;
		end

let gtk_export_only file =
	let clist = new colorlist in
	let img = new BasicTypes.image 1 1 in
	img#load_file file;
	clist#set_img img#clone;
	clist#create_color_list img#clone;
	let hmap = clist#get_img#clone in
	Analyzer.apply_height  clist#get_color_list clist#get_height_list hmap;
	Analyzer.blur hmap;
	hmap#save_file "out.heightmap.bmp";
	let lightmap = clist#get_img#clone in
	Analyzer.apply_height  clist#get_color_list clist#get_height_list lightmap;
	Analyzer.blur lightmap;
	let _ =  Analyzer.normalmap lightmap in
	lightmap#save_file "out.normalmap.bmp";	
	let lightpos = new BasicTypes.vector3 in
	lightpos#set_xyz(0.5, 1.1, 0.2);
	lightpos#normalize;
	Analyzer.lightmap lightmap lightpos;
	Analyzer.blur lightmap;
	lightmap#save_file "out.lightmap.bmp";
	()


let gtk_init file exportOnly fastMode () =
	let _ = GMain.init () in

				
	Glade.init ();
	let glade =  Glade.create ~file:"Resources/glade1.glade" () in

	let help = new GWindow.window (GtkWindow.Window.cast(Glade.get_widget glade "help")) in	
	let window = GWindow.window ~width:800 ~height:480 () in
	begin
		let clist = new colorlist in
		let _ = window#connect#destroy ~callback:destroy in
		let map3D = new Engine.mesh in
		let display = new Engine.display in
		let openGLArea = GlGtk.area [`USE_GL; `RGBA; `DOUBLEBUFFER; `DEPTH_SIZE 16]
					 ~width:600
					 ~height:400 ()
					 in
		let vpaned = GPack.paned `VERTICAL ~border_width:0 ~packing:window#add ~height:35() in
			let toolbar = GButton.toolbar
				~orientation:`HORIZONTAL
				~style:`BOTH
				~border_width:0
				~height:35
				~packing:vpaned#add1() in
				(*ajout dans la partie haute du VPanel*)
				(*FIX ME : Initialisation des boutons *)
				let butt_load = GButton.button ~packing:toolbar#add () in
					let _ = butt_load#connect#clicked ~callback:
						(function () ->gtk_open_bitmap openGLArea window display map3D clist) in
						let _ = GMisc.label ~text:"Chargement" ~packing:butt_load#add () in
				let butt_Export = GButton.button ~packing:toolbar#add () in
					let _ = butt_Export#connect#clicked ~callback:
						(fun () -> gtk_export_all map3D clist) in
						let _ = GMisc.label ~text:"Exportation" ~packing:butt_Export#add () in
				let butt_exit = GButton.button ~packing:toolbar#add () in
					let _ = butt_exit#connect#clicked ~callback:
						(window#destroy) in
						let _ = GMisc.label ~text:"Quitter" ~packing:butt_exit#add () in
				let butt_help = GButton.button ~packing:toolbar#add () in
					let _ = butt_help#connect#clicked ~callback:
						(help#show) in
						let _ = GMisc.label ~text:"Aide" ~packing:butt_help#add () in
				let butt_corr = GButton.button ~packing:toolbar#add () in
					let _ = butt_corr#connect#clicked ~callback:
						(fun _ -> gtk_correct_image openGLArea window display map3D clist) in
						let _ = GMisc.label ~text:"Corriger l'image" ~packing:butt_corr#add () in
				let butt_light = GButton.button ~packing:toolbar#add () in
					let _ = butt_light#connect#clicked ~callback:
						(fun _ -> gtk_lightmap openGLArea map3D clist) in
						let _ = GMisc.label ~text:"Calculer la lightmap" ~packing:butt_light#add () in			

				(* NOTE : Le warning disparaitra apres initialisation *)
		let hpaned = GPack.paned `HORIZONTAL
					 ~packing:vpaned#add2 () in
		let _ = (if exportOnly then
			gtk_open_file_dialog window
			(fun file -> gtk_export_only file; exit 0;)
		else begin
	

		hpaned#add2 (right_bar openGLArea clist glade map3D ());
		hpaned#add1 openGLArea#coerce;
		display#set_size ~width:640 ~height:480;
		openGLArea#set_size ~width:640 ~height:480;
		let _ = openGLArea#connect#display ~callback:(refresh3D (openGLArea) (display)) in
		let _ = openGLArea#connect#reshape ~callback:(display#set_size ) in
		openGLArea#misc#set_sensitive true;
		openGLArea#misc#set_can_focus true;
		openGLArea#misc#set_can_default true;
		let _ = 
			openGLArea#event#connect#key_press
				~callback:(on_area_key_press display openGLArea) in
		display#add_mesh map3D;
		window#show ();
		openGLArea#make_current();
		openGLArea#swap_buffers ();
		default_map openGLArea file window display map3D clist;
		
		end ) in
		GMain.Main.main ();
  	end

