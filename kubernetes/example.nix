{ kubenix, ... }: {
  imports = [
    kubenix.modules.k8s
  ];

  # Define your Kubernetes resources here.
  kubernetes.resources.pods.example.spec.containers.nginx = {
    image = "nginx:latest";
    ports = [
      { containerPort = 80; }
    ];
  };
}
