let sdl_init () =
  begin
    Sdl.init [`EVERYTHING];
    Sdlevent.enable_events Sdlevent.all_events_mask;
  end

let main() = 
	sdl_init();

	let diff = new BasicTypes.image 1 1 in
	let _ = diff#load_file "diff_test.bmp" in
	let out = diff in
	let _ = Analyzer.outlines diff out in
	Bitmap.save_image_bmp out "outl.bmp";

	let win = new Engine.window in
	let msh = Engine.create_grild 100 100 in
	let hmap = new BasicTypes.image 1 1 in
	hmap#load_file "hm.jpg";
	let img = new BasicTypes.image 1 1 in
	img#load_file "flcl.jpg";

	msh#apply_color (img);
	msh#apply_height (hmap);
	win#add_mesh msh;
	while true do
		win#events;
		win#draw;
	done

let _ = main();

