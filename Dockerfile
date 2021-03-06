FROM node:6.9.4-slim
MAINTAINER db@reppa.net
WORKDIR /tmp
COPY webdriver-versions.js ./
ENV CHROME_PACKAGE="google-chrome-stable_79.0.3945.88-1_amd64.deb" NODE_PATH=/usr/local/lib/node_modules:/protractor/node_modules
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA8E81B4331F7F50 && \
    npm install -g protractor@5.4.2 minimist@1.2.0 && \
    node ./webdriver-versions.js --chromedriver 79.0.3945.36 && \
    webdriver-manager update && \
    #echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \
    #-o Acquire::Check-Valid-Until="false"
    echo 'Acquire::Check-Valid-Until no;' > /etc/apt/apt.conf.d/99no-check-valid-until && \
    echo deb http://archive.debian.org/debian jessie-backports main contrib non-free >> /etc/apt/sources.list && \
    cat /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y xvfb wget sudo && \
    apt-get install -y -t jessie-backports openjdk-8-jre && \
    apt-get install -y libgconf-2-4 && \
    wget https://github.com/webnicer/chrome-downloads/raw/master/x64.deb/${CHROME_PACKAGE} && \
    dpkg --unpack ${CHROME_PACKAGE} && \
    apt-get install -f -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    rm ${CHROME_PACKAGE} && \
    mkdir /protractor
COPY protractor.sh /
COPY environment /etc/sudoers.d/
# Fix for the issue with Selenium, as described here:
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null SCREEN_RES=1280x1024x24
WORKDIR /protractor
ENTRYPOINT ["/protractor.sh"]
