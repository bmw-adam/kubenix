{ kubenix, config, tpvsel, pkgs, ... }:

let
  # Build a custom Docker image for tpvsel
  tpvselImage = pkgs.dockerTools.buildLayeredImage {
    name = "tpvsel";
    contents = [ tpvsel.defaultPackage.x86_64-linux ];

    extraCommands = ''
      mkdir -p etc
      chmod u+w etc
      # Optional: set up passwd/group inside container
      echo "tpvsel:x:1000:1000::/:" > etc/passwd
      echo "tpvsel:x:1000:tpvsel" > etc/group
    '';

    config = {
      Cmd = [ "/bin/tpvsel" ];     # adjust if binary path differs
      ExposedPorts = { "8080/tcp" = {}; };
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
        # Use the Nix-built Docker image
        image = tpvselImage;
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
}
