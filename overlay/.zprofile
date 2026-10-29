#if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
#       Hyprland 
#fi

# Expose Flatpak desktop entries and personal app commands.
[ ! -r /etc/profile.d/flatpak.sh ] || . /etc/profile.d/flatpak.sh
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Source /etc/profile to ensure system paths (e.g. flatpak) are available
if [ -f /etc/profile ]; then
    source /etc/profile
fi
