#Server_Canvas_IO

##Intro
 We build a simple server setup to show how we can use http with fbp and sparkflow and run a canvas rendering
 rectangles while receiving data from the server

##Details
  We build upon the last Canvas_basics and Server_basics example by adding a socket component to the server side
  that allows communication over websocket,that sends off coordinates details to the client which renders a rectangle
  on a canvas on the client side


##Running
 simple dart test/server_io.dart and open the web/index.html in dartium


