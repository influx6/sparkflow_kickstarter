#Server_IO

##Intro
 We build a simple server setup to show how we can use http with fbp and sparkflow,very basic example

##Details
  We simple create two components,which provides the functionality we need, the first component is the io/Server and the other is the io/route_actor. These connected to get just like any normal server setup sends off the request from io/Server to io/route_actor which passes the request to a function which then executes the request with a response


##Development
  We basically build a component that starts off a server once its booted and sends off request to its 
  request output port and connect the route_actor component which first waits for a function to use on the request till it gets the function it pauses its request stream and once the function has been supplied,all request get handled by the function 
  
  ```

    class Server{

      static void register(){

        //create the registry and add the components

         Sparkflow.createRegistry('http',(r){
      
            r.addMutation('io/server',(e){

               e.makeOutport('io:req');
               e.makeOutport('io:error');

               var server,port = 3001, address = '127.0.0.1';
               HttpServer.bind(address,port).then((s){
                  server = s;
                  s.listen((req){
                     e.send('io:req',req);
                  });
               }).catchError((e){
                  e.send('io:error',e);
               });
            });

            r.addMutation('io/route_actor',(e){
      
                Function fn;
                e.makeInport('io:req');
                e.makeInport('io:fn');

                //pause request stream till function is supplied
                e.port('io:req').pause();
                
                //we get the function first then allow request in
                e.tapData('io:fn',(n){
                    fn = n.data;
                    e.port('io:req').resume();
                });

                //executes function with the request
                e.tapData('io:req',(n){
                    return fn(n.data);
                });

            });

         });
      }
    }

    void main(){
      
      //register the server component registry
      Server.register();
  
      //create the network
      var io = Network.create('basic_server');
      
      //add the components into the network
      io.use('http/io/server','servo');
      io.use('http/io/route_actor','page');

      //bind the connections
      io.ensureBinding('servo','io:req','page','io:req');

      //schedule the packets
      io.schedulePacket('page','io:fn',(req){
         req.response.write('Welcome to ${req.uri.path}');
         req.response.close();
      });


      // boot the network
      io.boot().then(Funcs.tag('booting io servo'));

    }

  ```

##Running
 simple dart ./server_io.dart and curl http://127.0.0.1:3000/ or open that url in the browser


##Note
  The basics within these tutorial should already make sense to the reader has we have done major details
 on the previous ks101_canvas_basic tutorial,please re-read that tutorial incase you miss something or suggest an improvement as an issue.
