## Kube Prometheus Stack – powerful monitoring stack
Above we focused on how Helm Charts works and how to deploy the simplest monitoring, here we will try to do a quick overview of more advanced and complex set up.

Kube Prometheus Stack is a repository, which collects Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts. This provides easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator.

We install it similarly like earlier, but we provide a kube-prometheus-stack repository.

helm install prometheus prometheus-community/kube-prometheus-stack
kube prometheus stack
kube prometheus stack repository
Afterwards we can list our pods and see if everything is running smoothly.

Access to Grafana UI
Default port for Grafana dashboard is 3000, we can forward port to host by command like below and thus gain access to the dashboard by browser on http://localhost:3000.

kubectl port-forward &lt;grafana-pod-name&gt; 3000 
For Prometheus Operator default login is admin and password, prom-operator. You can change it by adding new below in yaml file and providing it in installation.

grafana:
  adminPassword: &lt;password&gt;

  