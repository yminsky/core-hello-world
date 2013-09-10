#!/usr/bin/env bash

EXT=byte

corebuild \
    hello_world.$EXT \
    hello_client.$EXT \
    hello_server.$EXT \
    broker_server.$EXT \
    broker_client.$EXT \

