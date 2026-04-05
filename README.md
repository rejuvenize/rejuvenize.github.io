# rejuvenize.github.io

## Syncing project builds

This repo can mirror generated public web assets from external projects into matching folders here.

Add one `.env` entry per project using this convention:

```env
PROJECT_ONE_PUBLIC_WEB_PATH=/absolute/path/to/project-one/public-web
PROJECT_TWO_PUBLIC_WEB_PATH=/absolute/path/to/project-two/public-web
```

Project names use lowercase letters, numbers, and hyphens. They map like this:

- `project-one` -> `PROJECT_ONE_PUBLIC_WEB_PATH`
- `project-two` -> `PROJECT_TWO_PUBLIC_WEB_PATH`

Commands:

```sh
make sync PROJECT=project-one
make sync-project-one
make sync-all
```

`make sync-all` will sync every `*_PUBLIC_WEB_PATH` entry defined in `.env`.
