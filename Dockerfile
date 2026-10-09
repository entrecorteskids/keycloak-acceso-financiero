FROM quay.io/keycloak/keycloak:26.4 AS builder
RUN /opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --health-enabled=true

FROM quay.io/keycloak/keycloak:26.4
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Instancia unica de 512 MB: heap acotado y recolector serial para no exceder el limite del contenedor
ENV JAVA_OPTS_KC_HEAP="-Xms48m -Xmx256m"
ENV JAVA_OPTS_APPEND="-Xmx256m -XX:MaxMetaspaceSize=160m -XX:+UseSerialGC -XX:MaxDirectMemorySize=32m"

# --cache es opcion de arranque: sin caché distribuida no se levanta JGroups ni Infinispan en clúster
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized", "--cache=local"]
