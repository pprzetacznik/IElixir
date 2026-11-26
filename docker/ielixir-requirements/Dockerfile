FROM jupyter/base-notebook

USER root

ENV WORK_DIR=/opt
ARG ERL_VERSION_SHORT=29
ARG ERL_VERSION=29.1.3
ARG ELIXIR_VERSION=1.20.5
ENV ERL_TOP=$WORK_DIR/otp \
    ELIXIR_TOP=$WORK_DIR/elixir
ENV PATH=$ERL_TOP/target/bin:$ELIXIR_TOP/bin:$PATH \
    ERL_VERSION_SHORT=$ERL_VERSION_SHORT \
    ERL_VERSION=$ERL_VERSION \
    ELIXIR_VERSION=$ELIXIR_VERSION

RUN set -xe \
  && apt-get update \
  && apt install -y --no-install-recommends \
    git \
    curl \
    wget \
    unzip \
    autoconf \
    g++ \
    gcc \
    libncurses-dev \
    libssl-dev \
    libxslt-dev \
    libwxbase3.0-dev \
    make \
    gcc-mingw-w64

RUN mkdir -p $WORK_DIR \
  && cd $WORK_DIR \
  && wget https://github.com/erlang/otp/archive/refs/tags/OTP-${ERL_VERSION}.zip -O otp.zip \
  && unzip otp.zip -d $WORK_DIR \
  && mv $WORK_DIR/otp-OTP-$ERL_VERSION $ERL_TOP \
  && rm otp.zip

RUN cd $ERL_TOP \
  && ./otp_build autoconf \
  && ./configure --prefix=$ERL_TOP/target \
  && make \
  && make install

RUN cd $WORK_DIR \
  && wget https://builds.hex.pm/builds/elixir/v${ELIXIR_VERSION}-otp-${ERL_VERSION_SHORT}.zip -O elixir.zip \
  && unzip elixir.zip -d $ELIXIR_TOP \
  && rm elixir.zip

USER $NB_UID

CMD ["iex"]
