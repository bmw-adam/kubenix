# This file should just be a NixOS-style module.
# Kubenix's `evalModules` function will automatically pass the necessary
# arguments like `kubenix`, `pkgs`, `config`, etc.
{ kubenix, ... }: {
  imports = [
    kubenix.modules.k8s
  ];

  # Define your Kubernetes resources here.
  kubernetes.resources.pods.example = {
    spec.containers.nginx = {
      image = "nginx:latest";

      # Always include ports to avoid 'protocol missing' errors
      ports = [
        { containerPort = 80; protocol = "TCP"; }
      ];
    };
  };
}
