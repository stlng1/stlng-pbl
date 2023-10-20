## Artifactory
helm repo add jfrog https://charts.jfrog.io
helm repo update


AWS S3
To use the AWS S3 bucket as the cluster’s filestore, pass AWS S3 the below parameters to helm install and helm upgrade:

...
# With explicit credentials:
--set artifactory.persistence.type=aws-s3 \
--set artifactory.persistence.awsS3.endpoint=${AWS_S3_ENDPOINT} \
--set artifactory.persistence.awsS3.region=${AWS_REGION} \
--set artifactory.persistence.awsS3.identity=${AWS_ACCESS_KEY_ID} \
--set artifactory.persistence.awsS3.credential=${AWS_SECRET_ACCESS_KEY} \
...

...
# With using existing IAM role
--set artifactory.persistence.type=aws-s3 \
--set artifactory.persistence.awsS3.endpoint=${AWS_S3_ENDPOINT} \
--set artifactory.persistence.awsS3.region=${AWS_REGION} \
--set artifactory.persistence.awsS3.roleName=${AWS_ROLE_NAME} \
...


helm upgrade artifactory --install jfrog/jfrog-platform -n jfrog -f artifactory-values.yaml--kubeconfig kubeconfig \
--set artifactory.persistence.type=aws-s3 \
--set artifactory.persistence.awsS3.endpoint=${AWS_S3_ENDPOINT} \
--set artifactory.persistence.awsS3.region=${AWS_REGION} \
--set artifactory.persistence.awsS3.roleName=${AWS_ROLE_NAME} \

1. Set environmental variables:

```
export SERVICE_IP=$(kubectl get svc --namespace default artifactory-k-artifactory-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo http://$SERVICE_IP/
```
[export SERVICE_IP=$(kubectl get svc --namespace default artifactory-k-artifactory-nginx --kubeconfig kubeconfig -o jso
npath='{.status.loadBalancer.ingress[0].ip}')]

4. Open Artifactory in your browser

http://$SERVICE_IP/


## Hashicorp Vault


Create a new namespace for the Vault installation.

 kubectl create ns vault
Copy
To access the Vault Helm chart, add the Hashicorp Helm repository.

 helm repo add hashicorp https://helm.releases.hashicorp.com
Copy
Install the Vault helm chart.

 helm install vault hashicorp/vault --namespace vault -f config.yaml
Copy
Initialize and unseal Vault.

 kubectl exec --stdin=true --tty=true vault-0 -- vault operator init

Unseal Key 1: MBFSDepD9E6whREc6Dj+k3pMaKJ6cCnCUWcySJQymObb
Unseal Key 2: zQj4v22k9ixegS+94HJwmIaWLBL3nZHe1i+b/wHz25fr
Unseal Key 3: 7dbPPeeGGW3SmeBFFo04peCKkXFuuyKc8b2DuntA4VU5
Unseal Key 4: tLt+ME7Z7hYUATfWnuQdfCEgnKA2L173dptAwfmenCdf
Unseal Key 5: vYt9bxLr0+OzJ8m7c7cNMFj7nvdLljj0xWRbpLezFAI9

Initial Root Token: s.zJNwZlRrqISjyBHFMiEca6GF
Copy
The output displays the key shares and initial root key generated.

Note

These keys are critical to both the security and the operation of Vault and should be treated as per your company's sensitive data policy.

Unseal the Vault server using the unseal keys until the key threshold is met.

 kubectl exec --stdin=true --tty=true vault-0 -- vault operator unseal 
Unseal Key (will be hidden):
Copy
When prompted, enter the Unseal Key 1 value.

 kubectl exec --stdin=true --tty=true vault-0 -- vault operator unseal 
Unseal Key (will be hidden):
Copy
When prompted, enter the Unseal Key 2 value.

 kubectl exec --stdin=true --tty=true vault-0 -- vault operator unseal 
Unseal Key (will be hidden):
Copy
When prompted, enter the Unseal Key 3 value.

Validate that Vault is up and running.

 kubectl get pods --selector='app.kubernetes.io/name=vault'

NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          1m49s
vault-1                                 1/1     Running   0          1m49s
Copy
Display all Vault services.

 kubectl get services -n vault --selector='app.kubernetes.io/name=vault-ui'

NAME       TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
vault-ui   NodePort   10.97.113.241   <none>        8200:30096/TCP   16d

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

  