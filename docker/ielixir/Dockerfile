ARG IELIXIR_REQUIREMENTS_DOCKER_VERSION
FROM pprzetacznik/ielixir-requirements:$IELIXIR_REQUIREMENTS_DOCKER_VERSION

ENV WORK_DIR=/opt

USER root

RUN apt install -y \
    libzmq3-dev \
    libsqlite3-dev

RUN set -xe \
  && curl -L https://github.com/pprzetacznik/IElixir/archive/refs/heads/master.zip -o ielixir.zip \
  && apt install -y unzip \
  && unzip ielixir.zip -d ielixir_tmp \
  && mv ielixir_tmp/IElixir-master ielixir \
  && rm -rf ielixir_tmp \
  && cd ielixir \
  && ls -alh \
  && mix local.hex --force \
  && mix local.rebar --force \
  && mix deps.get \
  && mix deps.compile \
  && ./install_script.sh \
  && conda install --quiet --yes 'jupyter_console'

USER $NB_UID

CMD ["start-notebook.sh"]
