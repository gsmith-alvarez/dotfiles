# Compiles a bun/TS CLI to one binary (bundles runtime); entry = source entrypoint.
{ stdenv, bun, ... }:
{ name, version, src, entry ? "./src/cli.ts", buildInputs ? [], nativeBuildInputs ? [] }:
stdenv.mkDerivation {
  pname = name;
  inherit version src buildInputs;
  nativeBuildInputs = [ bun ] ++ nativeBuildInputs;

  buildPhase = ''
    runHook preBuild
    bun install --frozen-lockfile
    bun build ${entry} --compile --outfile bin-${name}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin-${name} "$out/bin/${name}"
    runHook postInstall
  '';
}