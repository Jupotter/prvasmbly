let gtk_init () =
	GMain.init ();
	let window = GWindow.window ~width:1063 ~height:680 () in
	let _ = window#show () in 
	GMain.Main.main ()
let toto () = ();
