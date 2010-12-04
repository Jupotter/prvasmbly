let main () =
	GMain.init ();
	let window = GWindow.window ~width:1063 ~height:680 () in
	window#show ();
	GMain.Main.main ()

let _ = main ()
