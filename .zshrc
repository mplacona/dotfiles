alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
PATH=$PATH:~/Installs/depot_tools
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

