let sdl_init () =
  begin
    Sdl.init [`EVERYTHING];
    Sdlevent.enable_events Sdlevent.all_events_mask;
  end

let main() =
	sdl_init();

(*	let win = new Engine.window in
	let msh = Engine.create_grild 512 512 10.0 in
	let hmap = new BasicTypes.image 1 1 in
	hmap#load_file "carte.bmp";
	let img = new BasicTypes.image 1 1 in
	img#load_file "carte.bmp";
	let outimg = new BasicTypes.image img#width img#height
	Analyzer.outlines i outimg
	double_diff#save_file "outline.bmp"
	msh#apply_color (img);
	msh#apply_height (hmap);
	msh#save "hello.obj";
	win#add_mesh msh;
	while true do
		win#events;
		win#draw;
	done
*)
	let map = new BasicTypes.image 1 1 in
	map#load_file "carte.bmp";
	let outmap = map in
		let _ = Analyzer.double_diff outmap in
		Bitmap.save_image_bmp outmap "outmap.bmp";
	let outmap = map in
		let _ = Analyzer.outlines map outmap in
		Bitmap.save_image_bmp outmap "outmapB.bmp";
	let div2 = Analyzer.div_two map in
		Bitmap.save_image_bmp div2 "div2.bmp"

let _ = main();

