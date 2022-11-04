{ lib, fetchFromGitHub, rustPlatform, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "coldsnap";
  version = "v0.4.1";
  nativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = [ openssl ];

  src = fetchFromGitHub {
    owner = "awslabs";
    repo = pname;
    rev = version;
    sha256 = "sha256-0NSRD+OZOhKR0l37BE/5T+u+ictGjzdYgqTTiB9+uVo=";
  };

  cargoSha256 = "sha256-txnZpqxRgr5k8zgquYo5FT9iidvPkm6EVSLuU1UhbPQ=";
}
