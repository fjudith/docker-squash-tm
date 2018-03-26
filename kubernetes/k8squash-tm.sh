#!/bin/bash

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

# Create
if [ -z create ] ; then
  kubectl create namespace squash-tm
  kubectl label namespace squash-tm istio-injection=enabled

  tr --delete '\n' <squash-tm.postgres.password.txt >.strippedpassword.txt && mv .strippedpassword.txt squash-tm.postgres.password.txt
  kubectl create secret generic -n squash-tm squash-tm-pass --from-file=squash-tm.postgres.password.txt
  kubectl apply -f ./local-volumes.yaml 
  kubectl apply -n squash-tm -f ./squash-tm-deployment.yaml

  kubectl get svc squash-tm -n squash-tm
elif [ -v create ] && [ "$create" == "conduit" ]; then
  kubectl create namespace squash-tm
  kubectl label namespace squash-tm istio-injection=enabled

  tr --delete '\n' <squash-tm.postgres.password.txt >.strippedpassword.txt && mv .strippedpassword.txt squash-tm.postgres.password.txt
  kubectl create secret generic -n squash-tm squash-tm-pass --from-file=squash-tm.postgres.password.txt
  kubectl apply -f ./local-volumes.yaml
  cat ./squash-tm-deployment.yaml | conduit inject --skip-outbound-ports=5432 --skip-inbound-ports=5432 - | kubectl apply -n squash-tm -f -

  kubectl get svc squash-tm -n squash-tm -o jsonpath="{.status.loadBalancer.ingress[0].*}"

  kubectl get svc squash-tm -n squash-tm
elif [ -v create ] && [ "$create" == "istio" ]; then
  kubectl create namespace squash-tm
  kubectl label namespace squash-tm istio-injection=enabled

  tr --delete '\n' <squash-tm.postgres.password.txt >.strippedpassword.txt && mv .strippedpassword.txt squash-tm.postgres.password.txt
  kubectl create secret generic -n squash-tm squash-tm-pass --from-file=squash-tm.postgres.password.txt
  kubectl apply -f ./local-volumes.yaml
  kubectl apply -n squash-tm -f ./squash-tm-deployment.yaml
  kubectl apply -n squash-tm -f ./squash-tm-ingress.yaml

  export GATEWAY_URL=$(kubectl get po -l istio=ingress -n istio-system -o 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc istio-ingress -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')

  printf "Istio Gateway: $GATEWAY_URL"
fi


# Delete
if [ -z delete ] || [ "$delete" == "conduit" ]; then
  kubectl delete -f ./local-volumes.yaml
  kubectl delete secret -n squash-tm squash-tm-pass
  kubectl delete -n squash-tm -f ./squash-tm-deployment.yaml

  kubectl delete namespace squash-tm
fi

if [ -v delete ] && [ "$delete" == "istio" ]; then
  kubectl delete -f ./local-volumes.yaml
  kubectl delete secret -n squash-tm squash-tm-passs
  kubectl delete -n squash-tm -f ./squash-tm-deployment.yaml
  kubectl delete -n squash-tm -f ./squash-tm-ingress.yaml

  kubectl delete namespace squash-tm
fi