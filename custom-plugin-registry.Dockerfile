ARG PLUGIN_REGISTRY_IMAGE
FROM ${PLUGIN_REGISTRY_IMAGE} as plugin-registry

FROM scratch

COPY --from=plugin-registry / /
COPY ./openvsx-sync.json /

RUN localedef -f UTF-8 -i en_US en_US.UTF-8 && \
    usermod -a -G apache,root,postgres postgres
USER postgres
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV PGDATA=/var/lib/pgsql/14/data/database
ENV JVM_ARGS="-DSPDXParser.OnlyUseLocalLicenses=true -Xmx2048m"

RUN rm -rf ${PGDATA} && \
  /usr/pgsql-14/bin/initdb && \
  # Add all vsix files to the database
  /import-vsix.sh && \
  # add permissions for anyuserid
  chgrp -R 0 /var/lib/pgsql/14/data/database && \
  #cleanup postgresql pid
  rm /var/lib/pgsql/14/data/database/postmaster.pid && \
  rm /var/run/postgresql/.s.PGSQL* && \
  rm /tmp/.s.PGSQL* && \
  chmod 777 /tmp/.lock && \
  chmod -R 777 /tmp/file && \
  chmod -R g+rwX /var/lib/pgsql/14/data/database && mv /var/lib/pgsql/14/data/database /var/lib/pgsql/14/data/old
ENTRYPOINT ["/entrypoint.sh"]
