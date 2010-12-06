
OCAML = ocamlopt

GRAPHICSLIB = -ccopt -L. bigarray.cmxa -I +lablGL lablgl.cmxa lablglut.cmxa -I +sdl sdl.cmxa sdlloader.cmxa -I +lablgtk2 lablgtk.cmxa lablgtkgl.cmxa

PROJECTLIB =  -I Loaders/Bitmap/  Loaders/Bitmap/Bitmap.cmx  -I Analyzer/ Analyzer/Analyzer.cmx -I Loaders/Wavefront Loaders/Wavefront/Wavefront.cmx -I 3DEngine/ 3DEngine/Engine.cmx -I Gtk/ Gtk/Gtkint.cmx -I Interface/ Interface/Interface.cmx 
TYPESLIB= -I Types/ Types/BasicTypes.cmx
PCKMANAGER= yum
all: build clean

build:  start build.BasicTypes.cmx build.Loaders.cmx build.Analyzer.cmx build.3DEngine.cmx build.Interf.cmx
	@echo -n "generation de l'executable ...  :  "
	@${OCAML} -o project ${GRAPHICSLIB}  ${TYPESLIB}  ${PROJECTLIB} str.cmxa unix.cmxa  main.ml
	@echo "[REUSSIE]"
build.bytecode: 
	@ocamlc -o project.bytecode -I +lablGL lablgl.cma lablglut.cma  str.cma unix.cma  main.ml
build.BasicTypes.cmx:
	@echo -n "generation des types basiques ...  :  "
	@(cd Types/ && ${OCAML} ${GRAPHICSLIB} -c BasicTypes.cmx *.ml)
	@echo "[REUSSIE]"

build.3DEngine.cmx:
	
	@echo -n "generation du moteur 3D ...  :  "
	@(cd 3DEngine/ && ${OCAML} ${GRAPHICSLIB} -I ../Types/  ../Types/BasicTypes.cmx -I ../Analyzer/  ../Analyzer/Analyzer.cmx -c Engine.cmx *.ml)
	@echo "[REUSSIE]"

build.Interf.cmx:
	@echo -n "generation de l'interface ...  :  "
	@(cd Gtk/ && ${OCAML} ${GRAPHICSLIB} -I ../Types/ ../Types/BasicTypes.cmx -I ../3DEngine/ ../3DEngine/Engine.cmx -I ../Analyzer/ ../Analyzer/Analyzer.cmx -c Gtkint.cmx  *.ml)
	@(cd Interface/ && ${OCAML} ${GRAPHICSLIB}   -I ../Types/ ../Types/BasicTypes.cmx -I ../Gtk/ ../Gtk/Gtkint.cmx -I ../3DEngine/ ../3DEngine/Engine.cmx -I ../Analyzer/ ../Analyzer/Analyzer.cmx -c Interface.cmx  *.ml)

	@echo "[REUSSIE]"

build.Analyzer.cmx:
	@echo -n "generation de l'analyseur d'image ...  :  "
	@(cd Analyzer/ && ${OCAML}  -I ../Types/ -c Analyzer.cmx  ../Types/BasicTypes.cmx *.ml)
	@echo "[REUSSIE]"

build.Loaders.cmx:
	@echo "generation des Loaders  :  "
	@echo -n "	generation du Loader de fichier .obj ... :  "
	@(cd Loaders/Wavefront && ${OCAML}  -I ../../Types/ -c  Wavefront.cmx  ../../Types/BasicTypes.cmx *.ml)
	@echo "[REUSSIE]"
	@echo -n "	generation du Loader de fichier .bmp ... :  "
	@(cd Loaders/Bitmap && ${OCAML}  -I ../../Types/ -c Bitmap.cmx  ../../Types/BasicTypes.cmx *.ml )
	@echo "[REUSSIE]"

clean:
	@echo -n "netoyage des repertoires ...  :  "	
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
	@echo "generation du projet:"

test.bytecode: build.bytecode clean
	@echo "test du resultat ..."
	@(ocamlrun project.bytecode)
	@echo " "
test: build clean
	@echo "test du resultat ..."
	@(./project)
	@echo " "

install.packs:
	${PCKMANAGER} -y reinstall ocaml ocaml-devel ocaml-lablgl ocaml-lablgl-devel ocaml-SDL ocaml-SDL-devel SDL SDL-devel SDL_image ocaml-lablgtk ocaml-lablgtk-devel gtkglarea2-devel
#END FILE

