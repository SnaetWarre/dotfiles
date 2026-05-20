#!/usr/bin/env sh
set -eu

project="$HOME/Projects/Rust/hypr-gravity"
binary="$project/target/release/hypr-gravity"

if [ ! -x "$binary" ]; then
    notify-send "hypr-gravity" "Release binary missing, building it now"
    cargo build --release --manifest-path "$project/Cargo.toml"
fi

"$binary" run
