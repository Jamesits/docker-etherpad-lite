FROM node:8.16-jessie
MAINTAINER James Swineson <jamesswineson@gmail.com>

ENV ETHERPAD_VERSION 1.7.5

ENV NODE_ENV production

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl unzip mysql-client supervisor gzip git python libssl-dev pkg-config build-essential && \
    rm -r /var/lib/apt/lists/*

WORKDIR /opt/

RUN curl -SL \
    https://github.com/ether/etherpad-lite/archive/${ETHERPAD_VERSION}.zip \
    > etherpad.zip && unzip etherpad && rm etherpad.zip && \
    mv etherpad-lite-${ETHERPAD_VERSION} etherpad-lite

WORKDIR etherpad-lite

RUN bin/installDeps.sh \
    && rm settings.json
COPY entrypoint.sh /entrypoint.sh

RUN sed -i 's/^node/exec\ node/' bin/run.sh

VOLUME /opt/etherpad-lite/var
RUN ln -s var/settings.json settings.json
ADD supervisor.conf /etc/supervisor/supervisor.conf

EXPOSE 9001
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf", "-n"]
