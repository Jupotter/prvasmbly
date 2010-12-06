
OCAML = ocamlopt

GRAPHICSLIB = -ccopt -L. bigarray.cmxa -I +lablGL lablgl.cmxa lablglut.cmxa -I +sdl sdl.cmxa sdlloader.cmxa -I +lablgtk2 lablgtk.cmxa lablgtkgl.cmxa

PROJECTLIB =  -I Loaders/Bitmap/  Loaders/Bitmap/Bitmap.cmx  -I Analyzer/ Analyzer/Analyzer.cmx -I Loaders/Wavefront Loaders/Wavefront/Wavefront.cmx -I 3DEngine/ 3DEngine/Engine.cmx -I Gtk/ Gtk/Gtkint.cmx -I Interface/ Interface/Interface.cmx 
TYPESLIB= -I Types/ Types/BasicTypes.cmx
PCKMANAGER= yum
all: build clean

build:  start build.BasicTypes.cmx build.Loaders.cmx build.Analyzer.cmx build.3DEngine.cmx build.Interf.cmx
	@echo -n "Building executable...  :  "
	@${OCAML} -o project ${GRAPHICSLIB}  ${TYPESLIB}  ${PROJECTLIB} str.cmxa unix.cmxa  main.ml
	@echo "[SUCCESSFUL]"
build.bytecode: 
	@ocamlc -o project.bytecode -I +lablGL lablgl.cma lablglut.cma  str.cma unix.cma  main.ml
build.BasicTypes.cmx:
	@echo -n "Building basic types...  :  "
	@(cd Types/ && ${OCAML} ${GRAPHICSLIB} -c BasicTypes.cmx *.ml)
	@echo "[SUCCESSFUL]"

build.3DEngine.cmx:

	@echo -n "Building 3D engine...  :  "
	@(cd 3DEngine/ && ${OCAML} ${GRAPHICSLIB} -I ../Types/  ../Types/BasicTypes.cmx -I ../Analyzer/  ../Analyzer/Analyzer.cmx -c Engine.cmx *.ml)
	@echo "[SUCCESSFUL]"

build.Interf.cmx:
	@echo -n "Building interface...  :  "
	@(cd Gtk/ && ${OCAML} ${GRAPHICSLIB} -I ../Types/ ../Types/BasicTypes.cmx -I ../3DEngine/ ../3DEngine/Engine.cmx -I ../Analyzer/ ../Analyzer/Analyzer.cmx -c Gtkint.cmx  *.ml)
	@(cd Interface/ && ${OCAML} ${GRAPHICSLIB}   -I ../Types/ ../Types/BasicTypes.cmx -I ../Gtk/ ../Gtk/Gtkint.cmx -I ../3DEngine/ ../3DEngine/Engine.cmx -I ../Analyzer/ ../Analyzer/Analyzer.cmx -c Interface.cmx  *.ml)

	@echo "[SUCCESSFUL]"

build.Analyzer.cmx:
	@echo -n "Building analyzer...  :  "
	@(cd Analyzer/ && ${OCAML}  -I ../Types/ -c Analyzer.cmx  ../Types/BasicTypes.cmx *.ml)
	@echo "[SUCCESSFUL]"

build.Loaders.cmx:
	@echo "Building loaders  :  "
	@echo -n "	Building .obj loader... :  "
	@(cd Loaders/Wavefront && ${OCAML}  -I ../../Types/ -c  Wavefront.cmx  ../../Types/BasicTypes.cmx *.ml)
	@echo "[SUCCESSFUL]"
	@echo -n "	Building .bmp loader... :  "
	@(cd Loaders/Bitmap && ${OCAML}  -I ../../Types/ -c Bitmap.cmx  ../../Types/BasicTypes.cmx *.ml )
	@echo "[SUCCESSFUL]"

clean:
	@echo -n "Cleaning...  :  "	
	@rm -f *.{cmx,cmi,cmo,o,cmxa,a}
	@rm -f Interface/*.{cmx,cmi,cmo,o,cmxa,a}
	@rm -f 3DEngine/*.{cmx,cmi,cmo,o,cmxa,a}
	@rm -f Analyzer/*.{cmx,cmi,cmo,o,cmxa,a}
	@rm -f Loaders/Bitmap/*.{cmx,cmi,cmo,o,cmxa,a}
	@rm -f Loaders/Wavefront/*.{cmx,cmi,cmo,o,cmxa,a}
	@rm -f Types/*.{cmx,cmi,cmo,o,cmxa,a}
	@rm -f Gtk/*.{cmx,cmi,cmo,o,cmxa,a}
	@echo "[REUSSI]"
start:
	@clear
	@echo "Building project:"

test.bytecode: build.bytecode clean
	@echo "Testing result..."
	@(ocamlrun project.bytecode)
	@echo " "
test: build clean
	@echo "Testing result..."
	@(./project)
	@echo " "

install.packs:
	${PCKMANAGER} -y reinstall ocaml ocaml-devel ocaml-lablgl ocaml-lablgl-devel ocaml-SDL ocaml-SDL-devel SDL SDL-devel SDL_image ocaml-lablgtk ocaml-lablgtk-devel gtkglarea2-devel
#END FILE

