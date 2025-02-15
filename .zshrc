#!/usr/bin/zsh
path+=('/home/tom/.local/bin')
export PATH
export EDITOR=nano
# source API keys as env vars
source ./.apikeys

# Function to scan given IP(s / range) for open port 22s
function scanssh {
    nmap "$@" -p 22 | grep -B4 open | grep for | cut -d " " -f 5;
}

# Function to get IP info (Org, location etc).
function ipinfo {
    curl -su $ipinfokey: ipinfo.io/$1
}

# Function to get IP info and extract ASN.
function asn {
    prefix=ipinfo.io
    suffix=/org
    if [[ -n "$1" ]]; then
        url=$prefix/$1$suffix
    else
        url=$prefix$suffix
    fi
    curl -su $ipinfokey: $url
}

# Function to delete a given line number in the known_hosts file.
function knownhostrm {
    re='^[0-9]+$'
    if ! [[ $1 =~ $re ]] ; then
        echo "error: line number missing" >&2;
    else
        sed -i "$1d" ~/.ssh/known_hosts
    fi
}

# Function to get a random number modulo X
function randNum {
    if [[ -z "$2" ]]; then
        if [[ -n "$1" ]];	then
            num=$1
            (( randNumber = $RANDOM % $num ))
            echo $randNumber
        else
            echo "Error: you didn't pass an argument" >&2
        fi
    else
        echo "Error: you passed too many arguments" >&2
    fi
}


## Generic Aliases
alias lsdir="ls -d */"
alias json2csv="jq -r '(map(keys) | add | unique) as \$cols | map(. as \$row | \$cols | map(\$row[.])) as \$rows | \$cols, \$rows[] | @csv'"
alias weather="curl 'wttr.in?F'"
# Alias for dotfile management (https://wiki.archlinux.org/title/Dotfiles#Tracking_dotfiles_directly_with_Git)
alias config='/usr/bin/git --git-dir=/home/tom/.dotfiles --work-tree=/home/tom'
alias john-task-report="task project:work end.after:today-1wk completed"
alias brownnoise="play -c 5 -n synth brown vol -20dB"

## Script dependent aliases
alias serverpass='echo "$workserversuffix" | xclip -selection c'
alias get-temp=/home/tom/Projects/Scripts/get-temps.sh

## Machine dependent aliases
# alias screens-on="xrandr --output HDMI1 --auto --output HDMI2 --auto;sleep 1;xrandr --output eDP1 --pos 0x1080 --size 2560x1440 --output HDMI1 --pos 2560x0 --size 1920x1080 --output HDMI2 --pos 640x0 --size 1920x1080"
# alias screens-off="xrandr --output HDMI1 --off --output HDMI2 --off"
# alias battery=/home/tom/Projects/Scripts/battery-charging-thresholds.sh
alias battery-set="sudo tlp setcharge 40 60"

## Jobhunt functions
function generateCV {
    pandoc -s -H ./CV.tex -o Thomas-Cronin-CV-$(basename $(pwd)).pdf ./CV.md
}
function generateCoverLetter {
    pandoc -s -H ./CoverLetter.tex -o CoverLetter-$(basename $(pwd)).pdf ./CoverLetter.md
}

# Create and send taskwarror task list to Remarkable
function TaskList {
    task sync
    outdir=$(mktemp --dir)
    task status:pending -WAITING +READY \( due.before=tomorrow or due.none: \) export | jq -r 'sort_by(-.urgency) | .[:20] | (["ID","Desc","Project","Urgency"] | (., map(length*"-"))), (.[] | [.id, .description, .project, .urgency]) | @tsv' | column -t -s $'\t' -c 80 -W 2,3 | pandoc -s -H ./TaskList.tex -o $outdir/TaskList.pdf
    remarkable-cli-tooling/resync.py -v --if-exists replace -r Remarkable push $outdir/TaskList.pdf
}

# Display on opening terminal
fortune -o -s fortunes | cowsay -f stegosaurus

### Below is automatic crap added for / by programs ###

# >>>> Vagrant command completion (start)
fpath=(/opt/vagrant/embedded/gems/2.3.4/gems/vagrant-2.3.4/contrib/zsh $fpath)
compinit
# <<<<  Vagrant command completion (end)

# Atuin init
eval "$(atuin init zsh)"

# pnpm
export PNPM_HOME="/home/tom/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
