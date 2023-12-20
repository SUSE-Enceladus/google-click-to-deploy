{{/*
Expand the name of the chart.
*/}}
{{- define "rancher-prime-byos.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rancher-prime-byos.fullname" -}}
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
{{- define "rancher-prime-byos.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rancher-prime-byos.labels" -}}
helm.sh/chart: {{ include "rancher-prime-byos.chart" . }}
{{ include "rancher-prime-byos.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rancher-prime-byos.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rancher-prime-byos.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rancher-prime-byos.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rancher-prime-byos.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Check for Rancher image configuration
*/}}
{{- define "rancher-prime-byos.image" -}}
  {{- if and (.Values.global) (.Values.global.images) }}
    {{- .Values.global.images.rancher_prime_byos.registry }}/{{ .Values.global.images.rancher_prime_byos.image }}:{{ .Values.global.images.rancher_prime_byos.tag }}
  {{- else }}
    {{- .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
  {{- end }}
{{- end }}
