{{/* Common labels + names for clickstack-agent */}}

{{- define "clickstack-agent.name" -}}
clickstack-agent
{{- end -}}

{{- define "clickstack-agent.labels" -}}
app.kubernetes.io/name: clickstack-agent
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: clickstack
{{- end -}}

{{/*
Shared processor block: k8sattributes (ALL workload labels) + resource
(cluster identity) + batching + memory guard. Rendered into both collectors so
every signal carries an identical label set.
*/}}
{{- define "clickstack-agent.processors" -}}
memory_limiter:
  check_interval: 5s
  limit_percentage: 80
  spike_limit_percentage: 25
k8sattributes:
  auth_type: serviceAccount
  passthrough: false
  extract:
    metadata:
      - k8s.namespace.name
      - k8s.pod.name
      - k8s.pod.uid
      - k8s.pod.start_time
      - k8s.node.name
      - k8s.container.name
      - k8s.deployment.name
      - k8s.replicaset.name
      - k8s.daemonset.name
      - k8s.statefulset.name
      - k8s.job.name
      - k8s.cronjob.name
      - container.image.name
      - container.image.tag
    labels:
      - tag_name: app
        key: app.kubernetes.io/name
        from: pod
      - tag_name: k8s.app.component
        key: app.kubernetes.io/component
        from: pod
      - tag_name: k8s.owner.team
        key: team
        from: pod
  pod_association:
    - sources:
        - from: resource_attribute
          name: k8s.pod.uid
    - sources:
        - from: resource_attribute
          name: k8s.pod.name
        - from: resource_attribute
          name: k8s.namespace.name
    - sources:
        - from: connection
resource:
  attributes:
    - key: k8s.cluster.name
      value: "{{ .Values.cluster.name }}"
      action: upsert
    - key: deployment.environment
      value: "{{ .Values.cluster.environment }}"
      action: upsert
batch:
  timeout: 5s
  send_batch_size: 8192
{{- end -}}
