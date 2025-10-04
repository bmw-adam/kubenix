{ kubenix, system }:
(kubenix.evalModules.${system} {
  module = { kubenix, ... }: {
    imports = [ kubenix.modules.k8s ];
    kubernetes.resources.pods.example.spec.containers.nginx.image = "nginx:latest";
  };
}).config.kubernetes.result