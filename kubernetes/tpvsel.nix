{ kubenix, config, nixpkgs, tpvsel, ... }:

let
  dockerImage = nixpkgs.dockerTools.buildImage {
    name = "tpvsel";
    tag = "latest";

    # non-deprecated way
    copyToRoot = nixpkgs.buildEnv {
      name = "tpvsel-env";
      paths = [ tpvsel.defaultPackage.x86_64-linux ];
    };

    config = {
      Cmd = [ "/bin/tpvsel" ]; # adjust if binary path is different
      Expose = [8080];         # adjust port
    };
  };
in
{
  imports = [
    kubenix.modules.k8s
  ];

  kubernetes.resources = {
    pods.tpvsel = {
      metadata.labels.app = "tpvsel";
      spec.containers.tpvsel = {
        image = "tpvsel:local"; # must be loaded into cluster manually
        ports = [
          { containerPort = 8080; protocol = "TCP"; }
        ];
      };
    };

    services.tpvsel = {
      spec = {
        selector.app = "tpvsel";
        ports = [{
          name = "http";
          port = 80;
          targetPort = 8080;
          protocol = "TCP";
        }];
        type = "ClusterIP";
      };
    };
  };

  # expose the docker tar as another attribute
  dockerTar = dockerImage;
}
