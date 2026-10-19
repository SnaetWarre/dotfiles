if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# Vite+ bin (https://viteplus.dev)
[[ -f "$HOME/.config/vite-plus/env" ]] && . "$HOME/.config/vite-plus/env"
