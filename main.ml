let main = 
	Bitmap.initialize();
	Engine.initialize();
	Analyzer.initialize();
	Interface.initialize();
	let image = Bitmap.load_image_bmp "/home/Jjpotter/prvasmbly/img_test.bmp"	
		in Bitmap.save_image_bmp image "/home/Jjpotter/prvasmbly/save_test.bmp"

let _ = main
