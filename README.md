# dagger-sample

1. Edit secrets.yml.
2. Prepare gpg and sops.
3. Initialize.
```bash
dagger project init && dagger project update
```

# Git pull sample

```bash
dagger do gitPull \
  --with 'actions: params: git: { username: "", repository: "https://github.com/xxxxx/xxxxxxx.git", branch: "develop" }'
```

# Do bash command
```bash
dagger do list \
  --with 'actions: params: git: { username: "xxxx", repository: "https://github.com/xxxxx/xxxxxxx.git", branch: "develop" }' \
  --log-format plain
```

# Docker build and show xml

```bash
cd app && npm install

dagger do getSitemap \
  --with 'actions: params: { git: { username: "yskkuwahara", repository: "https://github.com/medley-inc/job-medley-nbp.git", branch: "feature/425-nmw-renewal" }, dockerhub: username: "81971438500" }' \
  --log-format plain
```

# Docker build and push to local docker repository

```bash
docker run -d -p 5000:5000 registry

dagger do pushLocal \
  --with 'actions: params: { git: { username: "yskkuwahara", repository: "https://github.com/medley-inc/job-medley-nbp.git", branch: "feature/425-nmw-renewal" }, dockerhub: username: "81971438500" }' \
  --log-format plain
```
