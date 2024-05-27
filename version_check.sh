#!/bin/bash

# Check if running in Docker environment by looking for /.dockerenv file
if [ -f /.dockerenv ]; then
    DOCKER_ENV=true
else
    DOCKER_ENV=false
fi

installed_packages=()
not_installed_packages=()

print_message() {
  echo "-----------------------------------"
  echo "$1"
  echo "-----------------------------------"
}

print_ok() {
  installed_packages+=("$1")
}

print_fail() {
  not_installed_packages+=("$1")
  echo "$1" >> failed_packages.txt
}

check_package() {
  local package_name="$1"
  local check_command="$2"
  if command -v "$package_name" >/dev/null 2>&1; then
    $check_command &> /dev/null && print_ok "$package_name" || print_fail "$package_name"
  else
    print_fail "$package_name"
  fi
}

# Clear previous failed packages file
> failed_packages.txt

# Development Tools
check_package build-essential "gcc --version"
check_package default-jre "java -version"
check_package python3 "python3 --version"
check_package composer "composer --version"
check_package poetry "poetry --version"
check_package pipx "pipx --version"
check_package rustup "rustup --version"
check_package go "go version"
check_package git "git --version"

# Utilities
check_package curl "curl --version"
check_package unzip "unzip -v"
check_package tree "tree --version"
check_package zip "zip --version"
check_package tar "tar --version"
check_package wget "wget --version"
check_package ack "ack --version"
check_package ripgrep "rg --version"
check_package pass "pass version"
check_package iftop "iftop --version"
check_package nmap "nmap --version"
check_package htop "htop --version"
check_package ncdu "ncdu --version"
check_package gpg "gpg --version"
check_package rsync "rsync --version"

# Text Editors
check_package vim "vim --version"
check_package nano "nano --version"
check_package emacs "emacs --version"

# Docker and related tools (check only if not in Docker)
if [ "$DOCKER_ENV" = false ]; then
  check_package docker.io "docker --version"
  check_package docker-compose "docker-compose --version"
  check_package kubectl "kubectl version --client"
  check_package vault "vault --version"
  check_package code "code --version"
fi

# Print Summary with Separated Sections
echo
echo
echo Package Summary
echo "==================================="
echo "INSTALLED PACKAGES"
echo "-----------------------------------"
for package in "${installed_packages[@]}"; do
  echo "  * $package - OK"
done

echo "==================================="
echo "NOT INSTALLED"
echo "-----------------------------------"
for package in "${not_installed_packages[@]}"; do
  echo "  * $package - NOT FOUND"
done

print_message "Please note that some packages might be installed but not functional due to missing dependencies."

# Print Total Package Count
total_installed_count=${#installed_packages[@]}
total_not_installed_count=${#not_installed_packages[@]}
total_count=$(( total_installed_count + total_not_installed_count ))

echo "==================================="
echo "TOTAL PACKAGES"
echo "-----------------------------------"
echo "  * Installed: $total_installed_count"
echo "  * Not Installed: $total_not_installed_count"
echo "  * Total: $total_count"
