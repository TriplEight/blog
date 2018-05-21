FROM python:3.6-alpine
ENV PYTHONUNBUFFERED 1

RUN echo $"source /usr/share/bash-completion/bash_completion\n\
export HISTFILE=$HOME/.bash_history/history\n\
PS1=\'\u@\h:\w$ \'" \
>> /root/.bashrc

RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/

RUN apk add --update --no-cache \
  bash \
  bash-completion \
  curl \
  git \
  make \
  tini \
  tree

RUN mkdir -p /etc/bash_completion.d
RUN cd /etc/bash_completion.d/ \
  && curl -SLO https://rawgit.com/django/django/stable/2.0.5.x/extras/django_bash_completion

COPY requirements.txt requirements.txt

RUN apk update && \
 apk add python3 postgresql-libs && \
 apk add --virtual .build-deps gcc python3-dev musl-dev postgresql-dev && \
 python3 -m pip install -r requirements.txt --no-cache-dir && \
 apk --purge del .build-deps

ADD . /code/

ENTRYPOINT ["/sbin/tini", "--"]
