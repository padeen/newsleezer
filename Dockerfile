FROM elixir:1.15.7

RUN mix local.hex --force

RUN mix local.rebar --force

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends inotify-tools

WORKDIR /usr/src/app

CMD ["mix", "phx.server"]
