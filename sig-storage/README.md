SIG Storage Deployment
=======================

Collection of files to deploy SIG-Storage on a single K3s linux node (tested on Debian).

This will deploy SIG-Storage on K3s with:
  - A disk dedicated to Persistent Volumes
  - As many persistent volumes as you define.

SIG Storage Project:
------------------------

The Kubernetes SIGS project is referenced from the [kubernetes-sigs/sig-storage-local-static-provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner) helm examples github repository.

SIG Storage Deployment Variables:
----------------------------------

```yml
  K3S_PERSISTENT_VOLUME_DISK='/dev/sdb'      #This is the disk you will be assigning Persistent Volumes to K3s from.
  NUMBER_PERSISTENT_VOLUMES=4      #This is the amount of persistent volumes to be created.
```

  Variables are provided as part of the 'deploy-k3s.sh' script included in the top level directory of this repository - See the [README.md](https://k3s.autothis.org/) file for more information.

SIG Storage Deployment Instructions:
-------------------------------------

  Deployment instructions are provided as part of the 'deploy-k3s.sh' script included in the top level directory of this repository - See the [README.md](https://k3s.autothis.org/) file for more information.
