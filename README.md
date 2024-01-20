# Podman Demo

***developed for Red Hat Edge to Cloud Learning Experience 2024 Hackathon by [Ryan Gniadek](mailto:rpg@redhat.com) and [Maurice Mckellar III](mailto:mmckella@redhat.com)***

This is a lab on how to use Podman to build and run a container, and then push it to a quay.io registry.

## Prerequisites
Podman must be installed on your machine. To do this, we will use Podman Desktop. Go to [podman-desktop.io](https://podman-desktop.io/) to download and install the application.

Depending on your operating system, there will be different steps to install and run the "podman" command.

We also reccomend using VSCode as your IDE. You can download VSCode [here](https://code.visualstudio.com/).

Finally, you will need to have a Red Hat account. You can create one [here](https://access.redhat.com/login).

## Assignment Setup
Inside of VSCode, open a terminal and run the following command:
```bash
git clone https://github.com/ryangniadek/podman-demo.git
```

Then open the folder in VSCode.

## Introduction
The goal of this lab is to learn:
- What is a container, and how it's different from deploying natively or on a virtual machine
- How to run a container image from a public registry
- How to build a container image
- How to deploy a container image to a public registry

Containers are an environment-agnostic way to package up code, configuration, and dependencies and run it anywhere a container engine (such as Podman or Docker) is installed.

Both containers and virtual machines are ways of providing resource isolation and are widespread in modern application deployments. Virtual machines abstract away the hardware and emulate the entire operating system. On the other hand, containers use the underlying operating system of the host to execute, so they are much lighter weight since they only need to include the code and dependencies for a specific application.

## How to run a container image
In this section, we will run a container image from a public registry. We will use the [quay.io](https://quay.io/) registry, which is a public registry that is hosted by Red Hat.

Inside your terminal type the following command:
```bash
podman run quay.io/podman/hello
```
Your output should look something like this:
```bash
Trying to pull quay.io/podman/hello:latest...
Getting image source signatures
Copying blob sha256:6f7d332c6972d7de13acdd07eafee248b5435ff1b69d22d1cbbe9c64198d4777
Copying config sha256:1b10fa0fd8d184d9de22a553688af8f9f8adbabb11f5dfc15f1a0fdd21873db2
Writing manifest to image destination
!... Hello Podman World ...!

         .--"--.
       / -     - \
      / (O)   (O) \
   ~~~| -=(,Y,)=- |
    .---. /`  \   |~~
 ~/  o  o \~~~~.----. ~~
  | =(X)= |~  / (O (O) \
   ~~~~~~~  ~| =(Y_)=-  |
  ~~~~    ~~~|   U      |~~

Project:   https://github.com/containers/podman
Website:   https://podman.io
Documents: https://docs.podman.io
Twitter:   @Podman_io
```

You may notice before the output of the hello world container, there are a few lines of output showing the container image being downloaded from Quay.

## How to build a container image
In this section, we will build a container image using a Containerfile. A Containerfile (sometimes called Dockerfile). Each line in the file is a command that will be executed, in order, when the container image is built.

> The order of the commands is important, as containers use a layered filesystem such that when changes are made, only the layer that needs to be changed onwards is updated. So layers that rarely change, such as the dependencies, should be at the top of the Containerfile, and layers that change frequently, such as the application code, should be at the bottom.

The Containerfile we provided you looks like this:
```Dockerfile
# Set the base image to the UBI 9 Python 3.11 image provided by Red Hat
FROM registry.access.redhat.com/ubi9/python-311:1-41
# Set working directory inside the container to /app
WORKDIR /app
# Copy the requirements.txt file from the local host to the container's /app directory
COPY ./application/requirements.txt /app
# Install the Python dependencies from the requirements.txt file
RUN pip install -r requirements.txt
# Copy the application files from the local host to the container's /app directory
COPY ./application /app
# Expose port 5000
EXPOSE 5000
# Set the default command for the container to flask run
CMD flask run --host=0.0.0.0
```

This Containerfile uses a base image provided by Red Hat, which is a minimal operating system that includes Python 3.11. It then copies in the requirements for a sample Flask application we provided, installs them inside the container, copies the rest of the application code, specifies that the container should listen on port 5000, and then sets the default command to run the Flask application.

Now let's build the container image and name it `my_app`. In your terminal, type the following command:
```bash
podman build -t my_app .
```

You should see output that indicates each layer of the container image being built.

To see the list of all images on your system, run this command:
```bash
podman images
```

## Run your container image
Now that you've built a container image `my_app`, you can run it using the following command:
```bash
podman run --rm -d -p 5000:5000 --name api my_app
```
Let's explain what all of the different options on the `podman run` command are doing:
- `--rm` this automatically removes the container and its file system after stopping the container
- `-d` detached mode, this runs the container as a background process
- `-p` expose a port on the container to the host machine given the argument `hostPort:containerPort`. So in the above command, we are exposing port `5000` inside the container on port `5000` on the host machine
- `--name` assign a name to your running container, in our case, `api`. If no name is assigned, a random string is generated
- `my_app` is the name of the container image to run.

Now that the container is running, you can query the Flask application running inside the container by running the following commands:
```bash
curl localhost:5000
curl localhost:5000/your-name-here
```

Once you have finished testing, stop the container:
```bash
podman stop api
```

## Deploying your container image to a registry
Now that you have built a container image, you can deploy it to a registry. A registry is a place to store container images. You can think of it as a GitHub for container images.

In this lab, we will use [quay.io](https://quay.io/), which is a public registry that is hosted by Red Hat.

To deploy your container image to quay.io, you will need to sign in with your Red Hat account. You can do that [here](https://quay.io/).

Once you have signed in, you can click "Create New Repository" and give it a name. For this lab, we will use `my_app`. Make the repository public, select the option for an empty repository, and click "Create Public Repository".

Now that you have created a repository, you can push your container image to it. First, you will need to log in to quay on your local machine. To do this, run the following command and enter your Red Hat credentials when prompted:
```bash
podman login quay.io
```

Now that you are logged in, you can push your container image to quay.io. To do this, you will need to tag your container image with the name of the repository you created, naming it the same thing as your remote repo. Run the following command to do this:
```bash
podman tag my_app quay.io/<your-username>/my_app
```

You can then push your container image to quay.io by running the following command:
```bash
podman push quay.io/<your-username>/my_app
```

Your container image is now published to the remote repository if you got this message:
```bash
...
Writing manifest to image destination
```

If you want, you can have a friend pull your container image and run it on their machine. Or even run it on a container platform such as OpenShift (stay tuned)!!

## Acknowledgements

This lab is heavily derrived from the [Getting Started with Containers Assignment](https://github.com/BURGS-VT/containers-assignment) developed by Ryan Gniadek and [Margaret Ellis](https://people.cs.vt.edu/~maellis1/) for Virginia Tech.
