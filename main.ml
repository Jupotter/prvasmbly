let sdl_init () =
  begin
    Sdl.init [`EVERYTHING];
    Sdlevent.enable_events Sdlevent.all_events_mask;
  end

let main() = 
	sdl_init();
	let win = new Engine.window in
	while true do
		win#events;
	done


let _ = main();
