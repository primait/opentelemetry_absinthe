FROM 001575623345.dkr.ecr.eu-west-1.amazonaws.com/elixir:1.10.2-1

# Serve per avere l'owner dei file scritti dal container uguale all'utente Linux sull'host
USER app

WORKDIR /code

COPY ["entrypoint", "/entrypoint"]

ENTRYPOINT ["/entrypoint"]
