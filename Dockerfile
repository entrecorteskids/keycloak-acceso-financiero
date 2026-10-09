FROM quay.io/keycloak/keycloak:26.4 AS builder
RUN /opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --cache=local \
    --health-enabled=true

FROM quay.io/keycloak/keycloak:26.4
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Instancia unica de 512 MB: heap acotado y recolector serial para no exceder el limite del contenedor
ENV JAVA_OPTS_KC_HEAP="-Xms48m -Xmx256m -XX:MetaspaceSize=96m -XX:MaxMetaspaceSize=160m -XX:+UseSerialGC"

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized"]
