{{- define "read_values_from_file" }}
{{- $filename := cat "values-" .Values.env ".yaml" | nospace }}
{{- $dict := . }}
{{- $_ := set $dict "envValues" (dict) }}
{{- range $path, $_ := .Files.Glob $filename }}
{{- $envValues := $.Files.Get $path | fromYaml }}
{{- $_ := set $dict "envValues" $envValues }}
{{- end }}
{{- end }}
