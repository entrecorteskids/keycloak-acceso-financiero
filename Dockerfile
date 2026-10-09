FROM quay.io/keycloak/keycloak:26.4 AS builder
RUN /opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --health-enabled=true

FROM quay.io/keycloak/keycloak:26.4
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Instancia unica de 512 MB: se acotan monton, metaespacio y memoria directa
# para que la maquina virtual no pase del limite del contenedor
ENV JAVA_OPTS_KC_HEAP="-Xms48m -Xmx224m"
ENV JAVA_OPTS_APPEND="-Xmx224m -XX:MaxMetaspaceSize=170m -XX:MaxDirectMemorySize=32m"

# --cache es opcion de arranque: sin caché distribuida no se levanta el clúster de Infinispan
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized", "--cache=local"]
