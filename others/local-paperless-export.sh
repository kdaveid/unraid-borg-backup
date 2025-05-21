#!/bin/bash
docker exec paperless-ngx document_exporter ../export -p 
/usr/local/emhttp/webGui/scripts/notify -i normal -s "Borg Paperless Export Run" -d " Paperless Export at `date`"
