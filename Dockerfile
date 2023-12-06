# using python base image from docker hub and 3.9-alpine3.13 is tag name
# alpine3.13 is the best light weight image for python
FROM python:3.9-alpine3.13


# maintainer is the person who will look after the project

LABEL maintainer='harislania'


# Tells docker to not buffer anything so the logs can be generated directly to cmd
ENV PYTHONUNBUFFERED 1


# copying our requirements file to image then our app to image
# mentioning WORKDIR so we don't have to define everytime
# make 8000 port available
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# setting default value, by default dev environment will be false
ARG DEV=false 

# we could run every command explicitly but docker creates layer which makes it slower and complex thats why we use single command to run everything and sagregate it using && and \ for new line

# creating venv only to safeguard the image from dependency clashes installing requirements and then removing file to keep image space as low as possible and it is best practice

# creating a new user to run the commands. alpine do provide us the root user with full priviliges but it is not recommended to use it for running command as if it gets compromised the hacker will have complete access to the system. So, the user running commands will have less priviliges.

# disabled-password: not ask for password everytime we run command
# --no-create-home: to avoid creating home directory
# django-user: name of user
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user


# adding venv path, so whenever we run python commands we don't have to define venv
ENV PATH="/py/bin:$PATH"

# swithing to commmand running user after creating everything with root
USER django-user