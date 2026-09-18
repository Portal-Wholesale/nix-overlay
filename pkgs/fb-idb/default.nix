{
  lib,
  python3,
  fetchurl,
  fetchPypi,
}:

let
  # fb-idb's generated gRPC stubs validate the protobuf runtime version at
  # import time and require >= 7.35.1; nixpkgs still ships the 6.x runtime.
  # The pure-Python protobuf wheel has no compiled extension, so a private
  # override is enough and does not touch the rest of the Python set.
  protobuf = python3.pkgs.buildPythonPackage rec {
    pname = "protobuf";
    version = "7.35.1";
    format = "wheel";
    src = fetchPypi {
      inherit pname version format;
      dist = "py3";
      python = "py3";
      hash = "sha256-S8l3aNj+StZ0PIoZQD4xRRHtn20TIFtoflJCHAI6wbk=";
    };
    pythonImportsCheck = [ "google.protobuf" ];
    meta.license = lib.licenses.bsd3;
  };
in
python3.pkgs.buildPythonApplication rec {
  pname = "fb-idb";
  version = "1.6.0";
  format = "wheel";

  # The wheel ships the pre-generated gRPC stubs; the sdist regenerates them
  # with grpcio-tools at build time, which is not worth carrying here.
  src = fetchurl {
    url = "https://github.com/facebook/idb/releases/download/v${version}/fb_idb-${version}-py3-none-any.whl";
    hash = "sha256-5VGC8G4fR5KxNRLBoYGGBCYzZ7ElKXUG21iGrjHQsoQ=";
  };

  dependencies = with python3.pkgs; [
    aiofiles
    grpclib
    protobuf
  ];

  pythonImportsCheck = [
    "idb"
    "idb.cli.main"
    "idb.grpc.idb_pb2"
  ];

  meta = {
    description = "iOS Development Bridge command-line client for automating iOS Simulators";
    homepage = "https://fbidb.io";
    changelog = "https://github.com/facebook/idb/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "idb";
  };
}
