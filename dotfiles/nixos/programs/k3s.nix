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
        services.k3s = {
          enable = true;
          role = "server";
          #pwgen -s -n 16 | head -n1 | pass insert -e Server/K3SToken
          # sudo mkdir -p /etc/k3s && pass "Server/K3SToken" | sudo tee /etc/k3s/token > /dev/null && sudo chmod 600 /etc/k3s/token
          tokenFile = "/etc/k3s/token";
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
