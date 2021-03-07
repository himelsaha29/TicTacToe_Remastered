# Executing the game:

## Install Löve:

### Debian based Linux

 `sudo apt-get install love`
 
### Red Hat Enterprise Linux
 
 Enable snapd: 
 
 `sudo yum install epel-release`
 
 `sudo yum install snapd`
 
 Enable main snap communication socket:
 
 `sudo systemctl enable --now snapd.socket`
 
 Enable classic snap support:
 
 `sudo ln -s /var/lib/snapd/snap /snap`
 
 Finally:
 
 `sudo snap install love2d`
 
 
 
 
## Run game:
 
 `love <path_to_game_ending_with_.love_extension>`
