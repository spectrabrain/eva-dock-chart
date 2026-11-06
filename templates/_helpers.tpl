{{- define "eva-dock.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "eva-dock.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "eva-dock.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "eva-dock.secretName" -}}
{{- printf "%s-secrets" (include "eva-dock.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "eva-dock.labels" -}}
app.kubernetes.io/name: {{ include "eva-dock.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "eva-dock.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eva-dock.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
