# Completion menu: enable selection and fix highlighting (works in Ghostty)
# Ghostty often doesn't show standout/reverse for the selected line, so set explicit colors.
zstyle ':completion:*' menu select
# ma = menu active (selected item). Use explicit bg/fg so Ghostty shows it.
# Red background (really: slightly transparent/washed out "red" from 256 palette), white foreground for the menu active item
zstyle ':completion:*' list-colors 'ma=48;5;52;38;5;15'
