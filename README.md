# clickstack-agent

Modular OpenTelemetry telemetry agent for **ClickStack spoke clusters**. Ships
node, container, kube-state, CoreDNS, control-plane and certificate metrics plus
all pod logs and Kubernetes events to a central ClickStack, fully labelled with
`k8s.*` resource attributes for correlation.

This repository is the **source of truth Argo CD pulls** to install the agent on
each spoke cluster (via the `clickstack-spokes` ApplicationSet on the hub).

## Layout

```
Chart.yaml            # chart metadata
values.yaml           # signal on/off toggles
templates/
  rbac.yaml           # collector ServiceAccount + read-only ClusterRole
  collector-node.yaml # DaemonSet: pod logs, hostmetrics, kubeletstats
  collector-cluster.yaml # Deployment: KSM/CoreDNS/cert/control-plane scrape + k8s events
  kube-state-metrics.yaml # gated on metrics.kubeState
  cert-exporter.yaml  # gated on metrics.certExporter
  _helpers.tpl        # shared k8sattributes + resource processors
```

## Local render / lint

```bash
helm lint .
helm template t . --set cluster.name=prod-eu-1
```

## Usage

Deployed automatically by the hub ApplicationSet, which sets `cluster.name` and
`cluster.environment` from the Argo CD cluster labels. See the hub repo docs
`onboard-spoke-cluster.md` for the full flow.
