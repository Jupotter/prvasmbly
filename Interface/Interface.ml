let hmap = new BasicTypes.image 1 1
let meshmap = new Engine.mesh
let toggle_outline = ref (fun (_:unit) -> ();)
let toggle_grild = ref (fun (_:unit) -> ();)
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
let tesselate (hm:BasicTypes.image) = 
	begin
	Analyzer.outlines hm;
	let div2 = Analyzer.div_two hm in 
	let div4 = Analyzer.div_two div2 in 
	let div8 = Analyzer.div_two div4 in 
	let div16 = Analyzer.div_two div8 in
	let div32 = Analyzer.div_two div16 in 
	let div64 = Analyzer.div_two div32 in
	let div128 = Analyzer.div_two div64 in
	let div256 = Analyzer.div_two div128 in
	meshmap#apply_subdivision 256 div256;
	meshmap#apply_subdivision 128 div128;
	meshmap#apply_subdivision 64 div64;
	meshmap#apply_subdivision 32 div32;
	meshmap#apply_subdivision 16 div16;
	meshmap#apply_subdivision 8 div8;

	end

let load_height_map file (win:Engine.window) = 
	begin
	hmap#load_file file;
	let outm =  hmap#clone in
	Analyzer.double_diff outm;
	let grlm = hmap#clone in
	Analyzer.grid_diag grlm  32;
	meshmap#add_grild 0 0 256 (hmap#width - 1) (hmap#height - 1);
	tesselate hmap#clone;
	meshmap#apply_color (hmap);
	meshmap#apply_height (hmap);
	win#add_mesh meshmap;	
	create_minimap win;
	toggle_outline := (show_image outm win);
	toggle_grild := (show_image grlm win);
	meshmap#lock;
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
	win#add_box bx;
	win#add_box bx2;
	win#add_box bx3;

	let bx4 = new Engine.box in
	bx4#set_size(0.25, 0.30 );
	bx4#set_position(0.6, 0.725);
	bx4#set_end_color_rgb(0.4, 0.4, 0.4);
	bx4#set_start_color_rgb(0.1, 0.1, 0.1);
	win#add_box bx;
	win#add_box bx2;
	win#add_box bx3;
	win#add_box bx4;
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
	toggle_menu := (fun _ -> 
		icogrl#toggle_visibility;
		icogrt#toggle_visibility;
		icoout#toggle_visibility;
		icowrf#toggle_visibility;
		icoobj#toggle_visibility;
			)
	end
let is_not_in_list (cl) (c: BasicTypes.color) =
	let rec call= function
    			| [] -> true
    			| e::l  -> 	if (e#equal c) then
						false
					else
						call l
	in
	call !cl;;
  let rec is_not_in_list cl (c: BasicTypes.color) =
let rec call = function
    | [] -> true
    | e::l when (c#equal e) -> false
    | e::l -> call l
in call !cl;;
 let get_image_colors (i:BasicTypes.image) =
  let colorlist = ref ([]:BasicTypes.color list) in
  let f1 = is_not_in_list colorlist in
  let _ = i#foreach_tested_pixel f1 (fun (c:BasicTypes.color) -> colorlist := c::!colorlist ; c) in !colorlist;;
		 

let test_color win= 
begin

let img = new BasicTypes.image 1 1 in
	img#load_file "carte.bmp" ;
let f = new BasicTypes.file_out "colors.txt" in
	List.iter (fun e -> (f#write_string (e#to_string ^ "\n"));();) (get_image_colors img);
	f#write_string 
(string_of_int( 
List.length ( get_image_colors img)
 ) );
	(f#write_string ("\n"^ "\r"));();
	f#close;
	();
	
end;
()


let initialize (win:Engine.window) =
	begin 
	create_ico win;
	create_border win;
	test_color win;
	end


