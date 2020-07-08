FROM prima/elixir-official:1.10.2-1

WORKDIR /code

RUN groupadd -g 1000 app && \
    useradd -g 1000 -u 1000 --system --create-home app && \
    mix local.hex --force && \
    mix local.rebar --force && \
    cp -rp /root/.mix /home/app/ && \
    chown -R app:app /home/app/.mix

USER app

COPY ["entrypoint", "/entrypoint"]

ENTRYPOINT ["/entrypoint"]
