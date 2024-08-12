FROM ubuntu:24.04 AS compiler
ENV PYTHONUNBUFFERED 1
WORKDIR /work
COPY requirements.txt ./
 RUN apt update && \
     apt -y install python3 python3-pip python3-venv 
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN  pip install --upgrade pip setuptools wheel && \
     pip  install --no-cache-dir -r requirements.txt

FROM ubuntu:24.04 AS runner
WORKDIR /work
COPY --from=compiler /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY scheduler.py ./
RUN  apt update && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt -y install cron tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata &&\
    rm -rf /var/lib/apt/lists/*
ENV TZ=Europe/Moscow
ENTRYPOINT [ "/opt/venv/bin/python3", "/work/scheduler.py" ]
