#!/usr/bin/env bash

EXT=exe

jbuilder build --dev \
    hello_world.$EXT \
    hello_client.$EXT \
    hello_server.$EXT \
    broker_server.$EXT \
    broker_client.$EXT \

