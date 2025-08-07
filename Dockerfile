FROM python:3.12-alpine

LABEL description="Kubernetes operator to sync IamIdentityMappings to the aws-auth configmap"
LABEL source.repository="aws_auth_eks_crd"
LABEL source.dockerfile="Dockerfile"

RUN apk update --no-cache && apk upgrade --no-cache && apk add build-base
RUN pip install poetry

ADD . /app/
WORKDIR /app

RUN poetry config virtualenvs.create false
RUN mv poetry.lock poetry.lock.bak || true
RUN poetry install --only=main --no-cache

RUN addgroup -S operatorgroup
RUN adduser --system --ingroup operatorgroup --disabled-password --no-create-home --shell /sbin/nologin k8soperator

USER k8soperator

ENTRYPOINT ["/usr/local/bin/kopf", "run", "src/kubernetes_operator/iam_mapping.py"]
