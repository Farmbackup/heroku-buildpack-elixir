function rust_tarball_version() {
  echo "stable"
}

function download_rust() {
  mkdir -p "$(rust_cache_path)"
  local rust_install_script_url="https://sh.rustup.rs"
  local rust_install_script_path="$(rust_cache_path)/rustup-init.sh"

  if [ ! -f "$rust_install_script_path" ]; then
    output_section "Fetching Rust installation script from $rust_install_script_url"
    curl -sSf "$rust_install_script_url" -o "$rust_install_script_path" || exit 1
  else
    output_section "Using cached Rust installation script"
  fi
}

function install_rust() {
  output_section "Installing Rust $(rust_tarball_version)"

  download_rust

  rm -rf "$(runtime_rust_path)"
  mkdir -p "$(runtime_rust_path)"

  export CARGO_HOME="$(runtime_rust_path)/cargo"
  export RUSTUP_HOME="$(runtime_rust_path)/rustup"
  mkdir -p "$CARGO_HOME" "$RUSTUP_HOME"

  export RUSTLER_NIF_VERSION=2.16

  if bash "$(rust_cache_path)/rustup-init.sh" -y --default-toolchain "$(rust_tarball_version)" 2>&1 | tee /tmp/rustup-install.log; then
    echo "Rust installation succeeded."
  else
    echo "Rust installation failed. Check the details below:"
    cat /tmp/rustup-install.log
    exit 1
  fi

  export PATH="$CARGO_HOME/bin:$PATH"
  output_section "Rust $(rust_tarball_version) installed at $CARGO_HOME/bin"
}

function verify_cargo_installation() {
  if ! command -v cargo &>/dev/null; then
    output_section "Cargo not found in PATH. Ensure it is properly installed and accessible."
    exit 1
  else
    output_section "Cargo found at $(command -v cargo)"
  fi
}
