# S.O. Project 2018
## Introduction to the project 
Project in Jolie: Jolie crystallises the programming concepts of microservices as native language features: the basic building blocks of software are not objects or functions, but rather services that can always be relocated and replicated as needed. Distribution and reusability are achieved by design.

Teacher: Davide Sangiorgi

Group: Bruno Marafini, Alessandro Fabbri, Riccardo Costanzo, Francesca Ventruto.

## Jolie
Jolie crystallises the programming concepts of microservices as native language features: the basic building blocks of software are not objects or functions, but rather services that can always be relocated and replicated as needed. Distribution and reusability are achieved by design.
Jolie code is always contained in services, which you can always move from being local to remote and vice versa, without altering the logic of your programs. A monolithical application can scale to being distributed by design: if you decide to distribute a part of it, just take it and execute it in another machine.
Jolie is protocol agnostic: your services can exchange data by using different protocols. Bridging two networks using different protocols is a matter of a few lines of code! And if you need a protocol that Jolie does not support yet, there is an API for easily developing new ones in Java.
Jolie offers many ways for building complex software from simple services. Even the deployment architecture of a system can be programmed with native primitives, generalising common practices. Whatever you build, is again a service that you can expose; so, it can be reused to build again! Here are some examples of composition:

- Orchestration: an orchestrator is a service that offers functionalities obtained by coordinating other services with a workflow.
- Aggregation: a generalisation of proxies and load balancers, which you can use to compose and expose the APIs of separate services.
- Redirection: a generalisation of virtual servers, which hides the actual locations of services to clients by assigning logical names to services.
- Embedding: a generalisation of application servers, which runs other services as inner components. It enables fast local communications and can even run code written in different languages than Jolie, such as Java and Javascript (with more coming)!

## Jolie Documentation
You can find the most common information and examples about Jolie [here](https://docs.jolie-lang.org).

# How to install Jolie
## Download the Jolie installer
In order to install Jolie you must first download the installer from the main Download page [here](http://www.jolie-lang.org/downloads.html, clicking on the **Jolie Installer** icon that will download the -jar1.6.2.

## Run the installer from the terminal
Open a shell terminal, access the directory in which you downloaded the installer, and execute **java -jar jolie-1.6.2.jar**. The installer may need permissions to write in the directories in which you intend to install Jolie. Depending on your Operating System you can launch the Jolie installer with elevated privileges:

- on Windows, by start a command prompt with administrator privileges and launch the installer;
- on Linux/MacOS, by launching the installer as root with command sudo java -jar jolie-1.6.2.jar.

## Installation Troubleshooting (Problems)
### I get "command not found" after I installed Jolie under MacOs X El Capitan (10.10.11) or latest MacOS Operating Systems
In MacOs X El Capitan (10.10.11) it is not possible to install Jolie using the default values provided by the installer. When prompted by the installer, insert e.g., **/usr/local/lib/jolie** as the *directory of installation* of Jolie and **/usr/local/bin** as the *directory of the launchers*.

### I get "Error: Could not find or load main class jolie.Jolie" after I installed Jolie under Linux/MacOs X.
The launchers deployed by the installer use the environment variable **JOLIE_HOME** to set the classpath and launch Jolie. As reported by the installer at the end of the installation, it is possible to set **JOLIE_HOME** with the command *echo 'export JOLIE_HOME="/usr/lib/jolie"' >> ~/.bash_profile*

However, some versions of Linux/MacOs X do not source the *.bash_profile* file. If, when trying to run Jolie you get the message *"Error: Could not find or load main class jolie.Jolie"*, it could be the case your shell is not sourcing file .bash_profile. To fix it, edit your *.bashrc* in you home directory by appending at its end the line source *.bash_profile*.

# Compilation from Source files
Following these instructions you can download the development version of Jolie (trunk). It requires the following software to be installed before proceeding:

1. JDK (Java SE Development Kit);
2. Git;
3. Apache Ant.

## Linux and Mac OS

Open a shell and execute:

**git clone https://github.com/jolie/jolie.git**

**cd jolie**

**ant && sudo ant install**

The ant script will automatically build and install Jolie for you. The default installation path for the Jolie binaries is */usr/lib/jolie*, but the installation parameters can be controlled by editing *buildconfig/config.properties*.

The Jolie launchers are installed inside folder */usr/bin*, but also this parameter is configurable in *buildconfig/config.properties*.

Remember to follow the on-screen instructions at the end of the installation procedure about the environment variables. This final step is similar to setting the java_home variable for Java, as explained here.

## Windows

Compiling Jolie under Windows requires to work only within the same drive e.g.. C:. This is due to limitations of the Java class-loader in locating resources within different drives.

Open a command line and execute:

**git clone https://github.com/jolie/jolie.git**

**cd jolie**

Open the *buildconfig/config.properties* file and change the parameters *install.launcher_dir* and *install.dir* by replacing the existing directories with your desired ones. Use \\ instead of the single backslashes when writing paths. Here is an example:
```markdown
install.launcher_dir=C:\\Windows\\system32
install.dir=C:\\Jolie
```
In case you change the directory for *install.launcher_dir*, make sure that it is included in your your PATH environment variable (similarly to what explained here for Java). Please note that using paths with spaces may cause problems in Windows and need special handling.

Finally, execute ant dist-install, following the on-screen instructions at the end of the installation procedure regarding environment variables. In particular, you should make sure that the environment variable *JOLIE_HOME* is set to the directory you used for *install.dir*.

# HelloWorld in Jolie
## Instructions to code
### Code
```markdown
include "console.iol"

main 
{
    println@Console( "Hello, world!" )()
}
```

The program above reads as:

- include the source file console.iol;
- send the message *"Hello, world!"* to the *println* operation of the *Console* service.

We can already see some characteristics of a Jolie program:

- we can include other source files by means of the include primitive;
- the entry point of a Jolie program is the main code block;
- we can send a message to a service with a native primitive (Line 4).

The last point differs from classical programming languages and is peculiar to Jolie: *the println@Console( "Hello, world!" )()* line is a **solicit-response statement**, which is a communication primitive.

## Run the service from terminal
Jolie programs are saved in files named with the *.ol* extension. For example, we can save the code of the service above in a file called **myFirstJolieService.ol**. Then, we can run it by executing the following command:

jolie myFirstJolieService.ol

which will print the string *Hello, world!*.