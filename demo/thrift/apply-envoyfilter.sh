action=$1
kubectl $action -n thrift -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: thrift-server-rate-limit-envoyfilter
spec:
  workloadSelector:
    labels:
      app: thrift-sample-server
  configPatches:
  - applyTo: NETWORK_FILTER
    match:
      context: SIDECAR_INBOUND
      listener:
        filterChain:
          filter:
            name: envoy.filters.network.thrift_proxy
    patch:
      operation: INSERT_BEFORE
      value:
        name: mydummy
        typed_config:
          '@type': type.googleapis.com/udpa.type.v1.TypedStruct
          type_url: type.googleapis.com/envoy.extensions.filters.http.wasm.v3.Wasm
          value:
            config:
              configuration:
                '@type': type.googleapis.com/google.protobuf.StringValue
                value: '{"delay": "1", "tick": "1"}'
              root_id: "rate-limit-filter"
              vm_config:
                code:
                  local:
                    filename: /var/local/wasm/rate-limit-filter.wasm
                runtime: envoy.wasm.runtime.v8
                vm_id: dcoz-vm
EOF