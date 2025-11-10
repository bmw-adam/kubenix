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
      metadata = {
        name = "tpvsel";
        labels.app = "tpvsel";
      };

      spec = {
        replicas = 1;

        selector = {
          matchLabels.app = "tpvsel";
        };

        template = {
          metadata = {
            labels.app = "tpvsel";
          };

          spec = {
            hostname = "tpvsel01";

            containers = [
              {
                name = "tpvsel";
                image = "tpvsel:latest";
                imagePullPolicy = "Never";

                command = [ "sh" "-c" "find / | grep tpvsel" ];

                ports = [
                  { name = "tpvsel"; containerPort = 1234; protocol = "TCP"; }
                  { name = "tpvsel"; containerPort = 1235; protocol = "TCP"; }
                ];
              }
            ];
          };
        };
      };
    };

    # deployments.tpvsel = {
    #   metadata.labels.app = "tpvsel";
    #   spec.containers.tpvsel = {
    #     image = "tpvsel:latest";
    #     imagePullPolicy = "Never";
    #     # imagePullPolicy = "IfNotPresent";

    #     # Always include ports to avoid 'protocol missing' errors
    #     ports = [
    #       { containerPort = 80; protocol = "TCP"; }
    #       { containerPort = 443; protocol = "TCP"; }
    #     ];
    #   };
    # };

    services.tpvsel = {
      metadata.labels.app = "tpvsel";
      spec = {
        selector.app = "tpvsel";
        type = "NodePort";
        ports = [
          { name = "tpvsel"; port = 1235; nodePort = 31895; protocol = "TCP"; }
        ];
      };
    };
  };
}
