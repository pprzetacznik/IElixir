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

### Use IElixir

Run Jupyter console with following line:
```Bash
(jupyter-env) $ jupyter console --kernel ielixir
```

Run Jupyter Notebook with following line:
```Bash
(jupyter-env) $ jupyter notebook
```

Go to [http://localhost:8888/](http://localhost:8888/) site (by default) in your browser and pick IElixir kernel:

![Pick IElixir](/resources/jupyter_pick_kernel.png?raw=true)

Evaluate some commands in your new notebook:

![IElixir basics](/resources/jupyter_ielixir_basics.png?raw=true)
