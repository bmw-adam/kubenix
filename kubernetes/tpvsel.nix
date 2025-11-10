{ kubenix, config, tpvsel, pkgs, ... }: 
let
  # tlsCrtPath = config.sops.secrets.tlsCrt.path;
  # tlsKeyPath = config.sops.secrets.tlsKey.path;
in
{
  imports = [
    kubenix.modules.k8s
  ];

  kubernetes.resources = {
    secrets.tpvsel = {
      metadata.name = "tpvsel-secrets";
      stringData = {
        TLS_KEY = builtins.readFile (builtins.getEnv "TLS_KEY");
        TLS_CRT = builtins.readFile (builtins.getEnv "TLS_CRT");
        OAUTH_CLIENT = builtins.readFile (builtins.getEnv "OAUTH_CLIENT");
        DIST_DIR_PATH = builtins.readFile (builtins.getEnv "DIST_DIR_PATH");
      };
    };

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

                command = [ "${tpvsel.packages.${pkgs.system}.default}/bin/backend" ];

                ports = [
                  { name = "tpvsel"; containerPort = 1234; protocol = "TCP"; }
                  { name = "tpvsel"; containerPort = 1235; protocol = "TCP"; }
                ];

                env = [
                    {
                      name = "TLS_KEY";
                      valueFrom.secretKeyRef = {
                        name = "tpvsel-secrets";
                        key = "TLS_KEY";
                      };
                    }
                    {
                      name = "TLS_CRT";
                      valueFrom.secretKeyRef = {
                        name = "tpvsel-secrets";
                        key = "TLS_CRT";
                      };
                    }
                    {
                      name = "OAUTH_CLIENT";
                      valueFrom.secretKeyRef = {
                        name = "tpvsel-secrets";
                        key = "OAUTH_CLIENT";
                      };
                    }
                    {
                      name = "DIST_DIR_PATH";
                      valueFrom.secretKeyRef = {
                        name = "tpvsel-secrets";
                        key = "DIST_DIR_PATH";
                      };
                    }
                  ];
              }
            ];
          };
        };
      };
    };
    
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
