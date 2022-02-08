#!/usr/bin/zsh
path+=('/home/tom/.local/bin')
export PATH
export EDITOR=nano
# source API keys as env vars
source .apikeys

# Function to scan given IP(s / range) for open port 22s
function scanssh () {
	nmap "$@" -p 22 | grep -B4 open | grep for | cut -d " " -f 5;
}

# Function to get IP info (Org, location etc).
function ipinfo() {
	curl -su $ipinfokey: ipinfo.io/$1
}

# Function to get IP info and extract ASN.
function asn() {
	prefix=ipinfo.io
	suffix=/org
	if [[ -n "$1" ]]
		then
			url=$prefix/$1$suffix
		else
			url=$prefix$suffix
	fi
        curl -su $ipinfokey: $url
}

# Function to delete a given line number in the known_hosts file.
function knownhostrm() {
	re='^[0-9]+$'
 	if ! [[ $1 =~ $re ]] ; then
		echo "error: line number missing" >&2;
	else
		sed -i "$1d" ~/.ssh/known_hosts
	fi
}


## Generic Aliases
alias lsdir="ls -d */"
alias json2csv="jq -r '(map(keys) | add | unique) as \$cols | map(. as \$row | \$cols | map(\$row[.])) as \$rows | \$cols, \$rows[] | @csv'"
alias weather="curl 'wttr.in?F'"
# Alias for dotfile management (https://wiki.archlinux.org/title/Dotfiles#Tracking_dotfiles_directly_with_Git)
alias config='/usr/bin/git --git-dir=/home/tom/.dotfiles --work-tree=/home/tom'

## Script dependent aliases
alias serverpass="echo $workserversuffix | xclip -selection c"
alias get-temp=/home/tom/Projects/Scripts/get-temps.sh

## Machine dependent aliases
# alias screens-on="xrandr --output HDMI1 --auto --output HDMI2 --auto;sleep 1;xrandr --output eDP1 --pos 0x1080 --size 2560x1440 --output HDMI1 --pos 2560x0 --size 1920x1080 --output HDMI2 --pos 640x0 --size 1920x1080"
# alias screens-off="xrandr --output HDMI1 --off --output HDMI2 --off"
# alias battery=/home/tom/Projects/Scripts/battery-charging-thresholds.sh
alias battery-set="sudo tlp setcharge 40 60"

# Display on opening terminal
fortune -o -s fortunes | cowsay -f stegosaurus
