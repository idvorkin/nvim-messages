describe('Hello World', function()
  it('should return the correct greeting', function()
    local function hello_world()
      return 'Hello, World!'
    end

    assert.are.equal('Hello, World!', hello_world())
  end)
end)
