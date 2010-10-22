let create_border (win:Engine.window)=
	begin
	let bx = new Engine.box in
	bx#set_size(1.0, 0.05);
	bx#set_end_color_rgb(0.7, 0.7, 0.7);
	bx#set_start_color_rgb(0.9, 0.9, 0.9);
	let bx2 = new Engine.box in
	bx2#set_size(0.3, 0.1 -. 0.05);
	bx2#set_position(0.05, 0.7);
	bx2#set_start_color_rgb(0.7, 0.7, 0.7);
	bx2#set_end_color_rgb(0.9, 0.9, 0.9);
	let bx3 = new Engine.box in
	bx3#set_size(0.3, 1.0 -. 0.10);
	bx3#set_position(0.10, 0.7);
	bx3#set_end_color_rgb(0.7, 0.7, 0.7);
	bx3#set_start_color_rgb(0.9, 0.9, 0.9);
	win#add_box bx;
	win#add_box bx2;
	win#add_box bx3;
	end

let initialize (win:Engine.window) = create_border win;
