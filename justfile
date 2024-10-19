# Justfile for running tests

# Recipe to run the test for YouTube template
# nvim --headless -u nvim/tests/test_init.lua "PlenaryBustedDirectory nvim/tests/"
# Justfile

install-dev:
    pre-commit install
    luarocks install luacheck
    luarocks install vusted
    brew install lua-language-server

# Run all tests in the tests/ directory using minimal_init
test:
    vusted ./test

lsp-check:
    lua-language-server --check  .
    fx ~/.cache/lua-language-server/log/check.json

