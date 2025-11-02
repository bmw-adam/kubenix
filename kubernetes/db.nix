{ kubenix, config, ... }:
{
  imports = [
    kubenix.modules.k8s
  ];

  kubernetes.resources = {
    # Pod definition
    deployments.yugabyte = {
      metadata = {
        name = "yugabyte";
        labels.app = "yugabyte";
      };
      spec = {
        replicas = 1;

        hostname = "yugabyte01";
        containers.yugabyte = {
          image = "yugabytedb/yugabyte:2.25.2.0-b359";
          imagePullPolicy = "IfNotPresent";

          command = [
            "bin/yugabyted"
            "start"
            "--background=false"
            "--base_dir=/db"
          ];

          ports = [
            { name = "master-ui"; containerPort = 7000; protocol = "TCP"; }
            { name = "yb-ui"; containerPort = 9000; protocol = "TCP"; }
            { name = "ysql"; containerPort = 5433; protocol = "TCP"; }
            { name = "ysql-web"; containerPort = 15433; protocol = "TCP"; }
            { name = "ycql"; containerPort = 9042; protocol = "TCP"; }
          ];

          volumeMounts = [
            {
              name = "ybdata";
              mountPath = "/db";
            }
          ];

          resources = {
            limits.memory = "2Gi";
            requests.memory = "512Mi";
          };
        };

        volumes = [
          {
            name = "ybdata";
            persistentVolumeClaim.claimName = "ybdata-pvc";
          }
        ];
      };
    };

    # Persistent Volume Claim
    persistentVolumeClaims.ybdata-pvc = {
      metadata.name = "ybdaa-pvtc";
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        resources.requests.storage = "3Gi";
      };
    };

    # Service to expose YugabyteDB ports
    services.yugabyte = {
      metadata.labels.app = "yugabyte";
      spec = {
        selector.app = "yugabyte";
        type = "ClusterIP";
        ports = [
          { name = "master-ui"; port = 7000; targetPort = 7000; protocol = "TCP"; }
          { name = "yb-ui"; port = 9000; targetPort = 9000; protocol = "TCP"; }
          { name = "ysql"; port = 5433; targetPort = 5433; protocol = "TCP"; }
          { name = "ysql-web"; port = 15433; targetPort = 15433; protocol = "TCP"; }
          { name = "ycql"; port = 9042; targetPort = 9042; protocol = "TCP"; }
        ];
      };
    };
  };
}
