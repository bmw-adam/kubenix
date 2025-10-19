{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kubenix.url = "github:hall/kubenix";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, kubenix, sops-nix, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      myK8sManifest = (kubenix.evalModules.${system} {
        modules = [
          ./kubernetes/default.nix
          ./secrets.nix
          # sops-nix.nixosModules.sops
        ];
      }).config.kubernetes.result;

      k8sJsonPackage = pkgs.stdenv.mkDerivation {
        pname = "k8s-json";
        version = "1.0";
        src = ./.;
        
        buildPhase = ''
          mkdir -p $out
          cp ${myK8sManifest} $out/kube.json
        '';

        installPhase = ''
          echo "Installation complete."
        '';
      };
    in
    {
      packages.${system}.default = k8sJsonPackage;
      defaultPackage.${system} = k8sJsonPackage;

      devShells.${system}.default = pkgs.mkShell {
        shellHook = ''
          echo
          echo "---------------------------------------------------------"
          echo "Welcome to the development shell for your K8s manifests!"
          echo "The generated files are available in the K8S_MANIFEST_DIR environment variable."
          echo "Try running: ls \$K8S_MANIFEST_DIR"
          echo "---------------------------------------------------------"
          echo
        '';

        K8S_MANIFEST_DIR = "${k8sJsonPackage}";
      };
    };
}

