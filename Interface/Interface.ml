let hmap = new BasicTypes.image 1 1
let meshmap = new Engine.mesh
let toggle_outline = ref (fun (_:unit) -> ();)
let toggle_grild = ref (fun (_:unit) -> ();)
let toggle_grild_sqrt = ref (fun (_:unit) -> ();)
let toggle_menu = ref (fun (_:unit) -> ();)

let create_minimap (win:Engine.window) = 
	begin
	let spr = new Engine.sprite hmap#clone in
	win#add_sprite spr;
	spr#set_size ( 0.24, 0.28);
	spr#set_position(0.729, 0.61);
	end
let show_image (i:BasicTypes.image) (win:Engine.window) = 
	begin	
	let bx = new Engine.box in
	bx#set_position(0.05,0.0 );
	bx#set_size(0.7, 1.0 -. 0.05 );
	bx#set_end_color_rgba(0.0, 0.0, 0.0, 0.8);
	bx#set_start_color_rgba(0.5, 0.5, 0.5, 0.4);
	let spr = new Engine.sprite i#clone in
	spr#set_size ( 0.5, 0.5);
	spr#set_position ( 0.1, 0.3);
	win#add_sprite spr;
	win#add_box bx;
	bx#hide;
	spr#hide;
	spr#set_on_click (fun _ -> (!toggle_menu)(); spr#toggle_visibility; bx#toggle_visibility;);
	(fun (_:unit) -> (!toggle_menu)(); spr#toggle_visibility; bx#toggle_visibility;);
	end




let create_border (win:Engine.window)=
	begin
	let bx = new Engine.box in
	bx#set_size(1.0, 0.05);
	bx#set_end_color_rgb(0.7, 0.7, 0.7);
	bx#set_start_color_rgb(0.9, 0.9, 0.9);
	let bx2 = new Engine.box in
	bx2#set_size(0.3, 0.1 -. 0.05);
	bx2#set_position(0.05, 0.7);
	bx2#set_start_color_rgb(0.7, 0.7, 0.7);
	bx2#set_end_color_rgb(0.9, 0.9, 0.9);
	let bx3 = new Engine.box in
	bx3#set_size(0.3, 1.0 -. 0.10);
	bx3#set_position(0.10, 0.7);
	bx3#set_end_color_rgb(0.7, 0.7, 0.7);
	bx3#set_start_color_rgb(0.9, 0.9, 0.9);

	let bx4 = new Engine.box in
	bx4#set_size(0.25, 0.30 );
	bx4#set_position(0.6, 0.725);
	bx4#set_end_color_rgb(0.4, 0.4, 0.4);
	bx4#set_start_color_rgb(0.1, 0.1, 0.1);

	let bx5 = new Engine.box in
	bx5#set_size(0.25, 0.35 );
	bx5#set_position(0.15, 0.725);
	bx5#set_start_color_rgb(1.0, 1.0, 1.0);
	bx5#set_end_color_rgb(0.9, 0.9, 0.9);
	win#add_box bx;
	win#add_box bx2;
	win#add_box bx3;
	win#add_box bx4;
	win#add_box bx5;
	end


		 
let write_colors (lst:BasicTypes.color list)= 
	begin
	let f = new BasicTypes.file_out "colors.txt" in
		List.iter (fun e -> (f#write_string (e#to_string ^ "\n"));();) lst;
		(f#write_string ("\n"^ "\r"));();
		f#close;
		();
	
	end;
	()

let color_box y (c:BasicTypes.color) (win:Engine.window) =
	let bx = new Engine.box in
	bx#set_size(0.05, 0.02);
	bx#set_position(0.16 +. y, 0.728 );
	bx#set_end_color_rgb(c#get_rgb);
	bx#set_start_color_rgb(c#get_rgb);
	win#add_box bx;
	()
let show_color lst (win:Engine.window) = 
	begin
	for i = 0 to min ((List.length lst) - 1) 12 do
		color_box (float_of_int(i)/.40.0) (List.nth lst i) win;
	done;
	()
	end


let load_height_map file (win:Engine.window) = 
	begin
	hmap#load_file file;
	let outm =  hmap#clone in
	Analyzer.double_diff outm;
	let grlm = hmap#clone in
	Analyzer.grid_diag grlm  32;
	let grlms = hmap#clone in
	Analyzer.grid grlms  32;
	let nrml = Analyzer.normalmap hmap#clone in
	nrml#save_file "normalmap.bmp";
	meshmap#add_grild 0 0 256 (hmap#width - 1) (hmap#height - 1);
	Analyzer.tesselate (hmap#clone) (meshmap);
	meshmap#apply_color (hmap);
	meshmap#apply_height (hmap);
	win#add_mesh meshmap;	
	create_minimap win;
	toggle_outline := (show_image outm win);
	toggle_grild := (show_image grlm win);
	toggle_grild_sqrt := (show_image grlms win);
	meshmap#lock;
	let colorlist = Analyzer.get_image_colors hmap in
	show_color (Analyzer.get_image_colors hmap) win;
	write_colors colorlist
	end

let add_ico file (win:Engine.window) =
	begin
	let img = new BasicTypes.image 1 1 in
	img#load_file file;
	let sprt = new Engine.sprite (img) in
	win#add_sprite sprt;
	sprt#set_size (0.08,0.1);
	sprt;
	end
let create_ico (win:Engine.window) =
	begin
	let icoobj = add_ico "Resources/icoobj.png" win in
	let icoout = add_ico "Resources/icoout.png" win in
	let icowrf = add_ico "Resources/icowrf.png" win in
	let icogrt = add_ico "Resources/icogrt.png" win in	
	let icogrl = add_ico "Resources/icogrl.png" win in
	icogrl#set_position(0.0, 1.0 -. 0.1);
	icogrt#set_position(0.0, 1.0 -. 0.2);
	icoout#set_position(0.0, 1.0 -. 0.3);
	icowrf#set_position(0.0, 1.0 -. 0.4);
	icoobj#set_position(0.0, 1.0 -. 0.5);

	icowrf#set_on_click((fun _ -> win#toggle_wireframe;));
	icoout#set_on_click_ref toggle_outline;
	icogrt#set_on_click_ref toggle_grild;
	icogrl#set_on_click_ref toggle_grild_sqrt;
	icoobj#set_on_click((fun _ -> meshmap#save "out.obj";));
	toggle_menu := (fun _ -> 
		icogrl#toggle_visibility;
		icogrt#toggle_visibility;
		icoout#toggle_visibility;
		icowrf#toggle_visibility;
		icoobj#toggle_visibility;
			)
	end






let initialize (win:Engine.window) =
	begin 
	create_ico win;
	create_border win;
	end;
()


