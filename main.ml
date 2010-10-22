let sdl_init () =
  begin
    Sdl.init [`EVERYTHING];
    Sdlevent.enable_events Sdlevent.all_events_mask;
  end

let main() = 
	sdl_init();
	
	let win = new Engine.window in
	Interface.initialize win;
	let msh = Engine.create_grild 240 240 10 in
	

	let hmap = new BasicTypes.image 1 1 in
	hmap#load_file "hm.jpg";

	let img = new BasicTypes.image 1 1 in
	img#load_file "hm.jpg";

	let flcl = new BasicTypes.image 1 1 in
	flcl#load_file "Resources/icogrl.png";

	let sprt = new Engine.sprite (flcl) in

	msh#apply_color (img);
	msh#apply_height (hmap);

	msh#save "hello.obj";
	win#add_mesh msh;
	win#add_sprite sprt;

	sprt#set_size (0.08,0.1);
	sprt#set_position(1.0 -. 0.08,0.0);
	while true do
		win#events;
		win#draw;
		win#update;
	done


let _ = main();

