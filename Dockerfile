FROM bitnami/kubectl:1.20.9 as kubectl
FROM quay.io/operator-framework/ansible-operator:v1.30.0


COPY requirements.yml ${HOME}/requirements.yml
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible

# Copy kubectl
COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/
# Install kubeseal
# Switch to root user
USER root

# Install kubeseal
RUN curl -LO https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/kubeseal-linux-amd64 && \
    chmod +x kubeseal-linux-amd64 && mv kubeseal-linux-amd64 /usr/local/bin/kubeseal

# Switch back to non-root user
USER 1001

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
