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

let gtk_init = 
	if ((Array.length Sys.argv) > 1) then
		begin
		Gtkint.gtk_init Sys.argv.(1) ();
		end
	else
		begin
		Gtkint.gtk_init "" ();
		end	

let main() = 
	
	
	begin
	sdl_init();
	Arg.parse [
				("-e",
				Arg.Unit (fun () -> 
					begin
						exit 0;
					end),
				"export only the map to a wavefron file");
				("--sdl",
				Arg.Unit (fun () -> 
					begin
						sdl_init();
						let win = new Engine.window in	
						Interface.initialize win;
						load_bitmap win;
							while true do
								win#events;
								win#draw;
								win#update;
							done;
						exit 0;
					end),
				"use a simple SDL window");
				]
			(fun r -> ();) "usage : ";
	
	end
(*let sdl_window () = 

	*)


let _ = main();
