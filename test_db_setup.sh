#!/bin/bash
MIX_ENV=test mix do event_store.drop, event_store.create, event_store.init
MIX_ENV=test mix ecto.reset
