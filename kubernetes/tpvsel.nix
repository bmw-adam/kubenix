{ kubenix, config, pkgs, ... }: {
  imports = with kubenix.modules; [ k8s ];

  docker = {
    registry.url = "docker.somewhere.io";
    images.example.image = pkgs.callPackage ./dockerDefinitions/tpvselDocker.nix { };
  };

  kubernetes.resources.pods.example.spec.containers = {
    custom.image = config.docker.images.example.path;
  };
}