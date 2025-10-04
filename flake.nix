{
  inputs.kubenix.url = "github:hall/kubenix";

  outputs = { self, kubenix, ... }@inputs:
  let
    system = "x86_64-linux";
  in
  {
    packages.${system}.default = (kubenix.evalModules.${system} {
      module = import ./kubernetes/default.nix { inherit kubenix; };
    }).config.kubernetes.result;
  };
}
