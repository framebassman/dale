FROM gradle:jdk8-hotspot AS build-env
COPY . /app
WORKDIR /app
RUN gradle installBootDist -Dspring.profiles.active=dev

FROM bellsoft/liberica-openjdk-alpine:11 as final
RUN apk add --no-cache --upgrade bash
RUN adduser -S deployer -G wheel
WORKDIR /app
COPY --chown=deployer:wheel --from=build-env /app/build/install/app-boot .
COPY --chown=deployer:wheel --from=build-env /app/wait-for-it.sh .
COPY --chown=deployer:wheel --from=build-env /app/start.sh .
# Run under non-privileged user with minimal write permissions
USER deployer
#ENTRYPOINT ["./start.sh && bin/web"]
CMD ./start.sh && bin/app
