## Prerequisites for starting Hands-On

### For Instructors
- Trainees should have already been invited to Vantiq.
- `event_generator` should be running in the instructor's environment.
- Refer [here](https://vantiq.sharepoint.com/:f:/s/jp-tech/EvUXuLjTXnNKqCaJ0e5QapIBrkWoLn-rR1cj2jO-kruZaw?e=h5IUQP) for the current configuration.

### For Trainees
- Vantiq user registration should be completed.
- Vantiq development Namespace should have been created.

![](../../imgs/hands-on-lab/01_before_project_import.png)

## Hands-on Assignment (30 mins)

1. [Import Project into Namespace](#01_project_import)
2. [Check the received data from Source](#02_source)
3. [Check the data processing step by step](#03_view_task_events)
4. [Input data to Type](#04_types)
5. [Generate simulated events (Procedure, Topic)](#05_adhoc_events)
6. [Add collaboration with an external service (reverse geocoding)](#06_external_service)

### 1. Import Project into Namespace<a id="01_project_import"></a>
Download the Project that will be used in this Hands-on Assignment (Link will be provided by the Instructor).  

Go to [Navigation bar] >> [Projects] >> [Import].

![](../../imgs/hands-on-lab/01_menu_project.png)

Drag and drop the Project zip file. Then, Import and reload the screen.
![](../../imgs/hands-on-lab/01_project_zip_dragged.png)

Project has been imported.
![](../../imgs/hands-on-lab/01_project_imported.png)

### 2. Check the received data from Source<a id="02_source"></a>
The App Builder shows that three inputs have already been defined.  
1. `GuardMQTT` - `GuardMqttBroker` Data from Source
2. `AiCameraMQTT` - `AiCameraMqttBroker` Data from Source
3. `AiCameraAdhoc`- Input simulated events for suspicious person detection
![](../../imgs/hands-on-lab/02_app_builder.png)

Of the above, follow the data flowing from `GuardMQTT`, which sends Guard location updates in JSON format once every 5 seconds.  
1. Right click on `GuardMQTT`, and select [View Task Events].
![](../../imgs/hands-on-lab/02_view_task_events_1.png)
1. You can observe the data flowing through `GuadMQTT`.
![](../../imgs/hands-on-lab/02_view_task_events_2.png)
1. Clicking on one of them will display the details and show that the data is in JSON format. It represents the location of the security guard.
![](../../imgs/hands-on-lab/02_view_task_events_3.png)

### 3. Check the data processing step by step<a id="03_view_task_events"></a>
As for the `EnrichGuard` and `TransformGuard`, perform [View Task Events] as in the previous section.  

1. `EnrichGuard` queries the security guard master (`guards` Type) and adds (Enrich) the security guard information whose `guard_id` matches. Compared to the previous step, notice that the `guards` property has been added.  
![](../../imgs/hands-on-lab/03_view_task_events_1.png)

1. `TransformGuard` transforms the output data from the previous step. Now you can see that the data used for processing has been organized and cleaned up.  
![](../../imgs/hands-on-lab/03_view_task_events_2.png)

1. Select a task and [Click to Edit] to see how it is implemented in each step.  
![](../../imgs/hands-on-lab/03_configuration.png)


### 4. Input data to Type<a id="04_types"></a>

1. First, the `AiCameraMQTT` task needs to be able to receive data. The `AiCameraMQTT` task receives data from a Source called `AICameraMqttBroker`. Select `AiCameraMqttBroker` from Source in [Project Contents].     
   <img src="../../imgs/hands-on-lab/04_project_contents_source.png" width=40%>

1. The [Toggle Keep Active On] checkbox in the upper right corner of the `AiCameraMqttBroker` pane is unchecked (Inactive), check it and save.   
![](../../imgs/hands-on-lab/04_aimqtt_source.png)


1. Once the Source becomes Active, data will flow to `AiCameraMQTT` (wait for a while until it receives data, since it receives data once a minute).  
![](../../imgs/hands-on-lab/04_ai_camera_mqtt_source_active.png)

1. Although the data flowed, the `SendEmail` is red. This indicates that an error occurred at that step. The cause is that the `email` appended by `FindNearestGuard` is not valid, so sending the email failed.    
   <img src="../../imgs/hands-on-lab/04_email_error.png" width=70%>

1. Modify the Type of the security guard master that is the origin of the `email` data.  It is possible to edit the Type directly, but for this exercise, modify it from the dedicated Client. Select `MonitorClient` from the Client in [Project Contents].   
   <img src="../../imgs/hands-on-lab/04_monitor_client_select.png" width=40%>

1. Go to [Launch] >> [Run currently saved Client in Client Launcher(RTC)].  
![](../../imgs/hands-on-lab/04_launch_monitor_client.png)

1. Go to the Edit Guard Master screen and update the `email` and `name` for the 5 security guards.  
![](../../imgs/hands-on-lab/04_type_guard_update.png)

1. Return to the App Builder and click on the [Clear Runtime Status] icon (left pointing arrow) in the upper right corner of the pane. This will reset the error status and badge (number of events) display from earlier.  
![](../../imgs/hands-on-lab/04_app_builder_clear_badge.png)

1. After a while, you should receive a suspicious person detection email.    
   <img src="../../imgs/hands-on-lab/04_mail_delivered.png" width=60%>

1. Now that the operation is confirmed, turn off (Inactive) the `AiCameraMqttBroker` Source in order to temporarily stop sending mail.  
![](../../imgs/hands-on-lab/04_aimqtt_source.png)

### 5. Generate simulated events (Procedure, Topic)<a id="05_adhoc_events"></a>

1. Click `AiCameraAdhoc` in the App Builder and check Configuration. Here is the configuration: `InputResource`: `topics`, `inboundResourced`: `/cameras/suspicous_person`. It is possible to take data from internal events with the configured topic name.  
![ ](../../imgs/hands-on-lab/05_topic_input_stream.png)

1. Select `generateAdhocEvent` from Procedure in [Project Contents].  This procedure will create a simulated event (JSON data) and PUBLISH it to the Topic `/cameras/suspicious_person`. Execute the Procedure using the blue arrow button in the upper left corner.  
![](../../imgs/hands-on-lab/05_procedure.png)

1. Once the Procedure is executed, `AiCameraAdhoc` will receive the event and process it.  
![](../../imgs/hands-on-lab/05_procedure_executed.png)

### 6. Add collaboration with an external service (reverse geocoding)<a id="06_external_service"></a>
Reverse geocoding is a service that converts latitude and longitude into addresses.Collaborate with an external reverse geocoding service.  

1. The Procedure `reverseGeoCoding` calls an external service and returns the latitude and longitude as an address. Note that it takes latitude and longitude as arguments and returns a string (address).  
![](../../imgs/hands-on-lab/06_reverseGeocoding_procedure.png)

1. In the App Builder, drag and drop `Transformation` from the list of activities on the left side of the pane to the line between `TransformAiCamera` and `FindNearestGuard`.  
![](../../imgs/hands-on-lab/06_drag_transformation.png)

1. Click on the added Transformation task and [Click to Edit]. Click `<null>` in transformation(Union) to add the transformation process. In Edit Transformation, add Transformation and enter `address`, `reverseGeoCoding(event.lat, event.lon)`.      
   <img src="../../imgs/hands-on-lab/06_transformation_config.png" width=85%>

1. Click on `<null>` in imports, edit imports and add `Procedure`, `reverseGeoCoding`.     
    <img src="../../imgs/hands-on-lab/06_import_config.png" width=85%>

1. Save the changes using the [Save Changes] icon in the upper right corner of the App Builder's pane. Right-click on the added Transformation and select [View Task Events].  
![](../../imgs/hands-on-lab/06_view_task_event.png)  

1. Run `generateAdhocEvent` (or make `AiCameraMqttBroker` Active). Observing the event as it passes through Transformation, notice the addition of the `address` retrieved from the reverse geocoding service.  
![](../../imgs/hands-on-lab/06_address_added.png)
