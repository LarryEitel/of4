'use strict'

describe 'Service: map', () ->

  # load the service's module
  beforeEach module 'of4App'

  # instantiate service
  map = {}
  beforeEach inject (_map_) ->
    map = _map_

  it 'should do something', () ->
    expect(!!map).toBe true;
