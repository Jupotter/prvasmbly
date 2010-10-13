open BasicTypes
open Graphics
class texture (i:image) = 
	object(self)
		val mutable id = -1

end;;
class window =
	object(self)
		val mutable mx = 0
		val mutable my = 0
		val mutable display = Sdlvideo.set_video_mode 640 480 [`DOUBLEBUF];
		method swap_buffers = ();
		method init = ();
		method draw = ();
		method events = 
			match Sdlevent.wait_event () with
				|Sdlevent.KEYDOWN 
					{Sdlevent.keysym=Sdlkey.KEY_ESCAPE} -> exit 0;
				|_ -> ();	
end;;

let initialize () = 
()
;;
