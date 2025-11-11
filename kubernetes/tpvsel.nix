{ kubenix, config, tpvsel, pkgs, ... }: 
let
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

                command = [ "${tpvsel.packages.${pkgs.system}.default}/bin/backend" ];

                env = [
                  { name = "TLS_KEY"; value = "/k3sdata/secrets/tlsKey"; }
                  { name = "TLS_CRT"; value = "/k3sdata/secrets/tlsCrt"; }
                  { name = "DIST_DIR_PATH"; value = "${tpvsel.packages.${pkgs.system}.default}/bin/dist"; }
                  { name = "OAUTH_CLIENT"; value = "/k3sdata/secrets/oauthClient"; }
                ];

                ports = [
                  { name = "tpvsel"; containerPort = 1234; protocol = "TCP"; }
                  { name = "tpvsel"; containerPort = 1235; protocol = "TCP"; }
                ];

                volumeMounts = [
                  {
                    name = "k3sdata";
                    mountPath = "/k3sdata";
                  }
                ];
              }
            ];

            volumes = [
              {
                name = "k3sdata";
                hostPath = {
                  path = "/run/secrets";   # <- filesystem mount on the host
                  type = "Directory";   # safe to use directory type
                };
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
