deployment:
    namespace: ${SERVICE_NAME}-${ENV}
    name: ${SERVICE_NAME}
    environment:
        container: "true"
        project_env: ${ENV}
        dd_tags: "application:${COMPANY},service:${SERVICE_NAME},env:${ENV}"
        dd_env: ${ENV}
    extra_environment:
        dd_agent_host: status.hostIP
    replicaCount: ${REPLICA_DESIRED}
    image:
        repository: ${REGISTRY_URL}
        tag: ${IMAGE_TAG}
        pullPolicy: Always
        name: ${SERVICE_NAME}
    spec:
        shareProcessNamespace: false
        strategy:
            type: RollingUpdate
            rollingUpdate:
                enabled: true
                maxSurge: 1
                maxUnavailable: 2
            resources:
                requests:
                    cpu: ${CPU}
                    memory: ${MEMORY}
secrets:
    name: general-secrets
    secrets:
        aws_default_region: us-east-1
        dd_service_mapping: requests:${SERVICE_NAME},Requests:${SERVICE_NAME}
datadog:
    query: |-
        avg:kubernetes.network.rx_bytes{kube_namespace:${SERVICE_NAME}-${ENV}}
    name: ${DD_METRIC_NAME}
    namespace: ${SERVICE_NAME}-${ENV}
autoscaler:
    name: ${SERVICE_NAME}
    minReplicas: ${REPLICA_MIN}
    maxReplicas: ${REPLICA_MAX}
    metricName: datadogmetric@${SERVICE_NAME}-${ENV}:${DD_METRIC_NAME}
    scaleTarget: ${SCALE_THRESHOLD}
    behavior:
        scaleUp:
            type: Pods
            value: 1
            periodSeconds: ${SCAN_UP_FREQ}
        scaleDown:
            type: Pods
            value: 1
            periodSeconds: ${SCAN_DOWN_FREQ}
            stabilizationWindowSeconds: ${STAGGER_DOWN_FREQ}
probes:
    readiness:
        path: /healthz/orch
    liveness:
        path: /healthz/orch
    startup:
        path: /healthz/orch
service:
    name: ${SERVICE_NAME}
    namespace: ${SERVICE_NAME}-${ENV}
    type: ClusterIP
    externalPort: 80
    internalPort: 80
    protocol: TCP
    initialDelaySeconds: 3
    failureThreshold: 30
    periodSeconds: 10
    selector:
        app: ${SERVICE_NAME}
    annotations:
        ad.datadoghq.com/service.check_names: '["http_check"]'
        ad.datadoghq.com/service.init_configs: '[{}]'
        ad.datadoghq.com/service.instances: |
            [
                {
                    "name": "${SERVICE_NAME}",
                    "url": "https://${HOST_NAME}/healthz/synthetic",
                    "timeout": 12
                }
            ]
ingress:
    enabled: true
    name: ${SERVICE_NAME}
    namespace: ${SERVICE_NAME}-${ENV}
    annotations:
        kubernetes.io/ingress.class: alb
        alb.ingress.kubernetes.io/load-balancer-name: ${SERVICE_NAME}-${ENV}
        alb.ingress.kubernetes.io/certificate-arn: ${TLS_CERT_ARN},${TLS_CERT_WWW_ARN}
        alb.ingress.kubernetes.io/scheme: internet-facing
        alb.ingress.kubernetes.io/target-type: ip
        alb.ingress.kubernetes.io/listen-ports: "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
        alb.ingress.kubernetes.io/actions.ssl-redirect: "{\"Type\": \"redirect\", \"RedirectConfig\": {\"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
        alb.ingress.kubernetes.io/security-groups: ${SECURITY_GROUP}
        alb.ingress.kubernetes.io/healthcheck-path: /healthz/lb
        alb.ingress.kubernetes.io/healthcheck-interval-seconds: 15
        external-dns.alpha.kubernetes.io/hostname: ${HOST_NAME},wwww.${HOST_NAME}
