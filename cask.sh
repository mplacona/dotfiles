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
brew cask uninstall --force visual-studio-code && brew cask install visual-studio-code

if [ -L ~/Library/Application\ Support/Code/user/settings.json ]; then
  echo "found old visual studio code settings. removing..."
  rm ~/Library/Application\ Support/Code/User/settings.json
fi

ln -s $DIR/visual-studio-code-settings.json ~/Library/Application\ Support/Code/User/settings.json

# *********************************
# fira code
echo "installing fira code"
brew tap caskroom/fonts
brew cask install font-fira-code

# *********************************
# a better `cat`
brew install bat

brew cask install docker
brew cask install firefox
brew cask install iterm2
brew cask install alfred
brew cask install zoomus
brew cask install spotify
brew cask install ngrok
brew cask install spectacle

brew cask install xquartz
brew cask install inkscape
brew cask install ultimaker-cura
brew install flux
