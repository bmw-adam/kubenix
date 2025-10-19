{ kubenix, config, tpvsel, ... }: 
let
  # tlsCrtPath = config.sops.secrets.tlsCrt.path;
  # tlsKeyPath = config.sops.secrets.tlsKey.path;
in
{
  imports = [
    kubenix.modules.k8s
  ];

  kubernetes.resources = {
    pods.example = {
      metadata.labels.app = "example";
      spec.containers.nginx = {
        image = "nginx:latest";

        # Always include ports to avoid 'protocol missing' errors
        ports = [
          { containerPort = 80; protocol = "TCP"; }
        ];
      };
    };

    services.example = {
      spec = {
        selector.app = "example";
        ports = [{
          name = "http";
          port = 80;
          targetPort = 80;
          protocol = "TCP";
        }];
        type = "ClusterIP";
      };
    };
  };
}
