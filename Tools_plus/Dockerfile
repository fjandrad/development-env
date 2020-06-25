ARG from=fjandrad/tools:latest
FROM ${from}

#====
#Install terminator with its dependencies
#====
 RUN apt-get update &&\
     apt-get install -y --no-install-recommends \ 
        terminator\
        &&\
    rm -rf /var/lib/apt/lists/*


