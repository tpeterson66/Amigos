# Project Gemini

This is a Kubernetes project to put a couple of concepts together including Traefik, Linkerd, ArgoCD, and a few other tools as we come across them.

## Objective

Get a cluster running to use for demo puposes. Use Traefik for the ingress controller to route requests to all of the applications running in the cluster. Deploy a simple application, something like Emojivoto to mess around with different technologies including ingress, and Linkerd. Manage the cluster as if it were production.

## Setup

Using Civo for a hosted Kubernetes cluster. There will be a single cluster with 3 nodes all using the medium SKU.

## Traefik

Use the configuration files in the Traefik folder to deploy traefik to the cluster. This will deploy the cluster using the traefik ingress controller allowing you to allow other applications via the cluster later on.

## Apps

These are applications which can be deployed to provide examples of applications runnning in the cluster. These are meant to be super simple and light weight, but can be used to show various functions within Kubernetes.

### whoami

This is a simple application which returns information about the container responding to the request. It also includes a simple ingressroute configuration file which can be used to automataically inform Traefik of the new service and route it through the ingress controller.

### uptime-kuma

This is a monitoring utility which can monitor the uptime of applications and services. This comes from the open-source project -> <https://github.com/louislam/uptime-kuma>