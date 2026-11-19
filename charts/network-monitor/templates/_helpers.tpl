{{/*
Expand the name of the chart.
*/}}
{{- define "network-monitor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "network-monitor.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "network-monitor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "network-monitor.labels" -}}
helm.sh/chart: {{ include "network-monitor.chart" . }}
{{ include "network-monitor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
App selector labels
*/}}
{{- define "network-monitor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "network-monitor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: app
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "network-monitor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "network-monitor.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
InfluxDB resource fullname
*/}}
{{- define "network-monitor.influxdb.fullname" -}}
{{- printf "%s-influxdb" (include "network-monitor.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
InfluxDB common labels
*/}}
{{- define "network-monitor.influxdb.labels" -}}
helm.sh/chart: {{ include "network-monitor.chart" . }}
{{ include "network-monitor.influxdb.selectorLabels" . }}
{{- if .Values.influxdb.embedded.image.tag }}
app.kubernetes.io/version: {{ .Values.influxdb.embedded.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
InfluxDB selector labels
*/}}
{{- define "network-monitor.influxdb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "network-monitor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: influxdb
{{- end }}

{{/*
Whether embedded InfluxDB is enabled
*/}}
{{- define "network-monitor.influxdb.embeddedEnabled" -}}
{{- if and .Values.influxdb.enabled .Values.influxdb.embedded.enabled -}}
true
{{- end -}}
{{- end }}

{{/*
Whether the chart should create an InfluxDB Secret
*/}}
{{- define "network-monitor.influxdb.createSecret" -}}
{{- if and .Values.influxdb.enabled (not .Values.influxdb.existingSecret) (or .Values.influxdb.embedded.enabled .Values.influxdb.token) -}}
true
{{- end -}}
{{- end }}

{{/*
Whether the app should mount NETM_INFLUXDB_TOKEN from a Secret
*/}}
{{- define "network-monitor.influxdb.useSecret" -}}
{{- if and .Values.influxdb.enabled (or .Values.influxdb.existingSecret .Values.influxdb.embedded.enabled .Values.influxdb.token) -}}
true
{{- end -}}
{{- end }}

{{/*
InfluxDB Secret name
*/}}
{{- define "network-monitor.influxdb.secretName" -}}
{{- if .Values.influxdb.existingSecret }}
{{- .Values.influxdb.existingSecret }}
{{- else }}
{{- printf "%s-influxdb" (include "network-monitor.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Uptime store duration helper
*/}}
{{- define "network-monitor.uptime.storeDuration" -}}
{{- default "168h" .Values.uptime.storeDuration }}
{{- end }}

{{/*
Whether inline metadata should be written to ConfigMap
*/}}
{{- define "network-monitor.hasInlineMetadata" -}}
{{- if and (not .Values.metadataRedirect) .Values.metadata -}}
true
{{- end -}}
{{- end }}
