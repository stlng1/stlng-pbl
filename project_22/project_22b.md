DEPLOYING APPLICATIONS INTO KUBERNETES CLUSTER

Deploying the Tooling app using Kubernetes objects

1. create deploy-tooling-app-to-k8s repo
2. clone repo to vscode
3. create html folder in repo
4. copy tooling-app codes into html folder
5. create Dockerfile in repo root

```
# Use the official Nginx image as the base image
FROM nginx

# Copy the HTML files and assets to the Nginx default HTML directory
COPY html /usr/share/nginx/html

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx when the container is run. The daemon off configuration option is used to run Nginx in the 
# foreground instead of as a background daemon process. By setting daemon off, Nginx will start as the main 
# process within the Docker container and stay in the foreground, which allows the container to remain 
# running and prevents it from exiting immediately

CMD ["nginx", "-g", "daemon off;"]
```

5. build docker image and push to dockerhub

```
    docker build -t stlng/tooling-app .
    docker push stlng/tooling-app
```

6. Write a Pod and a Service manifests, ensure that you can access the tooling app’s frontend using port-forwarding feature

*tooling-pod.yaml*

```
apiVersion: v1
kind: Pod
metadata:
  name: tooling-pod
spec:
  containers:
  - name: tooling-container
    image: stlng/tooling-app
    ports:
    - containerPort: 80
```


*tooling-service.yaml*

```
apiVersion: v1
kind: Service
metadata:
  name: tooling-service
spec:
  type: NodePort
  selector:
    app: tooling-pod
  ports:
    - protocol: TCP
      port: 80
      nodePort: 30080
```

