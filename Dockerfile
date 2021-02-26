FROM public.ecr.aws/prima/elixir:1.10.2-1

# Serve per avere l'owner dei file scritti dal container uguale all'utente Linux sull'host
USER app

WORKDIR /code

COPY ["entrypoint", "/entrypoint"]

ENTRYPOINT ["/entrypoint"]
