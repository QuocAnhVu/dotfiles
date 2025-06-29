#! /usr/bin/zsh
source $(dirname $0)/_lib.sh

localrc="$XDG_CONFIG_HOME/localrc"

# https://mise.jdx.dev/getting-started.html
context 'Installing mise-en-place'
if ! mise -v; then
    curl https://mise.run | sh
else
    message 'Mise detected. No need to install.'
fi
message 'Appending $localrc.'
run unique_append $localrc << "END"
# mise-en-place version manager
(! command -v mise > /dev/null) || eval "$(mise activate $(basename $SHELL))"
END

context 'Installing Python'
if ! mise current python | rg '\d+\.\d+\.\d+' ; then
    # python build dependencies (https://github.com/pyenv/pyenv/wiki#suggested-build-environment)
    context 'Installing python build dependencies.'
    if rg --quiet 'Fedora|Red Hat|Rocky Linux' /etc/os-release; then
        run sudo dnf install -y make gcc zlib-devel bzip2 bzip2-devel \
            readline-devel sqlite sqlite-devel \
            openssl-devel tk-devel libffi-devel xz-devel
    elif rg --quiet 'Ubuntu|Debian' /etc/os-release; then
        run sudo apt install -y make build-essential libssl-dev zlib1g-dev \
            libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
            libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    else
        message 'Installing python build dependencies failed.'
    fi
    context 'Installing python with mise'
    run mise use -g python@3
else
    message 'Python detected. No need to install.'
fi
message 'Appending $localrc.'
run unique_append $localrc << "END"
# Python
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
END

context 'Installing NodeJS'
if ! mise current node | rg '\d+\.\d+\.\d+' ; then
    # nodejs build dependencies (https://github.com/nodejs/node/blob/master/BUILDING.md#building-nodejs-on-supported-platforms)
    context 'Installing nodejs build dependencies.'
    if rg --quiet 'Fedora|Red Hat' /etc/os-release; then
        run sudo dnf install -y python3 gcc-c++ make python3-pip gnupg2
    elif rg --quiet 'Ubuntu|Debian' /etc/os-release; then
        run sudo apt install -y python3 g++ make python3-pip gnupg
    else
        message 'Installing nodejs build dependencies failed.'
    fi
    context 'Installing nodejs with mise'
    run mise use -g node@lts
    context 'Switching to pnpm'
    run corepack enable pnpm
else
    message 'NodeJS detected. No need to install.'
fi
message 'Appending $localrc.'
run unique_append $localrc << "END"
# NodeJS
# pnpm
export PNPM_HOME="/home/quocanh/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
alias pn=pnpm
END

context 'Installing Go'
if ! mise current go | rg '\d+\.\d+\.\d+' ; then
    context 'Installing go with mise'
    run mise use -g go@1.21
    message 'Appending $localrc.'
    run unique_append $localrc << "END"
# Go
export GOPATH="$XDG_DATA_HOME/go"
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
END
else
    message 'Go detected. No need to install.'
fi

context 'Installing Rust'
if ! rustc --version | rg '\d+\.\d+\.\d+' ; then
    context 'Installing rust with rustup'
    run_noeval "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path
    message 'Appending $localrc.'
else
    message 'Rust detected. No need to install.'
fi
run unique_append $localrc << "END"
# Rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export PATH="$CARGO_HOME/bin":$PATH
END
