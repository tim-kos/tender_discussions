Unreplied Tender Discussions
============================

Gives you a list of discussions of your Tender support site that nobody has replied to yet.


# Installation

* Clone or fork this repo
* Run `npm install .`

# Execution

You can supply all credentials over the command line:

```
./bin/tender_discussions --tenderapikey YOUR_TENDER_API_KEY --tendersitename YOUR_TENDER_SITENAME --state pending --campfireaccount YOUR_CAMPFIRE_ACCOUNT --campfirekey YOUR_CAMPFIRE_KEY --campfireroom YOUR_CAMPFIRE_ROOM_ID
```

... or you can supply them through environment variables. Just copy **env.default.sh** into an **env.sh** file, fill out all the credentials there and then run:


```
source env.sh && ./bin/tender_discussions --state pending
```

Cli arguments take precedence over the env variables if you provide both.


# TODO

- [] Write some tests
