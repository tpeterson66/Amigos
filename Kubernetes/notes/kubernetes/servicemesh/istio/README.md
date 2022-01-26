# Istio

Primary Features:

- Service Mesh
- mTLS between pods within the mesh
- Proxy data can be used to better track requests through your application using Grafana and Kiali. Grafana provides dashboards for the traffic within the mesh with the ability to dril down into the individual serivces. Kiali provides similar metrics and also provides a graph, which can be used to see the application layout. Kiali can also manage the Istio configuration files as well.
- Obserability - The ability to track and solve issues with the application deployments.

Pilot - Responsible for manging the pod proxy side-cars
Citadel - The certificate authority for the proxies
Galley - Translates K8s yaml to a format that Istio can understand

Istio can be enabled per namesapce using labels or you can add specific deployments using the istioctl command line tool. Per deployment can be used while the team is coming up to speed on Istio and then transition to the entire namespace.

## Getting Started

Getting Started: <https://istio.io/latest/docs/setup/getting-started/>

### istioctl command line tool install - Linux

```bash
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.12.1
export PATH=$PWD/bin:$PATH
```

### Installing Istio on Kubernetes

Verify the pre-reqs are met for Istio using `istioctl x precheck`. If successful, install istio using the following commands and using the correct profiles. The profiles can be reviewed here <https://istio.io/latest/docs/setup/additional-setup/config-profiles/>. The profiles can be listed using `istioctl profile list`.

```bash
istioctl install --set profile=default
# installs istio core, istiod, ingress gateways

# Verification
kubectl -n istio-system get all
<output>
NAME                                      READY   STATUS    RESTARTS   AGE
pod/istio-ingressgateway-8c48d875-7xtjw   1/1     Running   0          75s
pod/istiod-58d79b7bff-xgnnh               1/1     Running   0          85s

NAME                           TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                                      AGE
service/istio-ingressgateway   LoadBalancer   10.0.86.126   1.2.3.4         15021:32671/TCP,80:30413/TCP,443:30436/TCP   75s
service/istiod                 ClusterIP      10.0.105.61   <none>          15010/TCP,15012/TCP,443/TCP,15014/TCP        85s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istio-ingressgateway   1/1     1            1           75s
deployment.apps/istiod                 1/1     1            1           85s

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/istio-ingressgateway-8c48d875   1         1         1       75s
replicaset.apps/istiod-58d79b7bff               1         1         1       85s

NAME                                                       REFERENCE                         TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/istio-ingressgateway   Deployment/istio-ingressgateway   <unknown>/80%   1         5         1          75s
horizontalpodautoscaler.autoscaling/istiod                 Deployment/istiod                 <unknown>/80%   1         5         1          85s
```

## Istio Deployment within the Cluster

Once istio is installed, you will need to enable the pods and deployments within the cluster to use Istio or to add workloads to the mesh. Istio supports two options for this, you can enable for an entire namespace, or you can enable it for individual deployments. The individaul deployment option is ideal if you're still expirementing with istio and are learly of running it on the entire namespace. The end goal being that Istio is enabled for all namespaces running workloads in the cluster.

### Enable Namespaces for Istio

```bash
# enable istio side car proxy for all pods in the app1 namespace
kubectl create ns app1
kubectl label namespace app1 istio-injection=enabled # adds the envoy proxy to any new pod created.
kubectl delete pod --all # used to delete all the running pods and start up new pods with the sidecar proxy
```

### Deployments for Istio - Manual Injection

This method can be used to inject the sidecar proxy on specific pods instead of at the namespace layer. This will get the current running yaml deployment configuration, update the configuration to also include the sidecar proxy and then apply the configuration back to the cluster using kubectl apply.

```bash
kubectl -n <namespace> get deploy <deployment name> -o yaml | istioctl kube-inject -f - | kubectl apply -f -
```

## Metrics and Observability

Since all the network traffic is routed through the sidecar proxies, we can view the traffic using dashboards. This can be done using Grafana or Kiali.

### Grafana

```bash
kubectl apply -f istio-1.12.2/samples/addons/prometheus.yaml 
kubectl apply -f istio-1.12.2/samples/addons/grafana.yaml 

# verify the deployments
kubectl get pods -n istio-system
```

port forwarding can be used to access the grafana service using `kubectl -n istio-system port-forward svc/grafana 3000`

### Kiali

```bash
kubectl apply -f istio-1.12.2/samples/addons/kiali.yaml
```

port forwarding can be used to access the grafana service using `kubectl -n istio-system port-forward svc/kiali 20001`

## Virtual Services

An Istio service that allows you to effect service routing within the mesh. Can use autoamted retries, canary deployments, traffic splits, etc.

More information on these virtual services can be found: <https://istio.io/latest/docs/reference/config/networking/virtual-service>.

### Traffic Splits

This can be used to drip traffic into a new release of your code allowing for testing of your application before a full deployment. This is accomplished by using weighted destinations within your configuration file.

Another option is to use headers or cookies to have certain clients route to different destination services. This can be done for testing or validation of the application without load balacning between the old and the new.

## Lab Environment using Istio

There are some YAML files in this folder that, when deployed in order, can be used to spin up a simple nginx application running within the Istio mesh using the ingress gateway.

```bash
kubectl apply -f 000-namespace.yml
kubectl apply -f 001-deployment.yml -n app1
kubectl apply -f 002-service.yml -n app1
kubectl apply -f 003-ingress.yml -n app1 
```