> Here an example of helm helper provided to get values from custom file

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
