# Popeye

Popeye can be used to validate k8s deployment by checking for unused resrources or misconfigured resources within the environment. This can be installed using the source code or ran using a docker container.

<https://github.com/derailed/popeye>

## Installation

Download the latest version from the releases page on Github <https://github.com/derailed/popeye/releases>. If you do not want to install the package, you can use docker!

## Docker

```bash
  docker run --rm -it \
    -v $HOME/.kube:/root/.kube \
    -e popeye/=/tmp/popeye \
    -v /tmp:/tmp \
    derailed/popeye --context foo -n bar --save --output-file my_report.txt
```

## Kubernetes

Popeye can also run within the cluster itself. <https://github.com/derailed/popeye#the-spinachyaml-configuration>
