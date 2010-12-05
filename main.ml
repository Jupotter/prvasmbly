let sdl_init () =
 	begin
    	Sdl.init [`EVERYTHING];
    	Sdlevent.enable_events Sdlevent.all_events_mask;
	Sdlevent.disable_events Sdlevent.mousemotion_mask;
 	end

let load_bitmap (win:Engine.window) =
	if ((Array.length Sys.argv) > 1) then
		begin
		Interface.load_height_map Sys.argv.(1) win;
		end
	else
		begin
		Interface.load_height_map "carte.bmp" win;
		end

		
let main() = 
	Gtkint.gtk_init();
	sdl_init()
	

(*let sdl_window () = 
	let win = new Engine.window in	
	Interface.initialize win;
	load_bitmap win;
		while true do
			win#events;
			win#draw;
			win#update;
		done
	*)


let _ = main();
