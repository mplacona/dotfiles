#!/usr/bin/env sh

echo ""
echo "#############################"
echo "# Installing applications via cask from cask.sh"
echo "#############################"
echo ""

# get current location
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# *********************************
# Visual studio code
brew install --cask visual-studio-code

if [ -L ~/Library/Application\ Support/Code/user/settings.json ]; then
  echo "found old visual studio code settings. removing..."
  rm ~/Library/Application\ Support/Code/User/settings.json
fi

ln -s $DIR/visual-studio-code-settings.json ~/Library/Application\ Support/Code/User/settings.json

# *********************************
# fira code
echo "installing fira code"
brew tap caskroom/fonts
brew install --cask font-fira-code

# *********************************
# a better `cat`
brew install bat

brew install --cask docker
brew install --cask firefox
brew install --cask iterm2
brew install --cask alfred
brew install --cask zoomus
brew install --cask spotify
brew install --cask ngrok
brew install --cask spectacle

brew install --cask xquartz
brew install --cask inkscape
brew install --cask ultimaker-cura
brew install --cask angry-ip-scanner
