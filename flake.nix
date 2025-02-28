{
    description = "Rust development environment";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        rust-overlay = {
            url = "github:oxalica/rust-overlay";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                overlays = [ (import rust-overlay) ];
                pkgs = import nixpkgs {
                    inherit system overlays;
                };
                
                rustToolchain = pkgs.rust-bin.stable.latest.default.override {
                    extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
                };
            in
            {
                devShells.default = pkgs.mkShell {
                    buildInputs = with pkgs; [
                        rustToolchain
                        pkg-config
                        
                        # Common build dependencies
                        openssl.dev
                        
                        # Slint dependencies
                        wayland
                        wayland-protocols
                        libxkbcommon
                        fontconfig
                        xorg.libX11
                        xorg.libXcursor
                        xorg.libXrandr
                        xorg.libXi
                        libGL
                        libinput
                        mesa
                        freetype
                        slint-lsp
                        
                        # Development tools
                        cargo-watch
                        cargo-edit
                        cargo-audit
                    ];
                    
                    LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${ with pkgs; lib.makeLibraryPath [
                        wayland
                        libxkbcommon
                        fontconfig
                        libinput
                        mesa
                        freetype
                    ] }";

                    shellHook = ''
                        echo "Rust development environment"
                        echo "Rust: $(rustc --version)"
                        echo "Cargo: $(cargo --version)"
                    '';
                };
            }
        );
}
