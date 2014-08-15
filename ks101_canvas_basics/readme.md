#Canvas_Basics

##Intro
  Here we will create basic component that interact with the canvas to see an approach(not optimized) 
  means of doing canvas using fbp and sparkflow
  Also i will  be introducing a few new concept,that is the second approach of creationg components,
  the idea of component registry and how it works and helps to organise components into domains and
  subdomains

##Detail
  Component Registry or SparkRegistry as its called,is a class that allows the storage of components
  using a SUBDOMAIN/GROUP/ComponentName format ,where the subdomain can be any name or even a website
  link indicating where these set of components are comming from,the GROUP indicating the group of the 
  component and COMPONENTNAME indicating the name for this component,it allows a means of avoding 
  possible conflicts in names of components and allows subdomains within the registry.Also the 
  registry will be the primary collection point for all components both in the comming UI and its
  the structure which is used by the network when adding components. Now the SparkRegistry
  provide a means of creating component called Mutation, what these really means is we create
  a simple Component class instance and add behavours to it. These allows us to effectively create
  augmenting functions that take a simple Component class instance and add beviours to our it works
  and also allows us to extend that behaviour to lower components,sort of like inheritance but in a
  more functional way. Why these is created is in hope to find a means to send functions remotely
  just like in javascript,so as to automiatically move components from one point to the next
  also because they are functions,if dart allows creating of dynamic functions from string,we have
  the most beautiful means of creating dynamic components on the fly within any editor for Sparkflow.
  Easy to transport and use is the moto for these little class. It drops all functions as Maps and 
  we can simple jsonify that(once dart allows stringing of functions) and send that around and simple
  populate a registry to begin creating components.

##Design
  
  We will be creating two components,one the canvas component and the rectangle component which
  will receive the canvas element and use to draw an item to the screen,basically a rectangle
  of a specific color and specifc dimensions as supplied as an array to the rectangle component


##Development

  We create a basic class,with a single static function that we can to register the registry into
  the global Sparkflow class registry. The Sparkflow class a global resgistry that will contain
  other registry containing components,these allows us to subdomain components eaisily.
  The component registry has two methods of interest which are the:

    addMutation(String path,Function mutator);
    addBaseMutation(String basepath,String newpath,Function mutator);

   Where the path and basepath are in the subdomain format of GROUP/NAME format,and the function
   is used to agument the Component class instance behaviour,while the addMutation generates
   the base Component class, the addBaseMutation first generate a previously added Component
   mutation and then mutates that with its function which allows like mixing of different 
   behaviours down the tree,each new mutation is unique and contains behaviour from previous
   and we can see the mutation tree from the components meta map.

   Also the makeInport and makeOutport automatically creates the spaces if they dont exist,so
   you are not required to always call createSpace everytime,simplifes and shortens the process.

   More shortens are the tap,tapData,tapEndGroup,tapBeginGroup instance methods on the base component
   instance class,which allows the specifying of the port name and a function ,thereby shorting the 
   call to the usual: 
   
       component.port(_port_name).tap
       component.port(_port_name).tapData

    To

       component.tap(_port_name,Function);
       component.tapData(_port_name,Function);
    
    as seen below:

#Basic Detail:
    We create a canvas component that accepts an html.CanvasElement and sends that out to its outport once its available,we keep it resending it when any port connects there is the port.whenSocketSubscribe but for now we will make the connections before sending packet so lets simplify for now. Then second component is a rectangle component that takes the canvas instance then generates the context and waits for data of an array which contains [color,x,y,width,height] and then uses that to fill a rectangle into the canvas.

        ```

            class CanvasBasics{

              static void register(){

                Sparkflow.createRegistry('canvas',(r){
                    
                    r.addMutation('draw/canvas',(shell){
                       
                        var canvas;

                        shell.makeInport('io:in'); // the io space will be created automatically
                        shell.makeOutport('io:out');

                        shell.port('io:in').forceCondition((n) => n is CanvasElement);

                        shell.tapData('io:in',(n){
                           canvas = n.data;
                           shell.send('io:out',canvas);
                           shell.endStream('io:out'); //always wise to endstream after data is sent
                        });

                    });

                    r.addMutation('draw/rectangle',(shell){

                        var canvas,context;
                        shell.makeInport('io:canvas');
                        shell.makeInport('io:coords');

                        shell.port('io:canvas').forceCondition((n) => n is CanvasElement);
                        shell.port('io:coords').forceCondition((n) => n is List); 
                        shell.port('io:coords').forceCondition((n){
                          if(n.length < 5) return false;
                          return true;
                        });

                        shell.port('io:coords').pause();

                        shell.tapData('io:canvas',(n){
                           canvas = n.data;
                           context = canvas.context2D;
                           shell.port('io:coords').resume();
                        });


                        shell.tapData('io:coords',(n){
                            var cd = n.data;
                            context.save();
                            context.fillStyle = cd[0];
                            context.fillRect(cd[1],cd[2],cd[3],cd[4]);
                            context.restore();
                        });

                    });

                });

              }



        ```
    

    Now that we have a Class with a static function to register the registry into the global
    Sparkflow registry,we have a simple and easy means of creating components and we can 
    as said use it to add components into other components by calling the registry to generate
    a component using the SUBDOMAIN/GROUP/Name format


    the Main method:
    These brings us with the introduction of Networks,the basic block of an fbp process,Network is actually a graph(based of nodelist) structure that adds components into the graph and connects links between them when using the methods for specify port and component connections. Network provides 
    
    - use and useComponent method:
      where the first takes the string of the component path in the component registry and the ther an instance of the component,both take two arguments,the component name or instance and the custom id,to use to filter that component uniquely from the graph

     i.e 
        use(String path,String customid);
        useComponent(Component component,String customid);

    - ensureBinding, ensureUnbinding,looseBinding, looseUnbinding: provide means of specifying component
    and port connections between the network,other components.
     
       i.e 
       ensureBinding(String fromWho,String fromwhoport,String toWho,String toWhoport,String toWhoCustom id)
       ensureUnBinding(String fromWho,String fromwhoport,String toWho,String toWhoport,String toWhoCustom id)
       looseBinding(String fromWho,String fromwhoport,String toWho,String toWhoport,String toWhoCustom id)
       looseUnbinding(String fromWho,String fromwhoport,String toWho,String toWhoport,String toWhoCustom id)

     The difference between the ensure and loose is that the first ensure the connections are initiated at boot time and that it always executed everytime the network is booted while the later just fires off the connection command without garanteed that it rebind when the network is shutdown and booted up again. Its good to use after the network as started and components have been fully added,but ensureBinding ensures no matter what,on boot time,this connection will be made up and not before boot. 

    - schedulePacket,schedulePacketAlways:
     Also two functions provided by the network is the schedulePacket and SchedulePacketAlways, where
     schedulePacket puts a packet to be sent to a component port when the network is booted but its not
     resent after shutdown and bootup ,while the later ensures this,so at every boot schedulePacketAlways will always resend the packets.

     i.e 
        schedulePacket(String component_name,String portName,dynamic packet);
        schedulePacketAlways(String component_name,String portName,dynamic packet);


    ```
        void main(){
          
           var board = window.document.querySelector('#stage');

           CanvasBasics.register(); //register the subdomain registry
           var canvas = Network.create('basic test');

           //add the components and tag them
           canvas.use('canvas/draw/canvas','stage');
           canvas.use('canvas/draw/rectangle','rect');

           //make the connections u need
           canvas.ensureBinding('stage','io:out','rect','io:canvas');

           //send the packets you want to send initially on bootup
           canvas.schedulePacket('stage','io:in',board);
           canvas.schedulePacket('rect','io:coords',['#C02929',20,20,200,300]);

           //boot the network;
           canvas.boot().then(Funcs.tag('booting canvas test')).then((_){
              _.shutdown();
           });

        }
      }

    ```


# RUNNING
    To run just open the index.html file located within the ks101_canvas_basics folder and see the result
