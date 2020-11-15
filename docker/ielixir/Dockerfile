FROM pprzetacznik/ielixir-requirements

ENV WORK_DIR=/opt

USER root

RUN apt install -y \
    libzmq3-dev \
    libsqlite3-dev

RUN set -xe \
  && curl -s https://api.github.com/repos/pprzetacznik/IElixir/releases/latest | grep "tarball_url" | sed -n -e 's/.*tarball_url": "\(.*\)".*/\1/p' | xargs -t curl -fSL -o ielixir.tar.gz \
  && mkdir ielixir \
  && tar -zxvf ielixir.tar.gz -C ielixir --strip-components=1 \
  && rm ielixir.tar.gz \
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
