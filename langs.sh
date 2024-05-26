#! /usr/bin/zsh
source $(dirname $0)/_lib.sh

localrc="$XDG_CONFIG_HOME/localrc"

# https://mise.jdx.dev/getting-started.html
context 'Installing mise-en-place'
if rg --quiet 'Fedora|Red Hat' /etc/os-release; then
    run sudo dnf install -y dnf-plugins-core
    run sudo dnf config-manager --add-repo https://mise.jdx.dev/rpm/mise.repo
    run sudo dnf install -y mise
elif rg --quiet 'Ubuntu|Debian' /etc/os-release; then
    run apt update -y && apt install -y gpg sudo wget curl
    run sudo install -dm 755 /etc/apt/keyrings
    run wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
    run echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    run sudo apt update
    run sudo apt install -y mise
fi
message 'Appending $localrc.'
run unique_append $localrc << "END"
# mise-en-place version manager
eval "$(mise activate zsh)"
END

context 'Installing Python'
if ! mise current python | rg '\d+\.\d+\.\d+' ; then
    # python build dependencies (https://github.com/pyenv/pyenv/wiki#suggested-build-environment)
    context 'Installing python build dependencies.'
    if rg --quiet 'Fedora|Red Hat' /etc/os-release; then
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
    run mise use -g python@3.11
    message 'Appending $localrc.'
    run unique_append $localrc << "END"
# Python
export PYTHON_HISTORY="$XDG_CACHE_HOME/python_history"
END
else
    message 'Python detected. No need to install.'
fi

context 'Installing NodeJS'
if ! mise current node | rg '\d+\.\d+\.\d+' ; then
    # nodejs build dependencies (https://github.com/nodejs/node/blob/master/BUILDING.md#building-nodejs-on-supported-platforms)
    context 'Installing nodejs build dependencies.'
    if rg --quiet 'Fedora|Red Hat' /etc/os-release; then
        run sudo dnf install -y python3 gcc-c++ make python3-pip
    elif rg --quiet 'Ubuntu|Debian' /etc/os-release; then
        run sudo apt install -y python3 g++ make python3-pip
    else
        message 'Installing nodejs build dependencies failed.'
    fi
    context 'Installing nodejs with mise'
    run mise use -g node@lts
    context 'Switching to pnpm'
    run corepack enable pnpm
    message 'Appending $localrc.'
    run unique_append $localrc << "END"
# NodeJS
alias pn = pnpm
END
else
    message 'NodeJS detected. No need to install.'
fi

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
    run_noeval 'curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh'
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path
    message 'Appending $localrc.'
    run unique_append $localrc << "END"
# Rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export PATH="$CARGO_HOME/bin":$PATH
END
else
    message 'Rust detected. No need to install.'
fi
