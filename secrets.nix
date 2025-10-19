{ config, pkgs, ... }:
let
  tlsCrtPath = config.sops.secrets.tlsCrt.path;
  tlsKeyPath = config.sops.secrets.tlsKey.path;
in
{
  sops = {
    age.keyFile = "/home/bmwadam/.config/sops/age/cetus.txt";
    # age.keyFile = "/etc/sops/age/cetus.txt";
    defaultSopsFile = ./secrets-kubenix.enc.yaml;

    secrets = {
      tlsCrt = { };
      tlsKey  = {};
    };
  };

  environment.variables = {
    TLS_CRT_PATH = tlsCrtPath;
    TLS_KEY_PATH = tlsKeyPath;
  };
}
