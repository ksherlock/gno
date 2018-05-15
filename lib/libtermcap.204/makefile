termcap.root: termcap.asm termcap.mac
  compile termcap.asm keep=termcap

ltermcap: termcap.root
  rm -f ltermcap
  makelib ltermcap +termcap.a
  cp ltermcap 2/
