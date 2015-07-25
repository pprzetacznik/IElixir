IElixir
=======

Jupyter's kernel for Elixir

[![Build Status](https://travis-ci.org/pprzetacznik/IElixir.svg)](https://travis-ci.org/pprzetacznik/IElixir)

##Getting Started

### Configure Jupyter

```Bash
$ git clone https://github.com/jupyter/notebook.git
$ cd notebook
$ mkvirtualenv jupyter-env
$ workon jupyter-env
$ pip install -r requirements.txt
```

### Configure IElixir

Clone IElixir repository and prepare the project
```Bash
$ git clone https://github.com/pprzetacznik/IElixir.git
$ mix deps.get
$ mix deps.compile
$ mix test
```

Create and edit `kernel.json` file

```Bash
$ mkdir ~/.ipython/kernels/ielixir
$ vim ~/.ipython/kernels/ielixir/kernel.json
```

Put into the file following content:
```Bash
{
  "argv": ["{PATH_TO_YOUR_IELIXIR_PROJECT}/start_script.sh", "{connection_file}"],
  "display_name": "ielixir",
  "language": "Elixir"
}
```

or simply run installation script to create this file:
```Bash
$ ./install_script.sh
```

Run Jupyter console with following line:
```Bash
(jupyter-env) $ jupyter console --kernel ielixir
```
