let collist=["1"]
let highlist=[0.5]

let engine_load_map file =
	print_string ("chargement du fichier : " ^ file); flush stdout(* FIX ME : Recharger une map *)



let gtk_open_bitmap (parent_window) =

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
		let destroyf () = filesel#destroy () in (* destruction forcée *)
		let load () =     engine_load_map filesel#filename ; filesel#destroy () in
		(* pas sur que opengl accepte de se faire flushé avec callback a verifier  au pire virer le callback*)


	let _ = filesel#connect#destroy ~callback:destroy in
	let _ = filesel#cancel_button#connect#clicked ~callback:destroyf in
	let _ = filesel#ok_button#connect#clicked ~callback:load in
	filesel#show()



let destroy () = GMain.Main.quit ()

let refresh3D window ()=
	window#draw

let right_bar () =
	let vpaned = GPack.paned `VERTICAL
			~border_width:4
			~height:200
			~width:200() in
		let sw = GBin.scrolled_window () ~packing: vpaned#add2
			~hpolicy: `AUTOMATIC ~vpolicy: `AUTOMATIC in
		let sw2 = GBin.scrolled_window () ~packing: vpaned#add1
			~hpolicy: `AUTOMATIC ~vpolicy: `AUTOMATIC in
		let cols = new GTree.column_list in
		let str_col = cols#add Gobject.Data.string in
		let int_col = cols#add Gobject.Data.float in
		let model = GTree.list_store cols in
		let list_view = GTree.view ~model ~packing:sw2#add () in
		let i::_ = collist in
		let j::_ = highlist in
		let pos = model#append () in
		model#set ~row:pos ~column:str_col i;
		model#set ~row:pos ~column:int_col j;
		let renderer = GTree.cell_renderer_text [] in
		let irenderer = GTree.cell_renderer_text [] in
		let column = GTree.view_column ~title:"Messages"
			~renderer:(renderer, ["text", str_col]) () in
		let icolumn = GTree.view_column ~renderer:(renderer, ["text", int_col]) () in
		list_view#append_column column;
		list_view#append_column icolumn;
		vpaned#coerce

let gtk_init () =
	let _ = GMain.init () in
	let window = GWindow.window ~width:800 ~height:480 () in
	begin
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
		hpaned#add2 (right_bar());
		let openGLArea = GlGtk.area [`RGBA; `DOUBLEBUFFER; `DEPTH_SIZE 16]
					 ~width:600
					 ~height:400
					 ~packing:hpaned#add1 ()
					 in

		let window2 = new Engine.display in
		let _ = openGLArea#connect#display ~callback:(refresh3D (window2)) in

		gtk_open_bitmap window;
		window#show ();
		openGLArea#make_current();
		openGLArea#swap_buffers ();
		GMain.Main.main ();
  	end


