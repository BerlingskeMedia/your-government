angular.module "yourGovernmentDirective", []
  .directive "yourGovernment", ($http, $location, $timeout, $window) ->
    restrict: "E"
    templateUrl: "/upload/tcarlsen/your-government/partials/your-government.html"
    link: (scope, element, attr) ->
      scope.parliaments = null
      scope.userParliaments = null
      scope.activeParliament = {}
      scope.candidates = null
      scope.showPopup = false
      scope.showShare = false
      scope.search = {}
      scope.nameSet = false;

      api = "http://54.77.4.249";
      popupEle = element.find "popup"
      appWidth = element[0].offsetWidth
      parliamentsUrl = "#{api}/offices"
      anyoneSet = false

      scope.popup = (index, id) ->
        return if scope.stage isnt "home"
        return if scope.showShare is true

        $http.get "#{api}/offices/#{id}"
          .then (response) ->
            scope.candidates = response.data
            scope.showPopup = true

            $timeout ->
              ele = element.find("candidate").eq(index)
              popW = element.find("popup")[0].getBoundingClientRect().width
              rect = ele[0].getBoundingClientRect()
              top = ele[0].offsetTop
              left = ele[0].offsetLeft + rect.width
              direction = "e"

              if $window.innerWidth < 768
                left = 0
                direction = ""
              else if left > (appWidth / 2)
                console.log true
                left-= rect.width + popW
                direction = "w"

              popupEle
                .removeClass("e w")
                .addClass direction
                .css
                  MsTransform: "translate3d(#{left}px, #{top}px, 0)"
                  MozTransform: "translate3d(#{left}px, #{top}px, 0)"
                  WebkitTransform: "translate3d(#{left}px, #{top}px, 0)"
                  transform: "translate3d(#{left}px, #{top}px, 0)"

              ele.addClass("active")

              scope.activeParliament.index = index
              scope.activeParliament.name = scope.parliaments[index].office.name

              element.find("popup").find("input")[0].focus()

      scope.start = ->
        if scope.userParliaments
          scope.parliaments = scope.userParliaments
        else
          $http.get parliamentsUrl
            .then (response) ->
              scope.parliaments = response.data

        scope.title = "Hvem skal styre Danmark?"
        scope.description = "Sæt dit helt eget ministerhold. Du kan udpege hvemsomhelst, og du kan slette de ministerier, du ikke vil have. Tryk på en ministerpost for at komme i gang."
        scope.class = ""
        scope.stage = "home"

        $location.hash("")

      scope.selectCadidate = (candidate) ->
        return if candidate.name is undefined

        candidate.image = "/upload/tcarlsen/your-government/img/silhuet.png" if !candidate.image
        scope.showPopup = false
        anyoneSet = true

        scope.parliaments[scope.activeParliament.index].candidate = candidate

        scope.search.name = ""

      scope.removeCandidate = (index) ->
        scope.parliaments.splice index, 1

      scope.save = ->
        return if !anyoneSet

        $http.post "#{api}/parliaments", {nominations: scope.parliaments}
          .then (response) ->
            scope.title = "Her er dit ministerhold"
            scope.description = ""
            scope.shareId = response.data.uuid
            scope.showShare = true
            scope.showPopup = false

            element.find("candidate").addClass "active"
            element.find("save").remove()

            $location.hash(scope.shareId)

      scope.setParliamentName = (name) ->
        $http.post "#{api}/parliaments/#{scope.shareId}", {name: name}
          .then (response) ->
            console.log
            scope.nameSet = true
            scope.title = name

      scope.toplist = ->
        scope.userParliaments = scope.parliaments

        $http.get "#{api}/parliaments"
          .then (response) ->
            scope.parliaments = response.data.nominations
            scope.title = "Her er flertallets regering"
            scope.description = "Se hvilke ministre, flest brugere har valgt til deres egne ministerhold."
            scope.class = "active"
            scope.stage = "toplist"
            scope.showPopup = false
            scope.showShare = false

      if $location.hash()
        parliamentsUrl = "#{api}/parliaments/#{$location.hash()}"
        scope.description = "Du kan også sætte dit eget ministerhold. Tryk på 'Sæt din egen regering', udpeg hvemsomhelst og slet de ministerier, du ikke vil have."
        scope.class = "active"
        scope.stage = "friendlist"
        scope.friend = true

        $http.get parliamentsUrl
          .then (response) ->
            scope.parliaments = response.data.nominations

            if response.data.name
              scope.title = response.data.name
            else
              scope.title = "Her er din vens regering"
      else
        scope.start()
