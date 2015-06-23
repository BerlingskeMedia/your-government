angular.module "lineBreakFilter", []
  .filter "lineBreak", ->
    (input) ->
      return if input is undefined

      input.split(",").join(",\n")
