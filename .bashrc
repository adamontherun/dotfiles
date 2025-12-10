[[ $- != *i* ]] && return

for file in ~/.{bash_prompt,aliases,private}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

[[ -f "$HOME/.rokit/env" ]] && . "$HOME/.rokit/env"
[[ -f "$HOME/.aftman/env" ]] && . "$HOME/.aftman/env"
