#!/bin/bash
export NOTIFY_PATH=/usr/local/emhttp/webGui/scripts/notify 

docker exec paperless-ngx document_exporter ../export -p 

EXPORT_EXIT_CODE=$?

if [ $EXPORT_EXIT_CODE -eq 0 ]; then
    $NOTIFY_PATH -e PaperlessExport -s "Rocket PaperlessExport succeeded" -d "Success" -i normal
elif [ $EXPORT_EXIT_CODE -eq 1 ]; then
    $NOTIFY_PATH -e PaperlessExport -s "Rocket PaperlessExport warnings" -d "Completed with warnings, exit code: $EXPORT_EXIT_CODE" -i warning
else
    $NOTIFY_PATH -e PaperlessExport -s "Rocket PaperlessExport FAILED" -d "Export failed! Exit Code: $EXPORT_EXIT_CODE" -i warning
    exit $EXPORT_EXIT_CODE
fi

