	if (!data.message) {
       var MAX_LENGTH = 40;
       var data = {
           "camera_id": data.camera_id,
           "event_type": data.event_type,
           "image": data.image.substr(0, MAX_LENGTH) + '...',
           "timestamp": data.timestamp
       };        
    }
   client.data.lastAiCamData = JSON.stringify(data, null, 2);