class Nutcracker.Models.Overview extends Backbone.Model
  url: "/overview.json"
  
  initialize: => 
    @postInit()
    
  nodes: =>
    new Backbone.Collection(_(@get("clusters").pluck("nodes")).chain()
      .pluck("models")
      .flatten()
      .uniq(false, (o) -> o.get("hostname"))
      .value()
    )
  
  fetch: =>
    super and @postInit()
    Nutcracker.reload()
  
  clusters: =>
    @get "clusters"
  
  postInit: =>
    clientConnections = _(@get("clusters").pluck("client_connections")).sum()

    serverConnections = 0
    for nodesCollection in @get("clusters").pluck("nodes")
      serverConnections += nodesCollection.serverConnections()

    @set "serverConnections", serverConnections
    @set "clientConnections", clientConnections
    @set "initializeTime", new Date

  set: ( attributes, options ) ->
    if attributes.clusters? and attributes.clusters not instanceof Nutcracker.Collections.Clusters
      attributes.clusters = new Nutcracker.Collections.Clusters attributes.clusters

    Backbone.Model.prototype.set.call(@, attributes, options)