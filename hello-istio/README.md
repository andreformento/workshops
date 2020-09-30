# Node devops course: Istio Chapter

## Istio

### Setup inicial

Instale o Minikube no Mac:
```sh
brew install minikube
```

Para listar os contextos em que seu `kubectl` está conectado faça um:

```sh
kubectl config get-contexts
```

Se necessário mude o contexto para o Minikube:

```sh
kubectl config use-context minikube
```

Baixe e descompacte o Istio 1.6.5 (precisa ser até essa versão pois a partir do release 1.7.0 o profile demo não vem mais com kiali e outras ferramentas apresentadas nesse workshop) que pode ser encontrado na url: https://istio.io/latest/news/releases/1.6.x/announcing-1.6.5/

Instale o Istio na versão do profile demo segundo a doc: https://istio.io/latest/docs/setup/getting-started/

```sh
istioctl install --set profile=demo
```

Instale o namespace `istio-dev` que vamos precisar nos exemplos:

```sh
kubectl apply -f temp/istio-namespace.json
```

No Linux baixe e instale o `microk8s` (https://microk8s.io) e adapte as instruções desse workshop para ele ;) afinal Mac >> Linux

### Se familiarizando com o worflow de trabalho desse exemplo:

Criação/alteração das aplicações no cluster via helm

```sh
./utils.sh install
```

Faça o port forward do ingress:

```sh
./utils.sh pfIngress
```

Em outra abas faça uns requests para nossa cadeia de serviços:

```sh
./utils.sh callChain
```

Em outra aba, verifique como o Kiali identificou a topologia de nossos serviços: (user e senha: admin)

```sh
./utils.sh kiali
```

Em outra aba, veja os tracings no Jaeger

```sh
./utils.sh jaeger
```

Vamos agora testar o Canary subindo em uma das aplicações (primeiro argumento: 3) uma versão para a Green (segundo argumento: 0.2) com um certo percentual de tráfego (terceiro argumento: 0)

```sh
./utils.sh enableGreen 3 0.2 0
```

Agora que a Green está preparada vamos aumentar o percentual dela para 80%:

```sh
./utils.sh enableGreen 3 0.2 80
```