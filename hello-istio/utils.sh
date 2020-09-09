#!/bin/bash

total_number_services=5

function yaml() {
    rm -rf controversial-helm-usage.yaml
    touch controversial-helm-usage.yaml
    
    cd kube

    for ((i=1;i<=$total_number_services;i++)) do
    if (($i == 1)); then
        # helm -n istio-dev upgrade hello-istio${i} ${pwd}/helm -f values-dev.yaml --install
        helm -n istio-dev template hello-istio${i} . -f values-dev.yaml >> ../controversial-helm-usage.yaml    
        # please don't judge me!
        mv templates/gateway.yaml ../
    else
        service_number=$((${i}-1))
        # helm -n istio-dev upgrade hello-istio${i} ${PWD}/helm --set nextService=hello-istio${service_number} -f values-dev.yaml --install
        helm -n istio-dev template hello-istio${i} . --set nextService=hello-istio${service_number} -f values-dev.yaml >> ../controversial-helm-usage.yaml
    fi
    done
    # I know... I'm not proud!
    mv ../gateway.yaml templates/
    # Descomentar hosts do último virtual service
}

function installYaml() {
    kubectl -n istio-dev apply -f controversial-helm-usage.yaml
}

function callIngress() {
    curl -i http://localhost:7000 -H "Host: hello-istio-public.aws.my-company.io"
}

function callIngressChain() {
    curl -i http://localhost:7000/chain -H "Host: hello-istio-public.aws.my-company.io"
}

function callIngressChainBulk() {
    seq 1 60 | xargs -n1 -P3  curl http://localhost:7000/chain -H "Host: hello-istio-public.aws.my-company.io"
}

function callDelay() {
    curl -i -X POST http://localhost:6000/changeDelay
}

function deleteResources() {
    for ((i=1;i<=$total_number_services;i++)) do
        kubectl -n istio-dev delete svc hello-istio${i}
        kubectl -n istio-dev delete deploy hello-istio${i}
        kubectl -n istio-dev delete virtualservice hello-istio${i}
        kubectl -n istio-dev delete destinationrule hello-istio${i}
    done
    kubectl -n istio-dev delete gateway hello-istio-gateway
    rm -rf controversial-helm-usage.yaml
}

function portForwardSVC() {
    echo "Port-Forwarding svc #${1}"
    kubectl -n istio-dev port-forward svc/hello-istio$1 6000:80
}

function portForwardIngress() {
    kubectl -n istio-system port-forward svc/istio-ingressgateway 7000:80
}

function openJaeger() {
    istioctl dashboard jaeger
}

function openKiali() {
    istioctl dashboard kiali
}

case "$1" in
	"yaml")
		yaml
		;;
    "install")
		installYaml
		;;
	"clean")
		deleteResources
		;;
    "pf")
		portForwardSVC $2
		;;
    "pfIngress")
		portForwardIngress
		;;
	"kiali")
		openKiali
		;;
    "jaeger")
		openJaeger
		;;
	"call")
		callIngress
		;;
    "callDelay")
		callDelay
		;;
	"callChain")
		callIngressChain
		;;
    "callChainBulk")
		callIngressChainBulk
		;;
	*)
		error "Usage: $0 clean|yaml|install|pf|pfIngress|call|callDelay|callChain|callChainBulk|kiali|jaeger"
		exit 1
		;;
esac