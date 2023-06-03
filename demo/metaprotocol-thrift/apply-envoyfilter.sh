action=$1
kubectl $action -n meta-thrift -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  app: thrift-sample-server
spec:
  workloadSelector:
    labels:
      io.kompose.service: $app
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: SIDECAR_INBOUND
      listener:
        filterChain:
          filter:
            name: envoy.filters.network.meta_protocol_proxy
            subFilter:
              name: aeraki.meta_protocol.filters.router
    patch:
      operation: INSERT_BEFORE
      value:
        name: mydummy
        typed_config:
          '@type': type.googleapis.com/udpa.type.v1.TypedStruct
          type_url: type.googleapis.com/envoy.extensions.filters.http.wasm.v3.Wasm
          value:
            config:
              configuration:{}
              root_id: "rate-limit-filter"
              vm_config:
                code:
                  local:
                    filename: /var/local/wasm/rate-limit-filter.wasm
                runtime: envoy.wasm.runtime.v8
                vm_id: dcoz-vm
EOF