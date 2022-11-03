# dagger-sample

1. Edit secrets.yml.
2. Prepare gpg and sops.
3. Initialize.
```bash
$ dagger project init && dagger project update
```

# Git Pull Sample

```bash
dagger do gitPull \
  --with 'actions: params: git: { username: "", repository: "https://github.com/xxxxx/xxxxxxx.git", branch: "develop" }'
```

```bash
dagger do list \
  --with 'actions: params: git: { username: "xxxx", repository: "https://github.com/xxxxx/xxxxxxx.git", branch: "develop" }' \
  --log-format plain
```
