- ConfigMap for the support environment.
- A secret for a secret environment (such as a database connection).
- Configuration Deployment, including two application replicas, port 8080, readiness settings and health checks.
- ClusterIP type service.
- Ingress controller (eg Nginx Ingress Controller) and CertManager to handle load balancing and obtain Let's Encrypt certificates.
- HorizontalPodAutoscaler allows replication to scale based on CPU or RAM usage by up to 80%.
```
my-django-app/
│
├── charts/
├── templates/
│   ├── _helpers.tpl
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── hpa.yaml
│
├── values.yaml
├── Chart.yaml
└── README.md
```

values.yaml
```
database:
  url: "postgresql://user:password@db-hostname:5432/database"
  password: "mysecretpassword"
replicaCount: 2
containerPort: 8080
debug: False
tls:
  secretName: "my-tls-secret"
```

templates/configmap.yaml
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  DJANGO_DB_URL: {{ .Values.database.url }}
  DEBUG: {{ .Values.debug | quote }}
```

templates/secret.yaml
```
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-secret
type: Opaque
data:
  DATABASE_PASSWORD: {{ .Values.database.password | b64enc | quote }}
```

templates/deployment.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        app: {{ .Chart.Name }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "public.ecr.aws/q9z8p5v2/test:latest"
          ports:
            - containerPort: {{ .Values.containerPort }}
          envFrom:
            - configMapRef:
                name: {{ .Release.Name }}-configmap
            - secretRef:
                name: {{ .Release.Name }}-secret
```


templates/service.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-service
spec:
  selector:
    app: {{ .Chart.Name }}
  ports:
    - protocol: TCP
      port: 8080
      targetPort: {{ .Values.containerPort }}
  type: ClusterIP
```

templates/ingress.yaml
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: 37.44.159.169 
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ .Release.Name }}-service
                port:
                  number: 8080
  tls:
    - hosts:
        - 37.44.159.169 
      secretName: {{ .Values.tls.secretName }}
```


templates/hpa.yaml
```
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ .Release.Name }}-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ .Release.Name }}-deployment
  minReplicas: 2
  maxReplicas: 4
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

helmfile
```
repositories:
  - name: stable
    url: https://charts.helm.sh/stable

environments:
  - name: development
    values:
      - values/development.yaml
    kubeContext: development-context  # Имя контекста Kubernetes для development
  - name: production
    values:
      - values/production.yaml
    kubeContext: production-context  # Имя контекста Kubernetes для production

releases:
  - name: my-django-app
    chart: ./my-django-chart
    namespace: my-django-namespace
    version: "1.0.0"
    values:
      - values/common.yaml
    environment:
      name: development
    install: true
  - name: my-django-app
    chart: ./my-django-chart
    namespace: my-django-namespace
    version: "1.0.0"
    values:
      - values/common.yaml
    environment:
      name: production
    install: true
```

- Using Kubernetes and Helm in this scenario provides:

- Scalability: The ability to easily scale the application depending on the load.

- Resource Isolation: Kubernetes ensures that application resources are isolated, preventing conflicts.

- Release Management: Helm simplifies the process of updating and versioning your application.

- Declarative Configuration: Helm and Helmfile use declarative configurations, making it easier to define and version your application's infrastructure.

- Secrets management: Helm can be extended to securely manage secrets, for example using "helm-secrets".

- Load Balancing and SSL: Kubernetes automatically manages load balancing, and Helm can configure Ingress Controllers and obtain SSL certificates using CertManager.
