#!/usr/bin/env sh

echo "\n"
echo "#############################"
echo "# Installing various programs from brew.sh"
echo "#############################"
echo "\n"

# *********************************
# zsh
brew install zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting
# set it as default shell
chsh -s /bin/zsh

# *********************************
# Power Level 9K
brew tap sambadevi/powerlevel9k
brew install powerlevel9k


# *********************************
# highlight

echo $'installing highlight'
brew unlink highlight
brew install highlight

# *********************************
# jq command line json parser
brew install jq

# *********************************
# Programming bits
echo $'installing programming bits'
brew install dart git heroku heroku-node httpie node postgresql pyenv rbenv sqlite twilio vim htop spectacle java ngrok

# *********************************
# Interface bits
echo $'installing interface bits'
brew install alfred inkscape