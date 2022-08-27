FROM python:3.9-alpine as build

RUN mkdir /app \
  && wget -P /tmp/ "https://github.com/Sennevds/system_sensors/archive/refs/heads/master.tar.gz" \
  && tar -xvzf /tmp/master.tar.gz -C /app --strip-components 1 \
  && /bin/ash -c 'set -ex && ARCH=`uname -m` && wget "https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-Linux-${ARCH/aarch64/arm64}" -O /app/envsubst' \
  && apk --update-cache add --virtual build-dependencies build-base linux-headers \
  && pip install -r /app/requirements.txt

FROM python:3.9-alpine
RUN apk add bash wireless-tools

WORKDIR /app

COPY --from=build /app /app
COPY --from=build /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY ./ ./
RUN chmod a+x ./system_sensors.sh
RUN chmod a+x ./envsubst
CMD ./system_sensors.sh

