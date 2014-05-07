SHELL := /bin/bash
COFFEE     = node_modules/.bin/coffee
COFFEELINT = node_modules/.bin/coffeelint
MOCHA      = node_modules/.bin/mocha --compilers coffee:coffee-script --require "coffee-script/register"
REPORTER   = nyan

test: build
	@make lint || true
	$(MOCHA) --reporter $(REPORTER)

build: lint
	$(COFFEE) --compile --output lib src

lint:
	@[ ! -f coffeelint.json ] && $(COFFEELINT) --makeconfig > coffeelint.json || true
	$(COFFEELINT) --file ./coffeelint.json test src

.PHONY: \
	test \
	lint
