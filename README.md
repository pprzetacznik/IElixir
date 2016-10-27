IElixir
=======

Jupyter's kernel for Elixir

[![Build Status](https://travis-ci.org/pprzetacznik/IElixir.svg)](https://travis-ci.org/pprzetacznik/IElixir)
[![Inline docs](http://inch-ci.org/github/pprzetacznik/IElixir.svg?branch=master)](http://inch-ci.org/github/pprzetacznik/IElixir)
[![Coverage Status](https://coveralls.io/repos/github/pprzetacznik/IElixir/badge.svg?branch=master)](https://coveralls.io/github/pprzetacznik/IElixir?branch=master)
[![Join the chat at https://gitter.im/pprzetacznik/IElixir](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/pprzetacznik/IElixir?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Hex: https://hex.pm/packages/ielixir.

Please see generated documentation for implementation details: http://hexdocs.pm/ielixir/.

##Getting Started

### Configure Jupyter

```Bash
$ git clone https://github.com/jupyter/notebook.git
$ cd notebook
$ mkvirtualenv jupyter-env
$ workon jupyter-env
(jupyter-env) $ pip install --pre -e .
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

#### Install Kernel

Simply run installation script to create this file:
```Bash
$ ./install_script.sh
```

### Use IElixir

Run Jupyter console with following line:
```Bash
(jupyter-env) $ jupyter console --kernel ielixir
```

Run Jupyter Notebook with following line:
```Bash
(jupyter-env) $ jupyter notebook resources/example.ipynb
```

Go to [http://localhost:8888/](http://localhost:8888/) site (by default) in your browser and pick IElixir kernel:

![Pick IElixir](/resources/jupyter_pick_kernel.png?raw=true)

Evaluate some commands in your new notebook:

![IElixir basics](/resources/jupyter_ielixir_basics.png?raw=true)

### Generate documentation

Run following command and see `doc` directory for generated documentation in HTML:
```Bash
$ mix docs
```

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
