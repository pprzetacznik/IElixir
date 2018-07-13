FROM pprzetacznik/ielixir-requirements

USER root

RUN set -ex; \
		apt-get update; \
		apt-get install -y --no-install-recommends \
# Install Blas
    libblas-dev \
    liblapack-dev \
    libatlas-base-dev \
# # 		bzr \
# 		git \
# # 		mercurial \
# # 		openssh-client \
# # 		subversion \
# # 		\
# # 		procps \
	&& rm -rf /var/lib/apt/lists/*

USER $NB_UID

RUN set -xe \
  # && git clone https://github.com/pprzetacznik/IElixir.git \
  && curl -s https://api.github.com/repos/pprzetacznik/IElixir/releases/latest | grep "tarball_url" | sed -n -e 's/.*tarball_url": "\(.*\)".*/\1/p' | xargs -t curl -fSL -o ielixir.tar.gz \
  && mkdir ielixir \
  && tar -zxvf ielixir.tar.gz -C ielixir --strip-components=1 \
  && rm ielixir.tar.gz \
  && cd ielixir \
#  && cd IElixir \
  && ls -alh \
  && mix local.hex --force \
  && mix local.rebar --forcea \
  && mix deps.get \
  && mix deps.compile \
  && ./install_script.sh \
  && conda install --quiet --yes 'jupyter_console'

# CMD ["iex"]

# USER $NB_UID

CMD ["start-notebook.sh"]
