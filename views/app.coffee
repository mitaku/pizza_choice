app = angular.module('pizzaApp', ['ngResource'])


pizzasCtrl = app.controller 'PizzasCtrl', ($scope, $filter, $resource, $rootScope) ->

  Pizza = $resource "/pizzas/:id", {id:'@id'}, {
    vote: {method: "POST", url: "/pizzas/:id/vote"}
  }

  $scope.contents = Pizza.query()

  $scope.vote = (pizza) ->
    Pizza.vote({id: pizza.id})

  $scope.image_path = (pizza) ->
    return "https://raw.githubusercontent.com/kosenconf/080-pizza/master/public/pizza/" + pizza.image_file_name

  es = new EventSource('/subscribe/vote')
  es.onmessage = (e) ->
    obj = JSON.parse(e.data)
    $rootScope.$apply () ->
      angular.forEach $scope.contents, (content) ->
        if parseInt(content.id,10) == parseInt(obj.id,10)
          console.log obj.id
          content.count = obj.count
