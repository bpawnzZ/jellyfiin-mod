# Docker Jellyfin with Custom Frontend

## Submodule Initialization

This repository uses jellyfin-web as a Git submodule. To properly clone and initialize the repository:

### First-time Clone
```bash
git clone --recursive https://github.com/your-username/your-repo.git
```

### If Already Cloned Without Recursive
```bash
git submodule update --init --recursive
```

### Manual Submodule Setup
If the above doesn't work, you can manually initialize the submodule:

```bash
git submodule add https://github.com/jellyfin/jellyfin-web.git jellyfin-web
git submodule update --init --recursive
```

### Updating Submodule
To update the submodule to the latest version:
```bash
git submodule update --remote jellyfin-web
