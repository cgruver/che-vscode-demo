# che-vscode-demo

Demo for configuring the open-source build of VS Code in Eclipse Che & OpenShift Dev Spaces

```bash
podman login registry.redhat.io

DS_CSV=$(oc get csv | grep devspacesoperator | cut -d" " -f1)
DS_CSV=$(oc get csv | grep eclipse-che | cut -d" " -f1)

PLUGIN_REGISTRY_IMAGE=$(oc get csv ${DS_CSV} -o jsonpath={.spec.relatedImages} | jq -r 'map(select(.name == "plugin_registry")) | first | .image')

PLUGIN_REGISTRY_IMAGE=$(oc get csv ${DS_CSV} -o jsonpath={.spec.install.spec.deployments} | jq -r 'map(select(.name == "che-operator")) | first | .spec.template.spec.containers' | jq -r 'map(select(.name == "che-operator")) | first | .env' | jq -r 'map(select(.name == "RELATED_IMAGE_plugin_registry")) | first | .value')

podman build --build-arg PLUGIN_REGISTRY_IMAGE=${PLUGIN_REGISTRY_IMAGE} -t quay.io/cgruver0/che/plugin-registry:quarkus -f custom-plugin-registry.Dockerfile .
```
