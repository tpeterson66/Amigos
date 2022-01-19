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

CLI Install:

```bash
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.12.1
export PATH=$PWD/bin:$PATH
```

Istio Install to K8s

```bash
istioctl install
# installs istio core, istiod, ingress gateways


# Verification
kubectl -n istio-system get all
<output>
NAME                                      READY   STATUS    RESTARTS   AGE
pod/istio-ingressgateway-8c48d875-7xtjw   1/1     Running   0          75s
pod/istiod-58d79b7bff-xgnnh               1/1     Running   0          85s

NAME                           TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                                      AGE
service/istio-ingressgateway   LoadBalancer   10.0.86.126   20.62.182.139   15021:32671/TCP,80:30413/TCP,443:30436/TCP   75s
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


### Labeling Namespaces to use Istio

```bash
# enable istio side car proxy for all pods in the app1 namespace
kubectl create ns app1
kubectl label namespace app1 istio-injection=enabled
```

Create the application and service - this is a simple NGINX page

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysite-nginx-service
  labels:
    app: nginx
    service: nginx
spec:
  ports:
  - port: 80
    name: http
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysite-nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: bookinfo-details
#   labels:
#     account: details
# ---
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: details-v1
#   labels:
#     app: details
#     version: v1
# spec:
#   replicas: 1
#   selector:
#     matchLabels:
#       app: details
#       version: v1
#   template:
#     metadata:
#       labels:
#         app: details
#         version: v1
#     spec:
#       serviceAccountName: bookinfo-details
#       containers:
#       - name: details
#         image: docker.io/istio/examples-bookinfo-details-v1:1.16.2
#         imagePullPolicy: IfNotPresent
#         ports:
#         - containerPort: 9080
#         securityContext:
#           runAsUser: 1000
```

Open the app to the Internet

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: app1-nginx-gateway
  namespace: app1
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: nginx-service
  namespace: app1
spec:
  hosts:
  - "*"
  gateways:
  - app1-nginx-gateway
  http:
  - match:
    - uri:
        exact: /test
    rewrite:
    uri: "/"
    route:
    - destination:
        host: app1-nginx-gateway
        port:
          number: 80

```