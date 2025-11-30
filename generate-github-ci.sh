#!/bin/bash

# SPDX-FileCopyrightText: Fedora Atomic Desktops maintainers
# SPDX-License-Identifier: MIT

set -euo pipefail
# set -x

variants=(
    'sway-atomic'
    'base-atomic'
)

branch="$(git rev-parse --abbrev-ref HEAD)"
release=""
if [[ "${branch}" == "main" ]] || [[ -f "fedora-rawhide.repo" ]]; then
    release="rawhide"
else
    release="$(rpm-ostree compose tree --print-only --repo=repo silverblue.yaml | jq -r '."mutate-os-release"')"
fi

{
cat <<EOF
name: Build Fedora Sway Atomic

on:
  push:
    branches: ["main"]
  pull_request:
  schedule:
    - cron: "0 3 * * *"

jobs:
EOF

for variant in "${variants[@]}"; do
cat <<EOF
  build-$variant-aarch64:
    if: (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/test') && (github.event_name == 'push' || github.event_name == 'schedule')
    runs-on: [self-hosted, linux, ARM64]
    environment: build-release
    permissions:
      contents: read
      packages: write
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - name: Run buildroot container with Podman
        run: |
          podman run --privileged --rm \\
            -e CI=true \\
            -e REGISTRY="ghcr.io" \\
            -e RELEASE_REPO="\${{ github.repository }}" \\
            -e CI_REGISTRY_USER="\${{ github.actor }}" \\
            -e CI_REGISTRY_PASSWORD="\${{ secrets.GITHUB_TOKEN }}" \\
            -e ACTIONS_ID_TOKEN_REQUEST_URL="\$ACTIONS_ID_TOKEN_REQUEST_URL" \\
            -e ACTIONS_ID_TOKEN_REQUEST_TOKEN="\$ACTIONS_ID_TOKEN_REQUEST_TOKEN" \\
            -v "\$PWD":/workspace \\
            --workdir /workspace \\
            quay.io/fedora-ostree-desktops/buildroot:rawhide \\
            bash -c "just compose-image sway-atomic && just upload-container sway-atomic aarch64"
      - uses: actions/upload-artifact@v4
        with:
          name: buildid-$variant-aarch64
          path: .buildid
          include-hidden-files: true

  build-$variant-x86_64:
    if: (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/test') && (github.event_name == 'push' || github.event_name == 'schedule')
    runs-on: [self-hosted, linux, X64]
    environment: build-release
    permissions:
      contents: read
      packages: write
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - name: Run buildroot container with Podman
        run: |
          podman run --privileged --rm \\
            -e CI=true \\
            -e REGISTRY="ghcr.io" \\
            -e RELEASE_REPO="\${{ github.repository }}" \\
            -e CI_REGISTRY_USER="\${{ github.actor }}" \\
            -e CI_REGISTRY_PASSWORD="\${{ secrets.GITHUB_TOKEN }}" \\
            -e ACTIONS_ID_TOKEN_REQUEST_URL="\$ACTIONS_ID_TOKEN_REQUEST_URL" \\
            -e ACTIONS_ID_TOKEN_REQUEST_TOKEN="\$ACTIONS_ID_TOKEN_REQUEST_TOKEN" \\
            -v "\$PWD":/workspace \\
            --workdir /workspace \\
            quay.io/fedora-ostree-desktops/buildroot:rawhide \\
            bash -c "just compose-image sway-atomic && just upload-container sway-atomic x86_64"
      - uses: actions/upload-artifact@v4
        with:
          name: buildid-$variant-x86_64
          path: .buildid
          include-hidden-files: true


  merge-$variant:
    if: (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/test') && (github.event_name == 'push' || github.event_name == 'schedule')
    runs-on: self-hosted
    environment: build-release
    permissions:
      contents: read
      packages: write
      id-token: write
    needs:
      - build-$variant-x86_64
      - build-$variant-aarch64
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with:
          name: buildid-$variant-x86_64
      - uses: actions/download-artifact@v4
        with:
          name: buildid-$variant-aarch64
      - run: |
          podman run --privileged --rm \\
            -e CI=true \\
            -e REGISTRY="ghcr.io" \\
            -e RELEASE_REPO="\${{ github.repository }}" \\
            -e CI_REGISTRY_USER="\${{ github.actor }}" \\
            -e CI_REGISTRY_PASSWORD="\${{ secrets.GITHUB_TOKEN }}" \\
            -e ACTIONS_ID_TOKEN_REQUEST_URL="\$ACTIONS_ID_TOKEN_REQUEST_URL" \\
            -e ACTIONS_ID_TOKEN_REQUEST_TOKEN="\$ACTIONS_ID_TOKEN_REQUEST_TOKEN" \\
            -v "\$PWD":/workspace \\
            --workdir /workspace \\
            quay.io/fedora-ostree-desktops/buildroot:rawhide \\
            bash -c "just multi-arch-manifest $variant"
EOF
done
} > .github/workflows/github-ci.yml