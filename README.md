IElixir
=======

Jupyter's kernel for Elixir

[![Build Status](https://travis-ci.org/pprzetacznik/IElixir.svg)](https://travis-ci.org/pprzetacznik/IElixir)
[![Inline docs](http://inch-ci.org/github/pprzetacznik/IElixir.svg?branch=master)](http://inch-ci.org/github/pprzetacznik/IElixir)
[![Coverage Status](https://coveralls.io/repos/github/pprzetacznik/IElixir/badge.svg?branch=master)](https://coveralls.io/github/pprzetacznik/IElixir?branch=master)
[![Join the chat at https://gitter.im/pprzetacznik/IElixir](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/pprzetacznik/IElixir?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Hex: https://hex.pm/packages/ielixir.

Please see generated documentation for implementation details: http://hexdocs.pm/ielixir/.

## Getting Started

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

Running all tests, including longer ones that requires more time for evaluation:
```Bash
$ mix test --include skip
```

There may be also need to install rebar before IElixir installation, you can do this with command:
```Bash
mix local.rebar --force
```
After this you may need to add `~/.mix/` to your `$PATH` variable if you don't have `rebar` visible yet outside `~/.mix/` directory.

#### Install Kernel

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

![IElixir basics](/resources/jupyter_ielixir_basics.png?raw=true)

### Developement mode

If you want to see requests passing logs please use `dev` environment to see what is happening in the background.

```Bash
(jupyter-env) $ MIX_ENV=dev jupyter console --kernel ielixir
```

### Generate documentation

Run following command and see `doc` directory for generated documentation in HTML:
```Bash
$ mix docs
```

### Some issues

There may be need to run IElixir kernel with specific erlang attribute which can be turned on by setting variable:
```Bash
ELIXIR_ERL_OPTIONS="-smp enable"
```
This option has been included inside `install_script.sh` and `start_script.sh` scripts.

### References

Some useful articles:

* [IElixir Notebook in Docker](https://mattvonrocketstein.github.io/heredoc/ielixir-notebook-in-docker.html)
* [Hydrogen plugin for Atom](https://atom.io/packages/hydrogen)
* [Installation guide](http://blog.jonharrington.org/elixir-and-jupyter/)

I was inspired by following codes and articles:

* [https://github.com/pminten/ielixir](https://github.com/pminten/ielixir)
* [https://github.com/robbielynch/ierlang](https://github.com/robbielynch/ierlang)
* [https://github.com/dsblank/simple_kernel](https://github.com/dsblank/simple_kernel)
* [http://andrew.gibiansky.com/blog/ipython/ipython-kernels/](http://andrew.gibiansky.com/blog/ipython/ipython-kernels/)
* [https://ipython.org/ipython-doc/dev/development/messaging.html](https://ipython.org/ipython-doc/dev/development/messaging.html)

### License

Copyright 2015 Piotr Przetacznik

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
