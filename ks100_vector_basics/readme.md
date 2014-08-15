#Vector Basics

##Introduction

These tutorial provides basics on the creation of components and how components create ports for communication between each other,it provides a basic understand to how components are created. In sparkflow there exist two approaches to the creation of component where each is left to the developer to choose.
The first approach using the standard class inheritance approach where you simple inherit from <Component> class while the second approach uses a shell (i.e a new Component Instance) and lets you define the behaviours for that component shell and how it operates.
In these tutorial we will go with the first method as it provides a natural introduction with OOB languages but i would encourage use of the second method which you will see more in the next tutorial

##Details
  These is a basic examples of vector addition and subtraction operation and how to create components
  to encapsulate these behaviours and how they interact with ports.

  Components are blocks that contain a basic principle of how a operation process works,they define
  ports through which data come in and go out and can be made typedsafe through procedures that exist
  on the ports.

  Ports: These are simple streams/channels which data passes through,it is asynchronous and each data passed into a port is wrapped up in a <Parket> Class Instance,which allows designation of the type of packet (i.e data packet,a begingroup packet,end group packet) and provide convenient methods to listen for
  each type of packets.

##Design

  We wil be creating the first vector component which is the addition component:

     The natural starting place is to first extend the Component class, the component class accepts
     a single argument which standards a an id for that component,it can be anything really but 
     i generally called it the class name of the vector as it will be used within the ui to identify
     the component as such. So my advice,name as such.
     These component is simple,it has two list items which will contain the two vector values which we
     will be adding together,generally these will take two value list and not more that that,compoents
     have a metas map object that contains meta data and they can easily be filled with the necessary 
     information concerning that component,the values can be updated and changed using the meta instance
     function

              ```
                class Vector2Add extends Component{
                  List v1,v2;

                  Vector2Add(): super('VectorAdd'){
                    this.meta('id','VectorAdd');
                    this.meta('description','adds two vector list together');
              ```


      To create ports within a component,we need to first create a group for those ports,
      to use,its allows a form of namespacing and the group can be called anything,but 
      preferable make it meaningful. The method createSpace,creates the the group for the ports
      and when using the makeInport or makeOutport functions to create ports,the format for names
      must always follow GROUP_NAME:PORT_NAME, as the ports get added into that group and its mandatory
      required format.
      Inports and Outports generally are the same,except for semantics,that is,Inports are for incoming
      data and Outports are for outgoing data and these should be the order.

              ```
                    this.createSpace('in');
                    this.makeInport('in:v1'); //port for the first vector
                    this.makeInport('in:v2'); //port for the second vector

                    this.createSpace('out'); // group for output ports
                    this.makeOutport('out:result');
              ```
    To force type or create a condition under which data for ports can be allowed into the components
    ports, there exist the forceCondition function,a port can be trieved through the port(String id)
    functions,if the port exist it will be retrieved and returned so you can send or perform such 
    operation as below with it.
    ForceCondition takes functions that return a bool value of FALSE or TRUTH,where if any of the
    supplied functions fails (i.e returns false) the packet is rejected and booted off the port
    only packets that passes all test passes through, also forceCondition only works on packets that
    are data events,there exist forceBGCondition,forceEGCondition for beginGroup and endGroup 
    respectfully

          ```
                this.port('in:v1').forceCondition((n) => n is List); 
                this.port('in:v2').forceCondition((n) => n is List); 
                this.port('in:v1').forceCondition((n){
                  if(n.length > 2) return false;
                  return true;
                }); 

                this.port('in:v2').forceCondition((n){
                  if(n.length > 2) return false;
                  return true;
                }); 
        
          ```

    Ports stream data and to be able to listen to these streams,it provides the tap,tapData,tapBeginGroup,tapEndGroup functions that take a function as an argument, where the tap function,allows access to any packet of any type be it data,beginGroup and endGroup and the rest allows listening only for specific packet type.
    With these component we listen to the two ports for the two supplied vectors and the call the add instance function of this class,to add up the vector values

        ```
              this.port('in:v1').tapData((n){ //lets only listen for data events
                this.v1 = n.data;
                this.add(); 
              });

              this.port('in:v2').tapData((n){
                this.v2 = n.data;
                this.add(); // calls to execute the add operation
              });

          }

        ```

    As above,each inports calls out to add,add checks if the two values list have been provided,if not
    it does not execute,if they are,then it process and sends out the new vector values through the
    outport as below,as you can see FBP is not contraint much on time of arrival,when conditions set
    are met,then responses are generated,we are not bound to always get data sent within time limits
    unless that is intentionally put into the design but thats generally against asynchronous thinking
    but its not wrong either, the developer has the ultimate choice on these

      ```
        void add(){
            if(Valids.notExist(v1) || Valids.notExist(v2)) return null;
            var add = new List(2);
            add[0] = this.v1[0] + this.v2[0];
            add[1] = this.v1[1] + this.v2[1];

            this.port('out:result').send(add); // send out the result to the outport
            this.port('out:result').endStream(); //always endstream after you sent all data;
          }
        }

      ```


      The class for Vector subtraction is pretty much similar as below:

        ```

            class Vector2Subtract extends Component{
              List v1,v2;

              Vector2Subtract(): super('VectorSubtract'){

                this.createSpace('in');
                this.createSpace('out');

                this.makeInport('in:v1'); 
                this.makeInport('in:v2'); 
                this.makeOutport('out:result');

                this.port('in:v1').forceCondition((n) => n is List); 
                this.port('in:v2').forceCondition((n) => n is List); 

                this.port('in:v1').forceCondition((n){
                  if(n.length > 2) return false;
                  return true;
                }); 

                this.port('in:v2').forceCondition((n){
                  if(n.length > 2) return false;
                  return true;
                }); 

                this.port('in:v1').tapData((n){
                  this.v1 = n.data;
                  this.subtract(); 
                });

                this.port('in:v2').tapData((n){
                  this.v2 = n.data;
                  this.subtract(); 
                });

              }

              void subtract(){
                if(Valids.notExist(v1) || Valids.notExist(v2)) return null;
                var sub = new List(2);
                sub[0] = this.v1[0] - this.v2[0];
                sub[1] = this.v1[1] - this.v2[1];

                this.port('out:result').send(sub); // send out the result to the outport
                this.port('out:result').endStream(); //always endstream after you sent all data;
              }

            }

        ```


    So now that we have our components to begin to use them,its pretty simple,create the instances
    connect the ports as need and start sending of data and watch them play like below:

      ``` 

          void main(){
            
              var add = new Vector2Add();
              var sub = new Vector2Subtract();
              var sub2 = new Vector2Subtract(); // lets have abit of fun with this

              // these are functions that take a value and prints them out with the title
              // the definition is located within the Hub library,
              // its not different from running print('Vector Addtion $res')

              var addPrinter = Funcs.tag('Vector Addition');
              var subtractPrinter = Funcs.tag('Vector Subtraction');
              var boundPrinter = Funcs.tag('Bound Vector Subtraction');
              
              // lets bind into the output port for the result to be printer out
              add.port('out:result').tapData(addPrinter);
              sub.port('out:result').tapData(subtractPrinter);
              sub2.port('out:result').tapData(boundPrinter);

        ```

        Ports can be bound to each other using the bindPort(Port p,String id,bool endStream) function,
        where the first value is the port,the second custom id incase we only want to send data
        to that port alone and not all connected ports and a bool value to tell the port to call
        the port being connected endStream method when it calls its own.
        EndStream is a means to signal end of a stream of data,its useful when sending groups of
        packets and you need to decided when one group is done and anther group of streams begin
        to always endStream you ports when you done sending data because some components do listen
        to it for their operations,so always do so.
        Here we bind the result from the addition of the vectors from component 'add' as the input
        for the 'sub2' subtraction first vector values.
        ```
              add.port('out:result').bindPort(sub2.port('in:v1')); // we can bindports together

        ```

        Here are the data for the components and we send that into the ports for each components
        ```
              var v1 = [20,10], v2 = [30,40]; // out vectors

              add.port('in:v1').send(v1);
              add.port('in:v2').send(v2);

              sub.port('in:v1').send(v1);
              sub.port('in:v2').send(v2);

              sub2.port('in:v2').send(v2);
          }

      ```


    And thats basically how components are created and work,please look into the vector_basics.dart
    file for the code and run it to see the result. Enjoy
