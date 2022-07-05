# dotfiles
Configuration files used in my systems

## Steps for cygwin or Ubuntu

1. Add the following lines to the ~/.bashrc

```shell
source /path/to/dotfiles/.bashrc.common
source /path/to/dotfiles/.bashrc.work
or
source /path/to/dotfiles/.bashrc.home1
```

1. Copy .tmux.conf to ~

```shell
cp .tmux.conf ~
```

1. Copy .minttyrc to ~ (Only for Cygwin)

```shell
cp .minttyrc ~
```

1. Restart cygwin (Only for Cygwin)

1. Clone Vundle for vim plugin management

```shell
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

1. Create .vimrc at ~ with following content

```shell
source /path/to/dotfiles/.vimrc.common.plugins
source /path/to/dotfiles/.vimrc.common
```
1. Install the vim plugins


## Neovim configuration

1. Create the init.vim file in ~\AppData\Local\nvim\ folder
1. Include the following configurations

```
source e:\dotfiles\.neovim.plugins
source e:\dotfiles\.vimrc.common
source e:\dotfiles\.neovim.vim
```

Note: I've cloned the repo to E:\dotfiles\

## Special conf for RESMED

1. Setup cygwin git
    - mkdir ~/bin
	- ln -s symlink git -> windows git
    - ln -s symlink stlink
    - create wscons script

```shell
#!/bin/bash
time env PATH="/cygdrive/c/Users/pradeepas/AppData/Local/Programs/Git/cmd":/cygdrive/c/Python27 python.exe c:/Python27/Scripts/scons $*
```

1. Patch PlatformDeps.py in figshell

```
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../External/mdaformatter/Export/Cygwin')))
```

1. Create ~/.vim/after/plugin/my_conf.vim with following content

```shell
source /cygdrive/c/src/dotfiles/resmed.vim
```
