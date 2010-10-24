(* .OBJ files loader *)

let load_vertex (s:string) =
(0.,0.,0.)

let load_poly (s:string) =
(0.,0.,0.)::(0.,0.,0.)::(0.,0.,0.)::[]

let load_obj (s:string) =
let file = new BasicTypes.file_in s in
let poly_l = [] in
let vert_a = Array.make 0 (0.,0.,0.) in
try
while true do
	let line = file#read_line in
	if (String.length line != 0) && (line.[0]!='#') then
	match line.[0] with
	  'v' ->let vert_a = Array.append vert_a (Array.make 1 (load_vertex line)) in ()
	| 'f' ->let poly_l = (load_poly line)::poly_l in ()
	| _ ->()
done;
poly_l
with
End_of_file -> poly_l
