Scripts for building servo using docker.

### Building

Run ` build_fedora.bash `. This will clone the Servo git repo to ` ./source/ `, then build and start a docker container. When the compilation is complete, the servo binary and resources will be copied to ` ./servo/ `.

### Dependencies

- git
- bash
- docker

### Debug

If the environment variable `SB_DEBUG` is set, a debug binary will be built.

**WARNING:** rust debug builds are much slower and produce **much larger** artifacts and executables (think tens of gigabytes).

### Notes

You may need to be a member of the `docker` group to run docker without elevated privileges.