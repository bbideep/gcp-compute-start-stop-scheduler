import base64, os
from googleapiclient import discovery
from oauth2client.client import GoogleCredentials

def stop_vm(event, context):
    credentials = GoogleCredentials.get_application_default()
    service = discovery.build('compute', 'v1', credentials=credentials)
    project = os.getenv("GCP_PROJECT")
    zone_req = service.zones().list(project=project)
    while zone_req is not None:
        zone_resp = zone_req.execute()
        filter_data = os.getenv("FILTER_DATA")
        for zone in zone_resp['items']:
            #print(zone['name'])
            compute_req = service.instances().list(project=project, zone=zone['name'], filter=filter_data)
            while compute_req is not None:
                compute_resp = compute_req.execute()
                if 'items' in compute_resp:
                    for compute in compute_resp['items']:
                        try:
                            #print(compute['name'])
                            service.instances().start(project=project, zone=zone['name'], resourceId=compute['id'])
                        except:
                            print(compute['name']+ ' start failed.')
                compute_req = service.instances().list_next(previous_request=compute_req, previous_response=compute_resp)
        zone_req = service.zones().list_next(previous_request=zone_req, previous_response=zone_resp)

