# Kustomize

This is a tool, now built into kubectl, that allows for object replacement at runtime. This allows you to update certain values when executing the `kubectl apply` commands.

## Getting Started

Kustomize requires a `kustomization.yml` file to understand how to deploy the manifest files. There are two options to use Kustomize with kubectl:

```bash
# output the template rendering and then apply the output
kubectl kustomize <path to kustomize folder> | kubectl apply -f -
# OR
kubectl apply -k <path to kustomize folder>
```

### Overlays

Overlays are used to change the values in the manifest files to match a specific deployment, think dev vs. production values. This requires the following folder structures.

```bash
-| app
-| -| base
-| -| overlays
-| -| -| dev
-| -| -| prod # refrence the base configs with updated values.
```

### Patches

Patches are added to the environment folders and can be used to update certain information in the templates. This uses the information previously provided in the base templates to find and replace the values based on the patch details.


```yaml
# example kustomization.yml file
bases:
  - ../../app
patches:
  - label.yml

# example patch
apiVersion: v1
kind: Namespace
metadata:
  name: example
  labels:
    istio-injection: enabled
```
