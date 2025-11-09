{ kubenix, config, ... }: 
let
  # tlsCrtPath = config.sops.secrets.tlsCrt.path;
  # tlsKeyPath = config.sops.secrets.tlsKey.path;
in
{
  imports = [
    kubenix.modules.k8s
  ];

  kubernetes.resources = {
    deployments.tpvsel = {
      metadata.labels.app = "tpvsel";
      spec.containers.nginx = {
        image = "tpvsel:latest";
        imagePullPolicy = "Never";
        # imagePullPolicy = "IfNotPresent";

        # Always include ports to avoid 'protocol missing' errors
        ports = [
          { containerPort = 80; protocol = "TCP"; }
          { containerPort = 443; protocol = "TCP"; }
        ];
      };
    };

    services.tpvsel = {
      metadata.labels.app = "tpvsel";
      spec = {
        selector.app = "tpvsel";
        type = "NodePort";
        ports = [
          { name = "tpvsel"; port = 443; nodePort = 31895; protocol = "TCP"; }
        ];
      };
    };
  };
}
