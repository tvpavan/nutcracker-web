class Nutcracker.Views.Cluster extends Backbone.View
  template: JST['cluster']

  render: ->
    @$el.html @template {@model}

    options = {
      is3D: true
      titleTextStyle:
        fontSize: 17.5
        color: '#333333'
      width:  300
      height: 300
      sliceVisibilityThreshold: 0
      chartArea:
        width: '100%'
        height: '80%'
      legend:
        position: 'bottom'
    }

    formatter = new Nutcracker.Utils.GenericFormatter(humanize.filesize)

    data = [['Node','Node']]
    @model.get("nodes").map (node)->
      data.push [node.get("hostname"),node.get("info").max_memory]

    chart = new Backbone.GoogleChart({
      beforeDraw: (options)-> # move this to GoogleChart
        options.dataTable = google.visualization.arrayToDataTable options.dataTable
        formatter.format(options.dataTable, 1)
      chartType: 'PieChart'
      options: options
      dataTable: data
    })

    chart.on "select", (chart) =>
      Nutcracker.router.navigate @model.get("nodes").at(
        chart.getSelection()[0].row
      ).get('routeURL'), trigger: true

    @$el.find("#chart2").html chart.render().el
    @$el.find("#chart1").html new Backbone.GoogleChart({
      beforeDraw: (options)->
        options.dataTable = google.visualization.arrayToDataTable options.dataTable
        formatter.format(options.dataTable, 1)
      chartType: 'PieChart'
      options: options
      dataTable: [
        ['Memory', 'Memory']
        ['Free', @model.get("nodes").freeMemory() ]
        ['Used', @model.get('nodes').usedMemory() ]
      ]
    }).render().el
    
    this
