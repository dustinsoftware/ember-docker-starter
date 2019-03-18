# emberconf-preview (with Docker!)

This is a fork of https://github.com/embercasts/emberconf-octane-preview to demonstrate Docker + Windows integration. It's still a work in progress! It's untested on OS X but probably works with just `docker-compose up --build`.

Windows has noticeable filesystem I/O lag with Ember, so you may have better build times by using a Linux container.

Requirements:

- Docker (Linux containers mode). Ensure Docker is configured with at least 4 GB of RAM and 4 available cores, or builds will be much slower.
- C:\ as a shared drive (use Docker settings to enable this)
- Node LTS and yarn (for eslint and running npm scripts)
- .NET Core 2.1.300, used for [DockerVolumeWatcher](https://github.com/dustinsoftware/Docker-Volume-Watcher)

From a command line, run `yarn docker-start`. The container will take a while to restore dependencies the first time, but should be pretty fast after that. Ember serve should now be running, you can confirm this by visiting http://localhost:4200.

#### Recommendations

- Run `yarn docker-start` at the beginning of your workday for a fresh state. It will clean up old artifacts and do some sanity checks for you.
- If you are switching branches or doing a rebase, bring the container down first with `docker-compose down`. The file watcher sometimes can't keep up with all the files modified when switching commits.
