
build:  start build.BasicTypes.cmx build.Loaders.cmx build.Analyzer.cmx build.3DEngine.cmx build.Interf.cmx
	@echo -n "generation de l'executable ...  :  "
	@ocamlopt -o project.elf -I 3DEngine/ -I Types/ -I Interface/ -I Analyzer/ -I Loaders/Bitmap -I Loaders/Wavefront Types/BasicTypes.cmx 3DEngine/Engine.cmx  Interface/Interface.cmx Analyzer/Analyzer.cmx Loaders/Bitmap/Bitmap.cmx Loaders/Wavefront/Wavefront.cmx main.ml
	@echo "[REUSSIT]"
build.BasicTypes.cmx:
	@echo -n "generation des types basique ...  :  "
	@(cd Types/ && ocamlopt -c BasicTypes.cmx *.ml)
	@echo "[REUSSIT]"

build.3DEngine.cmx:
	
	@echo -n "generation du moteur 3D ...  :  "
	@(cd 3DEngine/ && ocamlopt -I ../Types/ -c Engine.cmx ../Types/BasicTypes.cmx *.ml)
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
	@(cd Loaders/Wavefront && ocamlopt  -I ../../Types/ -c  Bitmap.cmx  ../../Types/BasicTypes.cmx *.ml)
	@echo "[REUSSIT]"
	@echo -n "	generation du Loader de fichier .bmp ... :  "
	@(cd Loaders/Bitmap && ocamlopt  -I ../../Types/ -c Wavefront.cmx  ../../Types/BasicTypes.cmx *.ml )
	@echo "[REUSSIT]"

clean:
	@echo -n "netoyage des repertoires ...  :  "	
	@rm -f *.{cmx,cmi,o,cmxa,a}
	@rm -f Interface/*.{cmx,cmi,o,cmxa,a}
	@rm -f 3DEngine/*.{cmx,cmi,o,cmxa,a}
	@rm -f Analyzer/*.{cmx,cmi,o,cmxa,a}
	@rm -f Loaders/Bitmap/*.{cmx,cmi,o,cmxa,a}
	@rm -f Loaders/Wavefront/*.{cmx,cmi,o,cmxa,a}
	@rm -f Types/*.{cmx,cmi,o,cmxa,a}
	@echo "[REUSSIT]"
start:
	@clear
	@echo "generation du projet:"

test: build clean
	@echo "test du résultat ..."
	@(./project.elf)
	@echo " "
