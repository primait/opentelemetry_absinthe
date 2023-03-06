FROM public.ecr.aws/prima/elixir:1.14.2-3

# Serve per avere l'owner dei file scritti dal container uguale all'utente Linux sull'host
USER app

WORKDIR /code

COPY ["entrypoint", "/entrypoint"]

ENTRYPOINT ["/entrypoint"]
