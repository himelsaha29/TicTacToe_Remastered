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
 
 
 ### Fedora based Linux
 
 Enable snapd: 
 
 `sudo dnf install snapd`
 
 Restart your system, to ensure snap’s paths are updated correctly. 
 
 To enable classic snap support, enter the following to create a symbolic link between `/var/lib/snapd/snap` and `/snap`: 
 
 `sudo ln -s /var/lib/snapd/snap /snap`
 
 Finally:
 
 `sudo snap install love2d`
 
 
 
## Run game:
 
 `love <path_to_game_ending_with_.love_extension>`
