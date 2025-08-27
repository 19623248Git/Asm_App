# What I have done so far (azure)

## Create Azure Kubernetes Cluster (AKC)
```
DNS: tstrun-dns-t3x1xv7b.hcp.indonesiacentral.azmk8s.io
```
## Create Azure Container Registry (ACR)
```
registry domain name: tstrunacr.azurecr.io
```

## Using Azure CLI
### Check Azure Version
```
az --version
```

### Azure Login
```
az login --use-device-code
```

### Check Group List
```
az group list --output table
```

### Get Public IP to SSH
```
az vm show --resource-group tstrun_group --name tstrun --show-details --query "publicIps" --output tsv
```

### SSH to azureuser(make sure have key)
```
ssh -i ~/.ssh/tstrunpair.pem azureuser@20.2.138.242
```

### SSH to cloud identity (NOT NEEDED)

#### After SSH to azureuser, install azure CLI and login 

```
az ssh vm --resource-group tstrun_group --vm-name tstrun --subscription 2cab04a9-2142-4c11-9d7f-7d5e2cec364f
```

## Run Kubernetes related stuff

### Get Full Login ACR Server Name
```
az acr show --name tstrunacr --query loginServer --output tsv
```

### Tag Image
```
# Command format:
# sudo docker tag <local_image_name> <acr_login_server>/<new_image_name>:<version>

# Example:
sudo docker tag cobol-app tstrunacr.azurecr.io/cobol-app:v1
```

### Login to ACR from azureuser

- But before that, escalate docker privilege:
```
sudo usermod -aG docker $USER
newgrp docker
```

- Login: 
```
az acr login --name tstrunacr
```

### Push Tagged Image
```
docker push tstrunacr.azurecr.io/cobol-app:v1
```

### Setting Up AKS in Azureuser VM
- Get the Name: 
```
az aks list --resource-group tstrun_group --output table
```

- Get Credentials:
```
az aks get-credentials --resource-group tstrun_group --name tstrun
```


### Create Kubernetes Manifest Files
- deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cobol-app-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cobol-app
  template:
    metadata:
      labels:
        app: cobol-app
    spec:
      containers:
      - name: cobol-app-container
        image: tstrunacr.azurecr.io/cobol-app:v1
        ports:
        - containerPort: 8000
```
- service.yaml:
``` yaml
apiVersion: v1
kind: Service
metadata:
  name: cobol-app-service
spec:
  type: LoadBalancer
  selector:
    app: cobol-app
  ports:
  - protocol: TCP
    port: 5000 # public port to connect.
    targetPort: 8000 # internal port container.
```

- Apply both of the yaml files:
```
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

- Confirm if application is deployed:
```
kubectl get service cobol-app-service --watch
kubectl get pods --watch # Confirm if pods are RUNNING
```

- Grant AKS Access to ACR
```
az aks update --name tstrun --resource-group tstrun_group --attach-acr tstrunacr
```

## Setting up NGINX Ingress Controller

### Install Helm
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

### Install NGINX Ingress from Helm
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.config.strict-validate-path-type=false \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-tcp-idle-timeout"=30
```

### Get Pub IP for Ingress
```
kubectl get service ingress-nginx-controller -n ingress-nginx --watch
```

### Install Cert-Manager
```
curl -LO https://cert-manager.io/public-keys/cert-manager-keyring-2021-09-20-1020CF3C033D4F35BAE1C19E1226061C665DF13E.gpg

helm install \
  cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --version v1.18.2 \
  --namespace cert-manager \
  --create-namespace \
  --verify \
  --keyring ./cert-manager-keyring-2021-09-20-1020CF3C033D4F35BAE1C19E1226061C665DF13E.gpg \
  --set crds.enabled=true
```

### cluster-issuer.yaml
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: "your-email@yourdomain.com"
    privateKeySecretRef:
      name: letsencrypt-prod-private-key
    solvers:
    - http01:
        ingress:
          class: nginx
```
- Apply the yaml file:
```
kubectl apply -f cluster-issuer.yaml
``` 
### ingress.yaml

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: cobol-app-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - scobol.ddns.net
    secretName: cobol-app-tls-secret
  rules:
  - host: "scobol.ddns.net"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: cobol-app-service
            port:
              number: 5000
```

- Apply the yaml file:
```
kubectl apply -f ingress.yaml
```

### Ingress NGINX without HTTPS:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: cobol-app-ingress-test
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: "my-test-app.local"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: cobol-app-service
            port:
              number: 5000
```
