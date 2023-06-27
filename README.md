> Here is an example of **helm helper** intended for getting values from custom file

## How it works

* In the repo we have `merge_values` helm chart with the following file structure

```console
tree merge_values
```

<blockquote>

↳ output:
```
merge_values
├── Chart.yaml
├── charts
├── templates
│   ├── _helpers.tpl
│   └── configmap.yaml
├── values-develop.yaml
└── values.yaml

3 directories, 5 files
```
</blockquote>

* In the chart we have
  * `templates/_helpers.tpl` - file with helm helpers, it particulary defines the named template `read_values_from_file`
  * `templates/configmap.yaml` - exemplary helm template file for ConfigMap kubernetes object, which uses the above named template
  * `values.yaml` - file with default values
  * `values-develop.yaml` - file with values for custom `develop` environment
* When we install the helm chart we can pass to `helm install` command (e.g. with `--set` flag) the value for `env` variable corresponding to the custom environment (`develop` in our case)
* Then we can use named template `read_values_from_file` (defined within `templates/_helpers.tpl` file) in any of our helm templates to have access to values defined in the custom environment file (custom environment is set with the passed `env` variable to the `helm install` command)
* The values from `values-develop.yaml` and `values.yaml` files will be merged and available to use throughout the helm template
* Named template `read_values_from_file` is defined within `templates/_helpers.tpl` file

```console
{{- define "read_values_from_file" }}
{{- $filename := cat "values-" .Values.env ".yaml" | nospace }}
{{- $dict := . }}
{{- $_ := set $dict "envValues" (dict) }}
{{- range $path, $_ := .Files.Glob $filename }}
{{- $envValues := $.Files.Get $path | fromYaml }}
{{- $_ := set $dict "envValues" $envValues }}
{{- end }}
{{- end }}
```

* To use it the following structures is necessary

```
{{- $d := dict "Values" .Values "Files" .Files }}
{{- include "read_values_from_file" $d }}
{{- $v := merge $d.envValues $d.Values }}
```

* `$d`  dictionary is passed to the named template as current context (to have access to `.Values.env` and `.Files.Glob`) and used to return values read from file corresponding to the custom environment

## How to use

* Clone the repo and change to the repo directory

```console
git clone https://github.com/cloud-simple/helm-values-from-file.git && cd helm-values-from-file
```

* Run the following command setting the environment variable `env` (with flag `--set env=develop`) and see how default values (from `merge_values/values.yaml` file) are merged with values from the file corresponding to the environment (`merge_values/values-develop.yaml`)

```console
helm install --set env=develop --debug --dry-run test-merge ./merge_values
```

<blockquote>

↳ output:
```
install.go:200: [debug] Original chart version: ""
install.go:217: [debug] CHART PATH: /Users/.../helm-values-from-file/merge_values

NAME: test-merge
LAST DEPLOYED: Tue Jun 27 14:55:34 2023
NAMESPACE: default
STATUS: pending-install
REVISION: 1
TEST SUITE: None
USER-SUPPLIED VALUES:
env: develop

COMPUTED VALUES:
env: develop
meta:
  env: This is default value for Metadata Environment variable
replicas: 1
some: not_to_override

HOOKS:
MANIFEST:
---
# Source: merge_values/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-merge
data:
  env: develop
  filename: values-develop.yaml
  merged-values: |
    map[env:dev-NOT-develop meta:map[description:When we have a special vaiable, let's say 'env', which define the deployment environment, we would like to look for a file with values corresponding to that environment and read values from it env:This is a value for Metadata Environment variable from custom file idea:To be able to read values from custom file (e.g. indentified with help of 'env' variable passed with --set flag) and merge them with other values] replicas:2 some:not_to_override]
```
</blockquote>

* Run the following command without setting the environment variable `env` and see how default values are used

> **Note**
>
> The default value for `env` variable is `main` (as defined in `merge_values/values.yaml` file), and custom values file corresponding to the `main` environment is `values-main.yaml`, which doesn't exist, but this situation is processed correctly

```console
helm install --debug --dry-run test-merge ./merge_values
```

<blockquote>

↳ output:
```
install.go:200: [debug] Original chart version: ""
install.go:217: [debug] CHART PATH: /Users/.../Helm/helm-values-from-file/merge_values

NAME: test-merge
LAST DEPLOYED: Tue Jun 27 15:21:17 2023
NAMESPACE: default
STATUS: pending-install
REVISION: 1
TEST SUITE: None
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
env: main
meta:
  env: This is default value for Metadata Environment variable
replicas: 1
some: not_to_override

HOOKS:
MANIFEST:
---
# Source: merge_values/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-merge
data:
  env: main
  filename: values-main.yaml
  merged-values: |
    map[env:main meta:map[env:This is default value for Metadata Environment variable] replicas:1 some:not_to_override]
```
