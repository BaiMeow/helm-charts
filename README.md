# BaiMeow Helm Charts

A collection of Helm charts hosted on GitHub Pages via [chart-releaser](https://github.com/helm/chart-releaser-action).

## Usage

```bash
helm repo add baimeow https://baimeow.github.io/helm-charts
helm repo update
helm search repo baimeow
```

## Available Charts

| Chart | Description |
|---|---|
| [network-monitor](./charts/network-monitor) | Monitor your network status (OSPF/BGP) with topology graphs and uptime tracking |

## Publishing

Pushing a version bump in `charts/<name>/Chart.yaml` to `main` automatically runs [Release Charts](.github/workflows/release.yml):

1. Lints all charts under `charts/`.
2. Packages changed charts and creates a GitHub Release (`<chart>-<version>`).
3. Updates `index.yaml` on the `gh-pages` branch.

> **First-time GitHub Pages setup:** In repository **Settings -> Pages**, set **Source** to **Deploy from a branch** and select branch `gh-pages` (`/ (root)`).
