IElixir
=======

Jupyter's kernel for Elixir.

[![Build Status](https://travis-ci.org/pprzetacznik/IElixir.svg?branch=master)](https://travis-ci.org/pprzetacznik/IElixir)
[![IElixir CI](https://github.com/pprzetacznik/IElixir/workflows/IElixir%20CI/badge.svg)](https://github.com/pprzetacznik/IElixir/actions?query=workflow%3A"IElixir+CI")
[![Inline docs](http://inch-ci.org/github/pprzetacznik/IElixir.svg?branch=master)](http://inch-ci.org/github/pprzetacznik/IElixir)
[![Coverage Status](https://coveralls.io/repos/github/pprzetacznik/IElixir/badge.svg?branch=master)](https://coveralls.io/github/pprzetacznik/IElixir?branch=master)
[![Join the chat at https://gitter.im/pprzetacznik/IElixir](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/pprzetacznik/IElixir?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Hex: https://hex.pm/packages/ielixir.
Please see generated documentation for implementation details: http://hexdocs.pm/ielixir/.
Docker: [pprzetacznik/ielixir](https://hub.docker.com/r/pprzetacznik/ielixir).

## Getting Started

### Table of contents

* [Configure Jupyter](#configure-jupyter)
* [Configure IElixir](#configure-ielixir)
* [Install Kernel](#install-kernel)
* [Use IElixir](#use-ielixir)
* [Package management with Boyle](#package-management-with-boyle)
* [Developement mode](#developement-mode)
* [Generate documentation](#generate-documentation)
* [Docker](#docker)
* [Some issues](#some-issues)
* [Publish new release](#publish-new-release)
* [Contribution](#contribution)
* [References](#references)
* [License](#license)

### Configure Jupyter

I recommend you to use `virtualenv` and `virtualenvwrapper` for this project to isolate dependencies between this and other projects however you may also work without this if you don't like this.
```Bash
$ pip install virtualenv virtualenvwrapper
```
Now you need to load `virtualenvwrapper.sh` script into your current environment. I recommend you to add this like as well to the `~/.bash_profile.sh` script to have this script loaded every time you open fresh bash.
```Bash
$ source /usr/local/bin/virtualenvwrapper.sh
```

Now using our new tools we can easily create isolated virtual environment for jupyter installation.
```Bash
$ mkvirtualenv jupyter-env
$ workon jupyter-env
(jupyter-env) $ pip install jupyter
```

### Configure IElixir

Clone IElixir repository and prepare the project
```Bash
$ git clone https://github.com/pprzetacznik/IElixir.git
$ cd IElixir
$ mix deps.get
$ mix test
$ MIX_ENV=prod mix compile
```

If you're meeting problem with missing zeromq header files then you should install it. [More](#zeromq-header-files-missing).

Running all tests, including longer ones that requires more time for evaluation:
```Bash
$ mix test --include skip
```

There may be also need to install rebar before IElixir installation, you can do this with command:
```Bash
mix local.rebar --force
```
After this you may need to add `~/.mix/` to your `$PATH` variable if you don't have `rebar` visible yet outside `~/.mix/` directory.

### Install Kernel

Simply run installation script to create file `kernel.json` file in `./resouces` directory and bind it to the jupyter:
```Bash
$ ./install_script.sh
```

### Use IElixir

Run Jupyter console with following line:
```Bash
(jupyter-env) $ jupyter console --kernel ielixir
```

To quit IElixir type `Ctrl-D`.

Run Jupyter Notebook with following line:
```Bash
(jupyter-env) $ jupyter notebook resources/example.ipynb
```

Go to [http://localhost:8888/](http://localhost:8888/) site (by default) in your browser and pick IElixir kernel:

![Pick IElixir](/resources/jupyter_pick_kernel.png?raw=true)

Evaluate some commands in your new notebook:

![IElixir basics](/resources/jupyter_ielixir_matrex_demo.png?raw=true)

### Magic commands

You can also use `ans` variable to access output of previous cell. Moreover, if you want to access any cell which you can do it using it's number by calling `out` map, eg. `out[1]`.

### Package management with Boyle

You can manage your packages in runtime with Boyle. Name of the package honours remarkable chemist, Robert Boyle. This package allows you to manage your Elixir virtual enviromnent without need of restarting erlang virtual machine. Boyle installs environment into `./envs/you_new_environment` directory and creates new mix project there with requested dependencies. It keeps takes care of fetching, compiling and loading/unloading modules from dependencies list of that environment.

You can also use this environment as a separate mix project and run it interactively with `iex -S mix` from the environment directory.


Creating new Elixir virtual environment
```Elixir
iex> Boyle.mk("my_new_environment")
{:ok, ["my_new_environment"]}
```

List available virtual environments
```Elixir
iex> Boyle.list()
{:ok, ["my_new_environment"]}
```

Activate virtual environment
```Elixir
iex> Boyle.activate("my_new_environment")
:ok
```

Install new package in virtual environment and use new package
```Elixir
iex> Boyle.install({:number, "~> 0.5.7"})
:ok
iex> Number.Currency.number_to_currency(2034.46)
"$2,034.46"
```

Deactivate virtual environment and unload packages installed within that virtual environment
```Elixir
iex> Boyle.deactivate()
:ok
iex> Number.Currency.number_to_currency(2034.46)
** %UndefinedFunctionError{arity: 1, exports: nil, function: :number_to_currency, module: Number.Currency, reason: nil}
```

Additional resources:
* [Notebook with Boyle examples](https://github.com/pprzetacznik/IElixir/blob/master/resources/boyle%20example.ipynb)
* [Notebook with Boyle examples with usage of Matrex library](https://github.com/pprzetacznik/IElixir/blob/master/resources/boyle%20example%20-%20matrex%20installation%20and%20usage.ipynb)
* [Notebook with inline image examples with usage of Gnuplot library](https://github.com/pprzetacznik/IElixir/blob/master/resources/inlineplot%20example%20-%20gnuplot.ipynb)

### Developement mode

If you want to see requests passing logs please use `dev` environment to see what is happening in the background.

```Bash
(jupyter-env) $ MIX_ENV=dev jupyter console --kernel ielixir
```

### Generate documentation

Run following command and see `doc` directory for generated documentation in HTML:
```Bash
$ MIX_ENV=docs mix docs
```

### Docker

You can find docker image at [pprzetacznik/ielixir](https://hub.docker.com/r/pprzetacznik/ielixir).

Running jupyter notebook:
```
$ docker run -p 8888:8888 --hostname localhost -v /my/workspace:/home/jovyan/work pprzetacznik/ielixir
```

Docker image is based on following images:
* [jupyter/base-notebook image](https://hub.docker.com/r/jupyter/base-notebook/) - this is image use as a base for ielixir image,
* [elixir image](https://hub.docker.com/_/elixir/) - some installation parts were taken from dockerfile used for this image,
* [pprzetacznik/ielixir-requirements image](https://hub.docker.com/r/pprzetacznik/ielixir-requirements/) - this image resolves all dependencies for jupyter and elixir so only IElixir installation is left.

If you would like to make some changes to the images you can find dockerfiles in:
* docker/ielixir - for dockerfile source of pprzetacznik/ielixir image,
* docker/ielixir-requirements - for dockerfile source of pprzetacznik/ielixir-requirements image.

Elixir builds taken from [hex.pm builds.txt](https://repo.hex.pm/builds/elixir/builds.txt).

#### Other docker images worth seeing

* [Dockerfile for smaller image based on alpine](https://github.com/cprieto/docker-jupyter/blob/master/elixir/Dockerfile)

### Some issues

#### ZeroMQ header files missing

```
===> /home/travis/build/bryanhuntesl/IElixir/deps/erlzmq/c_src/erlzmq_nif.c:24:17: fatal error: zmq.h: No such file or directory
 #include "zmq.h"
                 ^
compilation terminated.
```

Install ZeroMQ development package for you operating system.

* On RHEL/Centos/Fedora `dnf install zeromq-devel`
* On OSX `brew install zmq`
* On Ubuntu `apt-get install libzmq3-dev`
* On Alpine Linux `apk add zeromq-dev`

#### Erlang configuration

There may be need to run IElixir kernel with specific erlang attribute which can be turned on by setting variable:
```Bash
ELIXIR_ERL_OPTIONS="-smp enable"
```
This option has been included inside `install_script.sh` and `start_script.sh` scripts.

#### Listing all available jupyter kernels.

```Bash
$ jupyter kernelspec list
```

### Publish new release

```Bash
$ git tag v1.0.1
$ git push origin v1.0.1
```

### Contribution

* Try to write some description of the feature or bug fix you're working in pull request's description and concise description of new modules or functions in moduledoc annotations,
* Please follow Elixir style guides to keep style clear, consider Elixir and Phoenix source code as the style ground truth,
* Keep as little comments as you can, comments tend to expire so try to use doctests instead to show how your code works,
* Write some unit tests for your code but don't try to test private functions, class tests are bad and units tests are good - https://blog.arkency.com/2014/09/unit-tests-vs-class-tests/

### References

Some useful articles:

* [IElixir Notebook in Docker](https://mattvonrocketstein.github.io/heredoc/ielixir-notebook-in-docker.html)
* [Hydrogen plugin for Atom](https://atom.io/packages/hydrogen)
* [Installation guide](http://blog.jonharrington.org/elixir-and-jupyter/)
* [Jupyter Notebooks with Elixir and RDF](https://medium.com/@tonyhammond/jupyter-notebooks-with-elixir-and-rdf-598689c2dad3)
* [Making Graphs using Elixir inside Jupyter Notebook snapshot from 2019/04 on Internet Archive](https://web.archive.org/web/20191228085409/http://aipotato.com/2019/04/making-graphs-using-elixir-inside-jupyter-notebook/)

I was inspired by following codes and articles:

* [https://github.com/pminten/ielixir](https://github.com/pminten/ielixir)
* [https://github.com/robbielynch/ierlang](https://github.com/robbielynch/ierlang)
* [https://github.com/dsblank/simple_kernel](https://github.com/dsblank/simple_kernel)
* [http://andrew.gibiansky.com/blog/ipython/ipython-kernels/](http://andrew.gibiansky.com/blog/ipython/ipython-kernels/)
* [https://ipython.org/ipython-doc/dev/development/messaging.html](https://ipython.org/ipython-doc/dev/development/messaging.html)

### License

Copyright 2015 Piotr Przetacznik.
IElixir source code is released under Apache 2 License.
Check [NOTICE](NOTICE) and [LICENSE](LICENSE) files for more information.
