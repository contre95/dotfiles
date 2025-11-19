{ lib, hostname, ... }:
{
  config =
    if
      lib.elem hostname [
        "server"
        "tablet"
      ]
    then
      {
        systemd.services.k3s.serviceConfig.LoadCredential = [
          "k3s-token:/run/credentials/k3s-token"
        ];

        systemd.services.k3s.preStart = ''
          pass Server/K3SToken > /run/credentials/k3s-token
          chmod 600 /run/credentials/k3s-token
        '';

        services.k3s = {
          enable = true;
          role = "server";
          tokenFile = "/run/credentials/k3s-token";

          extraFlags = toString ([
            "--write-kubeconfig-mode \"0644\""
            "--cluster-init"
            "--disable servicelb"
            "--disable traefik"
            "--disable local-storage"
            # ] ++ (if meta.hostname == "homelab-0" then [] else [
            #   "--server https://homelab-0:6443"
          ]);

          clusterInit = true;
        };

      }
    else
      { };
}
