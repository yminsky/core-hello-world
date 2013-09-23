#!/usr/bin/env bash

EXT=native

corebuild \
    -j 4 \
    -pkg async,textutils  \
    hello_world.$EXT \
    hello_client.$EXT \
    hello_server.$EXT \
    broker_server.$EXT \
    broker_client.$EXT \

