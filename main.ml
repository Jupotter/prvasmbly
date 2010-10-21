let sdl_init () =
  begin
    Sdl.init [`EVERYTHING];
    Sdlevent.enable_events Sdlevent.all_events_mask;
  end

let main() = 
	sdl_init();
	
	let win = new Engine.window in
	let msh = Engine.create_grild 502 502 20 in
	let flcl = new BasicTypes.image 1 1 in
	flcl#load_file "hm.jpg";

	let hmap = new BasicTypes.image 1 1 in
	hmap#load_file "carte.bmp";

	let img = new BasicTypes.image 1 1 in
	img#load_file "carte.bmp";



	let sprt = new Engine.sprite (hmap#clone) in
	msh#apply_color (img);
	msh#apply_height (hmap);
	msh#save "hello.obj";
	win#add_mesh msh;
	win#add_sprite sprt;
	sprt#set_on_click (fun _-> sprt#move(0.1,0.1););
	while true do
		win#events;
		win#draw;
		win#update;
	done


let _ = main();

