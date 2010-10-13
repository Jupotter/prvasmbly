GRAPHICSLIB= bigarray.cmxa -I +lablGL lablgl.cmxa lablglut.cmxa -I +sdl sdl.cmxa sdlloader.cmxa
PROJECTLIB= -I 3DEngine/ 3DEngine/Engine.cmx -I Loaders/Bitmap/  Loaders/Bitmap/Bitmap.cmx -I Loaders/Wavefront Loaders/Wavefront/Wavefront.cmx -I Analyzer/ Analyzer/Analyzer.cmx -I Interface/ Interface/Interface.cmx
TYPESLIB= -I Types/ Types/BasicTypes.cmx
build:  start build.BasicTypes.cmx build.Loaders.cmx build.Analyzer.cmx build.3DEngine.cmx build.Interf.cmx
	@echo -n "generation de l'executable ...  :  "
	@ocamlopt -o project.elf ${GRAPHICSLIB}  ${TYPESLIB}  ${PROJECTLIB} str.cmxa unix.cmxa  main.ml
	@echo "[REUSSIT]"
build.bytecode: 
	@ocamlc -o project.bytecode -I +lablGL lablgl.cma lablglut.cma  str.cma unix.cma  main.ml
build.BasicTypes.cmx:
	@echo -n "generation des types basique ...  :  "
	@(cd Types/ && ocamlopt -c BasicTypes.cmx *.ml)
	@echo "[REUSSIT]"

build.3DEngine.cmx:
	
	@echo -n "generation du moteur 3D ...  :  "
	@(cd 3DEngine/ && ocamlopt ${GRAPHICSLIB} -I ../Types/ -c  ../Types/BasicTypes.cmx *.ml)
	@echo "[REUSSIT]"

build.Interf.cmx:
	@echo -n "generation de l'interface ...  :  "
	@(cd Interface/ && ocamlopt  -I ../Types/ -c Interface.cmx ../Types/BasicTypes.cmx *.ml)
	@echo "[REUSSIT]"

build.Analyzer.cmx:
	@echo -n "generation de l'analyseur d'image ...  :  "
	@(cd Analyzer/ && ocamlopt  -I ../Types/ -c Analyzer.cmx  ../Types/BasicTypes.cmx *.ml)
	@echo "[REUSSIT]"

build.Loaders.cmx:
	@echo "generation des Loaders  :  "
	@echo -n "	generation du Loader de fichier .obj ... :  "
	@(cd Loaders/Wavefront && ocamlopt  -I ../../Types/ -c  Wavefront.cmx  ../../Types/BasicTypes.cmx *.ml)
	@echo "[REUSSIT]"
	@echo -n "	generation du Loader de fichier .bmp ... :  "
	@(cd Loaders/Bitmap && ocamlopt  -I ../../Types/ -c Bitmap.cmx  ../../Types/BasicTypes.cmx *.ml )
	@echo "[REUSSIT]"

clean:
	@echo -n "netoyage des repertoires ...  :  "	
	@rm -f *.{cmx,cmi,o,cmxa,a}
	@rm -f Interface/*.{cmx,cmi,o,cmxa,a}
	@rm -f 3DEngine/*.{cmx,cmi,o,cmxa,a}
	@rm -f 3DEngine/OpenGL/*.{cmxa,a}
	@rm -f Analyzer/*.{cmx,cmi,o,cmxa,a}
	@rm -f Loaders/Bitmap/*.{cmx,cmi,o,cmxa,a}
	@rm -f Loaders/Wavefront/*.{cmx,cmi,o,cmxa,a}
	@rm -f Types/*.{cmx,cmi,o,cmxa,a}
	@echo "[REUSSIT]"
clean.OpenGL:
	@rm -f 3DEngine/OpenGL/*.{cmxa,a,o,out}
start:
	@clear
	@echo "generation du projet:"

OpenGL:
	@echo -n "generation des modules OpenGL ...  :  "
	@(cd 3DEngine/OpenGL && ocamlopt -c win_stub.c)
	@(cd 3DEngine/OpenGL && ocamlopt -c -cc gcc -cclib GL unix.cmxa bigarray.cmxa graphics.cmxa  win_stub.o Win.ml)	
	@(cd 3DEngine/OpenGL && ocamlopt  -c glcaml_stub.c)
	@(cd 3DEngine/OpenGL && ocamlopt -c -cclib GL unix.cmxa bigarray.cmxa graphics.cmxa  glcaml_stub.o Glcaml.ml)


	@rm -f 3DEngine/OpenGL/*.{out}
	@echo "[REUSSIT]"
test.bytecode: build.bytecode clean
	@echo "test du résultat ..."
	@(ocamlrun project.bytecode)
	@echo " "
test: build clean
	@echo "test du résultat ..."
	@(./project.elf)
	@echo " "
