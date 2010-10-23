let sdl_init () =
  begin
    Sdl.init [`EVERYTHING];
    Sdlevent.enable_events Sdlevent.all_events_mask;
  end

let main() = 
	sdl_init();
	
	let win = new Engine.window in
	Interface.initialize win;
	Interface.load_height_map "carte.bmp" win;

	while true do
		win#events;
		win#draw;
		win#update;
	done


let _ = main();

