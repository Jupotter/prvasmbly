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
	let _ = (Arg.parse [
				("-e",
				Arg.Unit (fun () -> 
					begin
						Gtkint.gtk_init "" true false();
						exit 0;
					end),
				"export only the map");
				]
			(fun r -> ();) "usage : ") in

	if ((Array.length Sys.argv) > 1) then
		begin
		Gtkint.gtk_init Sys.argv.(1) false false ();
		end
	else
		begin
		Gtkint.gtk_init "" false false();
		end	

let main () = gtk_init;()
let _ = main();
