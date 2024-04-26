BASEDIR=$(dirname "$0")
source $BASEDIR/../common_func.sh

kubectl create ns hydragen
# kubectl create configmap rate-limit-filter --from-file=rate-limit-filter.wasm="$BASEDIR/http-headers.wasm" -n meta-thrift
LabelIstioInjectLabel hydragen

kubectl apply -f $BASEDIR/hydragen-sample.yaml -n hydragen
