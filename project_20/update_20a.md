# Practice Task №2 – Complete Continuous Integration With A Test Stage

1. Document your understanding of all the fields specified in the Docker Compose file tooling.yml

**version:** version of docker to be used.

**services:** services to be 'boxed' in containers being build by docker

**tooling_frontend/db:** names of services

**build:** location of Dockerfile required to build image

**ports:** ports where service is run and also mapped to host

**volumes:** where service related data is stored

**links:** other services that must be running before it is started

**image:** the image the container will be built from

**restart:** always

**environment:** environmental varibles

2. Update your Jenkinsfile with a test stage before pushing the image to the registry.

```

3. What you will be testing here is to ensure that the tooling site http endpoint is able to return status code 200. Any other code will be determined a stage failure.
4. Implement a similar pipeline for the PHP-todo app.
5. Ensure that both pipelines have a clean-up stage where all the images are deleted on the Jenkins server.