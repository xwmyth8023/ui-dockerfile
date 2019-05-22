#image from ubuntu:xenial
FROM ubuntu:xenial

#user is root
USER root

#APPDIR is /opt/app/current
ENV APPDIR /opt/app/current

#LANG is C.UTF-8
ENV LANG C.UTF-8
#JAVA version is 8u121
ENV JAVA_VERSION 8u121
#JAVA_HOME is /usr/lib/jvm/java-8-openjdk-amd64/jre
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre
#Firefox version
ENV FIREFOX_VERSION=48.0
#Geckodriver verison
ENV GECKODRIVER_VERSION=0.16.0
#Selenium server standlone version
ENV SELENIUM_SHORT_VER=3.4
ENV SELENIUM_LONG_VER=selenium-server-standalone-3.4.0.jar
#Chrome driver version
ENV CHROMEDRIVER_VERSION=2.30
#Chrome version
ENV CHROME_VERSION=59.0.3071.86
#node version
ENV NODE_VERSION=6.11.3

# install ca-certificates,curl, wget, bzip2, unzip xz-utils
RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		wget \
		bzip2 \
		unzip \
		xz-utils \
	&& rm -rf /var/lib/apt/lists/*

# config docker java home
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

# install openjdk8-jre-headless
RUN set -x \
    && apt-get update \
	&& apt-get install -y \
        openjdk-8-jre-headless \
        ca-certificates-java \
	&& rm -rf /var/lib/apt/lists/* \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

#config ca-certificates-java.postinst
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

#install firefox
RUN apt-get update \
    && apt-get install -y \
        libxcomposite-dev \
        libasound2-dev \
        libdbus-glib-1-dev \
        libgtk2.0-0 \
	libgtk-3-dev \
    && wget --no-verbose -O /tmp/firefox.tar.bz2 https://ftp.mozilla.org/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 \
    && rm -rf /opt/firefox \
    && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
    && rm /tmp/firefox.tar.bz2 \
    && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
    && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/local/bin/firefox

#install firefox driver
RUN wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v$GECKODRIVER_VERSION/geckodriver-v$GECKODRIVER_VERSION-linux64.tar.gz \
    && rm -rf /opt/geckodriver \
    && tar -C /opt -zxf /tmp/geckodriver.tar.gz \
    && rm /tmp/geckodriver.tar.gz \
    && mv /opt/geckodriver /opt/geckodriver-$GECKODRIVER_VERSION \
    && chmod 755 /opt/geckodriver-$GECKODRIVER_VERSION \
    && ln -fs /opt/geckodriver-$GECKODRIVER_VERSION /usr/local/bin/geckodriver

#install chrome
RUN \
    apt-get -yq install gconf-service libgconf-2-4 libpango1.0-0 fonts-liberation xdg-utils libasound2 && \
    apt-get -yq install libxss1 libappindicator1 libindicator7 &&   \
    wget --no-verbose -O /tmp/google-chrome.deb https://www.slimjet.com/chrome/download-chrome.php?file=lnx%2Fchrome64_$CHROME_VERSION.deb &&  \
    dpkg -i /tmp/google-chrome.deb &&   \
    apt-get install -f &&   \
    echo GOOGLE CHROME INSTALLED

#install chrome driver
RUN \
    apt-get -yq install unzip && \
    wget --no-verbose -N http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip &&  \
    chmod +x chromedriver && \
    mv -f chromedriver /usr/local/share/chromedriver && \
    ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver &&  \
    ln -s /usr/local/share/chromedriver /usr/bin/chromedriver &&  \
    echo CHROMEDRIVER INSTALLED

#install xvfb
RUN apt-get -qqy install xvfb

#install nodejs
RUN \
  echo INSTALLING NODE && \
  apt-get -y install nodejs && \
  apt-get -y install npm && \
  ln -s /usr/bin/nodejs /usr/bin/node && \
  echo CHECKING NODE && \
  node --version && \
  npm install -g n && \
  n $NODE_VERSION && \
  mkdir -p /opt/app/current && \
  mkdir -p /var/log/nodejs && \
  echo DIRECTORIES BUILT && \
  apt-get update && \
  echo APT-GET UPDATED && \
  apt-get -yq install build-essential curl git netcat  && \
  apt-get -yq install chrpath libssl-dev libxft-dev && \
  apt-get -yq install libfreetype6 libfreetype6-dev && \
  apt-get -yq install libfontconfig1 libfontconfig1-dev && \
  echo APT-GET PACKAGES INSTALLED && \
  apt-get clean && \
  echo APT-GET CLEANED && \
  cd ~ && \
  wget --no-verbose http://selenium-release.storage.googleapis.com/$SELENIUM_SHORT_VER/$SELENIUM_LONG_VER && \
  mv $SELENIUM_LONG_VER /usr/local/share && \
  ln -sf /usr/local/share/$SELENIUM_LONG_VER /usr/local/bin && \
  echo SELENIUM INSTALLED && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  echo TMP FILES CLEANED && \
  npm install -g nightwatch && \
  echo NPM INSTALLED

#work dirctory is APPDIR
WORKDIR $APPDIR

#run docker-shell
ENTRYPOINT ["docker-shell"]

# run -t when image start
CMD ["-t"]

#add host file ./docker/docker-shell.sh to docker file /usr/bin/docker-shell
ADD ./docker/docker-shell.sh /usr/bin/docker-shell
#let /usr/bin/docker-shell can be run.
RUN chmod +x /usr/bin/docker-shell
#add host file ./package.json to docker $APPDIR/package.json
ADD ./package.json $APPDIR/package.json
#add host file ./.npmrc to docker $APPDIR/.npmrc
ADD ./.npmrc $APPDIR/.npmrc
#run npm install
RUN npm install
#add host *.* to docker $APPDIR
ADD . $APPDIR

