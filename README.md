# Run install script via curl

```sh
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl
bash -ci "$(curl -fsSL https://raw.github.com/QuocAnhVu/dotfiles/master/do_all.sh)"
```