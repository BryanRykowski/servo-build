Scripts for building servo using docker.

### Building

Run ` build_fedora.bash `. This will clone the Servo git repo to ` ./source/ `, then build and start a docker container. When the compilation is complete, the servo binary and resources will be copied to ` ./servo/ `.

### Dependencies

- git
- bash
- docker

### Arguments

` --version VERSION ` The Fedora docker image to use. Default is ` latest `[^1].

` --skip-app-build ` Skips building Servo.

` --rebuild-image ` Force re-building the Docker image.

` --clean-image ` Remove the docker image (Runs ` docker image rm servobuild-fedora:VERSION `)[^2].

` --clean-all ` Remove the docker image and the ` ./source/ ` and ` ./servo ` directories.

` --debug ` Build the debug version of Servo[^3].

### Notes

You may need to be a member of the ` docker ` group to run docker without elevated privileges.

[^1]: if you use the ` --version ` argument for a build, all commands need it included to work properly. 

[^2]: removing an image will not remove Docker overlay files. You can free up more space by running ` docker image prune `.

[^3]: **WARNING:** rust debug builds are much slower and produce **much larger** artifacts and executables (think tens of gigabytes).
