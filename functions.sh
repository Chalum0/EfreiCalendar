#!/bin/bash

see_student_lessons() {

    # Asks for a week and displays the lessons for that wek

    echo "Enter the week number:"
    read -r week
    local json_file="student.json"

    if [[ -z "$week" ]]; then
        echo "Please provide a week number (1-52)."
        return 1
    fi

    if [[ ! -f "$json_file" ]]; then
        echo "JSON file not found: $json_file"
        return 1
    fi

    jq --argjson week "$week" '
    .rows[] |
    select((.srvTimeCrDateFrom | sub("[+-]\\d{2}:\\d{2}$"; "Z") | fromdateiso8601 | strftime("%U")) == ($week | tostring)) |
    {
        Date: .srvTimeCrDateFrom,
        Time: "\(.timeCrTimeFrom)-\(.timeCrTimeTo)",
        Description: .prgoOfferingDesc,
        Room: .srvTimeCrDelRoom,
        Teacher: .tchResName
    }
    ' "$json_file"
}

display_upcoming_tests() {

    # Displays the 10 upcomming lessons

    local json_file="student.json"

    if [[ ! -f "$json_file" ]]; then
        echo "JSON file not found: $json_file"
        return 1
    fi

    jq '
        .rows[] |
        select(.srvTimeCrActivityId == "SURVEILLANCE" or .soffDeliveryMode == "CONTROLECRIT" or .soffDeliveryMode == "DEVOIRECRIT") |
        {
            Date: .srvTimeCrDateFrom,
            Time: "\(.timeCrTimeFrom)-\(.timeCrTimeTo)",
            Description: .prgoOfferingDesc,
            Room: .srvTimeCrDelRoom,
            Teacher: .tchResName
        }' "$json_file" | jq -s 'sort_by(.Date) | .[0:10]'
}