#!/bin/sh
# Amnezia-UI Universal v3.1.0 - Modern Merlin Install Script
# Following YazFi/XRAYUI pattern for ASUSWRT-Merlin

APP_NAME="Amnezia-UI"
APP_VER="v3.1.0-merlin"
SCRIPT_NAME="$(basename "$0")"
ROUTER_DIR="/jffs/addons/amneziaui"
SCRIPT_DIR="/jffs/scripts"
TMP_DIR="/tmp"
GITHUB_REPO="Sp0Xik/asuswrt-merlin-amnezia-ui"
RELEASE_URL="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
  printf "\n${BLUE}========================================${NC}\n"
  printf "${BLUE}    %s Installation Script${NC}\n" "$APP_NAME"
  printf "${BLUE}    Version: %s${NC}\n" "$APP_VER"
  printf "${BLUE}========================================${NC}\n\n"
}

print_status() {
  printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

print_error() {
  printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

print_warning() {
  printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

check_requirements() {
  print_status "Checking system requirements..."
  
  # Check if we're running on ASUSWRT-Merlin
  if [ ! -f "/jffs/scripts/init-start" ] && [ ! -d "/jffs/addons" ]; then
    print_error "This script is designed for ASUSWRT-Merlin firmware"
    print_error "Please ensure you have custom scripts enabled"
    exit 1
  fi
  
  # Check available space
  SPACE_AVAILABLE=$(df /jffs | awk 'NR==2 {print $4}')
  if [ "$SPACE_AVAILABLE" -lt 10240 ]; then
    print_warning "Low disk space in /jffs (less than 10MB available)"
    print_status "Available: $(($SPACE_AVAILABLE / 1024))MB"
    printf "Do you want to continue? [y/N]: "
    read -r CONTINUE
    case "$CONTINUE" in
      [Yy]*) ;;
      *) print_status "Installation cancelled"; exit 0 ;;
    esac
  fi
  
  # Check for required tools
  for tool in wget curl tar; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      print_error "Required tool '$tool' not found"
      exit 1
    fi
  done
  
  print_status "Requirements check passed"
}

download_file() {
  local url="$1"
  local output="$2"
  local description="$3"
  
  print_status "Downloading $description..."
  
  if command -v curl >/dev/null 2>&1; then
    if ! curl -fsSL "$url" -o "$output"; then
      print_error "Failed to download $description using curl"
      return 1
    fi
  elif command -v wget >/dev/null 2>&1; then
    if ! wget -qO "$output" "$url"; then
      print_error "Failed to download $description using wget"
      return 1
    fi
  else
    print_error "Neither curl nor wget found"
    return 1
  fi
  
  print_status "Successfully downloaded $description"
}

get_latest_release() {
  local release_info="$TMP_DIR/release_info.json"
  
  print_status "Fetching latest release information..."
  
  if ! download_file "$RELEASE_URL" "$release_info" "release info"; then
    print_error "Failed to get release information"
    return 1
  fi
  
  # Extract download URL for the main package
  DOWNLOAD_URL=$(grep '"browser_download_url"' "$release_info" | head -1 | sed 's/.*"browser_download_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  
  if [ -z "$DOWNLOAD_URL" ]; then
    print_error "Could not find download URL in release info"
    return 1
  fi
  
  print_status "Found release: $DOWNLOAD_URL"
  rm -f "$release_info"
}

install_files() {
  local package_file="$TMP_DIR/amnezia-ui-package.tar.gz"
  local extract_dir="$TMP_DIR/amnezia-ui-extract"
  
  print_status "Starting installation process..."
  
  # Download the package
  if ! download_file "$DOWNLOAD_URL" "$package_file" "Amnezia-UI package"; then
    print_error "Failed to download main package"
    return 1
  fi
  
  # Create directories
  print_status "Creating directory structure..."
  mkdir -p "$ROUTER_DIR"
  mkdir -p "$SCRIPT_DIR"
  mkdir -p "$extract_dir"
  
  # Extract package
  print_status "Extracting package..."
  if ! tar -xzf "$package_file" -C "$extract_dir"; then
    print_error "Failed to extract package"
    return 1
  fi
  
  # Copy files to appropriate locations
  print_status "Installing files..."
  
  # Copy main files to addon directory
  if [ -d "$extract_dir" ]; then
    cp -r "$extract_dir"/* "$ROUTER_DIR/"
  fi
  
  # Move scripts to /jffs/scripts
  if [ -f "$ROUTER_DIR/amnezia-ui-busybox.sh" ]; then
    mv "$ROUTER_DIR/amnezia-ui-busybox.sh" "$SCRIPT_DIR/amnezia-ui"
  fi
  
  # Set permissions
  print_status "Setting permissions..."
  find "$ROUTER_DIR" -type f -name "*.sh" -exec chmod 0755 {} \;
  find "$SCRIPT_DIR" -type f -name "amnezia-ui" -exec chmod 0755 {} \;
  
  # Make binaries executable
  if [ -f "$ROUTER_DIR/amneziawg-go" ]; then
    chmod 0755 "$ROUTER_DIR/amneziawg-go"
  fi
  
  print_status "Files installed successfully"
}

run_initial_setup() {
  print_status "Running initial setup..."
  
  # Run the main installation script
  if [ -x "$SCRIPT_DIR/amnezia-ui" ]; then
    print_status "Executing: sh $SCRIPT_DIR/amnezia-ui install"
    sh "$SCRIPT_DIR/amnezia-ui" install
    
    if [ $? -eq 0 ]; then
      print_status "Initial setup completed successfully"
    else
      print_warning "Initial setup encountered some issues, but installation continued"
    fi
  else
    print_error "Main script not found or not executable"
    return 1
  fi
}

cleanup() {
  print_status "Cleaning up temporary files..."
  rm -rf "$TMP_DIR/amnezia-ui-*"
  rm -f "$TMP_DIR/release_info.json"
}

show_completion_message() {
  printf "\n${GREEN}========================================${NC}\n"
  printf "${GREEN}    Installation Completed!${NC}\n"
  printf "${GREEN}========================================${NC}\n\n"
  
  print_status "$APP_NAME $APP_VER has been installed successfully!"
  print_status "Files installed to: $ROUTER_DIR"
  print_status "Main script: $SCRIPT_DIR/amnezia-ui"
  
  printf "\n${BLUE}Next steps:${NC}\n"
  printf "1. Use the command: ${YELLOW}amnezia-ui${NC} (from anywhere)\n"
  printf "2. Or use: ${YELLOW}$SCRIPT_DIR/amnezia-ui${NC}\n"
  printf "3. Add your VPN configs with: ${YELLOW}amnezia-ui add /path/to/config.conf${NC}\n"
  printf "4. Start VPN interface: ${YELLOW}amnezia-ui start${NC}\n"
  printf "5. Check status: ${YELLOW}amnezia-ui status${NC}\n\n"
  
  printf "${BLUE}Web Interface:${NC}\n"
  printf "Start web backend: ${YELLOW}amnezia-ui web start${NC}\n"
  printf "Then visit: ${YELLOW}http://$(nvram get lan_ipaddr):8080${NC}\n\n"
  
  printf "${BLUE}For help:${NC} ${YELLOW}amnezia-ui help${NC}\n\n"
}

show_error_message() {
  printf "\n${RED}========================================${NC}\n"
  printf "${RED}    Installation Failed!${NC}\n"
  printf "${RED}========================================${NC}\n\n"
  
  print_error "The installation did not complete successfully."
  print_status "Please check the error messages above and try again."
  
  printf "\n${BLUE}Troubleshooting:${NC}\n"
  printf "1. Ensure you have sufficient free space in /jffs\n"
  printf "2. Check your internet connection\n"
  printf "3. Verify ASUSWRT-Merlin custom scripts are enabled\n"
  printf "4. Try running the script again\n\n"
  
  printf "${BLUE}For support, visit:${NC}\n"
  printf "https://github.com/$GITHUB_REPO/issues\n\n"
}

# Main installation function
main() {
  print_header
  
  # Check if running as root or admin
  if [ "$(id -u)" != "0" ] && [ "$(nvram get http_username)" != "$(whoami)" ]; then
    print_warning "Running without admin privileges"
  fi
  
  # Step 1: Check requirements
  if ! check_requirements; then
    show_error_message
    exit 1
  fi
  
  # Step 2: Get latest release info
  if ! get_latest_release; then
    show_error_message
    exit 1
  fi
  
  # Step 3: Install files following Merlin pattern
  if ! install_files; then
    show_error_message
    exit 1
  fi
  
  # Step 4: Run initial setup
  if ! run_initial_setup; then
    print_warning "Initial setup had issues, but core files are installed"
  fi
  
  # Step 5: Cleanup
  cleanup
  
  # Step 6: Show completion message
  show_completion_message
  
  exit 0
}

# Handle script interruption
trap 'print_error "Installation interrupted!"; cleanup; exit 1' INT TERM

# Run main function
main "$@"
