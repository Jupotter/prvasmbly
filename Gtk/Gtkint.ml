class colorlist = object(self)
	val mutable clist = ([]:BasicTypes.color list)
	val mutable flist = ([]:float list)
	val mutable slist = ([]:string list)
	val mutable columnlist = new GTree.column_list
	val mutable scrolled_panel = GBin.scrolled_window
    			~hpolicy:`AUTOMATIC ~vpolicy:`AUTOMATIC ()
	method refresh = ();
		let rec rem = function
			|[] -> ()
			|e::l ->
							
				scrolled_panel#remove e;
				rem l
		in
		rem scrolled_panel#children;

		let str_col = columnlist#add Gobject.Data.string in
		let fl_col  = columnlist#add Gobject.Data.float in
		let model = GTree.list_store columnlist in
		let list_view = GTree.view ~model ~packing:scrolled_panel#add () in

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
			~renderer:(renderer, ["text",str_col]) () in
		let fcolumn=GTree.view_column ~title:"Height"
			~renderer:(renderer, ["text",fl_col]) () in
		list_view#append_column scolumn;
		list_view#append_column fcolumn;

		();

	method add_color (c:BasicTypes.color) (f:float) =
		 clist <- c::clist;
		 flist <- f::flist;
		 slist <- 	(string_of_float(c#get_r) ^ ":" ^
				string_of_float(c#get_b) ^ ":" ^
				string_of_float(c#get_g) ^ ":" ^
				string_of_float(c#get_a))::slist;
		self#refresh;
		();

	method create_color_list (img:BasicTypes.image) = 
		let clist = Analyzer.get_image_colors img in
		let rec foreach = function
			|[] -> ()
			|e::l -> 	self#add_color e (e#get_r +. e#get_g);
					foreach l
		in
		foreach clist;
		();
	method create=
		self#refresh;
		scrolled_panel#coerce;


	method set_color_height (c:string) (f:float) =
		let rec scol = function
			|(_, []) |  ([], _) -> []
			|(_::hlist,strng::_)  when strng = c -> f::hlist
			|(height::hlist,_::slist) -> height::(scol (hlist, slist))
		in
		flist <- (scol (flist, slist));
		self#refresh;
		();

end;;

let engine_load_map file clist =
	print_string ("chargement du fichier : " ^ file); flush stdout;
	let img = new BasicTypes.image 1 1 in
	img#load_file file;
	clist#create_color_list img
	
	(* FIX ME : Recharger une map *)



let gtk_open_bitmap (parent_window) (map3D) (clist)=

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
		let load () = engine_load_map filesel#filename clist; filesel#destroy () in


	let _ = filesel#connect#destroy ~callback:destroy in
	let _ = filesel#cancel_button#connect#clicked ~callback:destroyf in
	let _ = filesel#ok_button#connect#clicked ~callback:load  in
	filesel#show()



let destroy () = GMain.Main.quit ()


let refresh3D area window ()=
	let _ = window#draw in
	let _ = area#swap_buffers () in ()



let right_bar clist () =
	let vpaned = GPack.paned `VERTICAL
			~border_width:4
			~height:200
			~width:200() in
		
		vpaned#add1 clist#create;
		(*FIX ME : la création de tout sauf de la liste de couleur*)
		vpaned#coerce

let gtk_init () =
	let _ = GMain.init () in
	let window = GWindow.window ~width:800 ~height:480 () in
	begin
		let clist = new colorlist in
		let _ = window#connect#destroy ~callback:destroy in
		let vpaned = GPack.paned `VERTICAL ~border_width:0 ~packing:window#add ~height:35() in
			let toolbar = GButton.toolbar
				~orientation:`HORIZONTAL
				~style:`BOTH
				~border_width:0
				~height:35
				~packing:vpaned#add1() in
				(*ajout dans la partie haute du VPanel*)
				(*FIX ME : Initialisation des boutons *)
				(* NOTE : Le warning disparaitra apres initialisation *)
		let hpaned = GPack.paned `HORIZONTAL
					 ~packing:vpaned#add2 () in
		hpaned#add2 (right_bar clist());
		let openGLArea = GlGtk.area [`USE_GL; `RGBA; `DOUBLEBUFFER; `DEPTH_SIZE 16]
					 ~width:600
					 ~height:400
					 ~packing:hpaned#add1 ()
					 in
		let map3D = new Engine.mesh in
		let display = new Engine.display in
		display#set_size ~width:640 ~height:480 ();
		openGLArea#set_size ~width:640 ~height:480;
		let _ = openGLArea#connect#display ~callback:(refresh3D (openGLArea) (display)) in
		gtk_open_bitmap window map3D clist;
		display#add_mesh map3D;
		window#show ();
		openGLArea#make_current();
		openGLArea#swap_buffers ();
		GMain.Main.main ();
  	end


