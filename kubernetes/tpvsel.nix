{ kubenix, config, pkgs, tpvsel, ... }:

let
  dockerImage = pkgs.dockerTools.buildImage {
    name = "tpvsel";
    tag = "latest";
    contents = [ tpvsel.defaultPackage.x86_64-linux ];
    config = {
      Cmd = [ "/bin/tpvsel" ];
      Expose = [8080];
    };
  };

  # The path to the actual image tarball
  dockerTar = "${dockerImage}";
in
{
  imports = [
    kubenix.modules.k8s
  ];

  kubernetes.resources = {
    pods.tpvsel = {
      metadata.labels.app = "tpvsel";
      spec.containers.tpvsel = {
        # The image name that will be *used in Kubernetes manifest*.
        # You must manually load this tar into whatever registry or node you’re targeting.
        image = "tpvsel:local";

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

  # Expose the image tar for loading into Docker
  outputs = {
    dockerTar = dockerImage;
  };
}
