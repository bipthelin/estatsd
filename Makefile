PROJECT = estatsd

ERLC_OPTS = +debug_info +'{parse_transform,lager_transform}'

DEPS = lager
dep_lager = git@github.com:basho/lager.git 2.0.3

include erlang.mk
