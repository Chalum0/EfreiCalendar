#!/bin/bash

display_lessons() {

    local json_file="$1"
    local week="$2"
    week=$((week - 1))

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

    local json_file="$1"

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

display_lessons_of_type() {

    local json_file="$1"
    type="$2"

    if [[ ! -f "$json_file" ]]; then
        echo "JSON file not found: $json_file"
        return 1
    fi

    jq --arg type "$type" '
        .rows[] |
        select(.prgoOfferingDesc == $type) |
        {
            Date: .srvTimeCrDateFrom,
            Time: "\(.timeCrTimeFrom)-\(.timeCrTimeTo)",
            Description: .prgoOfferingDesc,
            Room: .srvTimeCrDelRoom,
            Teacher: .tchResName
        }' "$json_file" | jq -s 'sort_by(.Date) | .[0:10]'

}

display_hour_for_week() {

    local json_file="$1"
    local week="$2"
    week=$((week - 1))

    if [[ -z "$week" ]]; then
        echo "Please provide a week number (1-52)."
        return 1
    fi

    if [[ ! -f "$json_file" ]]; then
        echo "JSON file not found: $json_file"
        return 1
    fi

    local lesson_count
    lesson_count=$(jq --argjson week "$week" '
        [.rows[] |
        select((.srvTimeCrDateFrom | sub("[+-]\\d{2}:\\d{2}$"; "Z") | fromdateiso8601 | strftime("%U")) == ($week | tostring))
        ] | length
    ' "$json_file")

    local total_hours=$((lesson_count * 5))

    echo "You have a total of $total_hours hours on week $week."

}


display_common_schedule() {

    teacher_schedule=$(jq -r '.rows[] | "\(.srvTimeCrDateFrom) \(.timeCrTimeFrom) \(.timeCrTimeTo)"' "$1")
    student_schedule=$(jq -r '.rows[] | "\(.srvTimeCrDateFrom) \(.timeCrTimeFrom) \(.timeCrTimeTo)"' "$2")

    start_date=$(date -d "+1 day" "+%Y-%m-%d")
    end_date=$(date -d "+30 days" "+%Y-%m-%d")
    hours=("0800" "0900" "1000" "1100" "1200" "1400" "1500" "1600" "1700" "1800")

    for date in $(seq 0 30); do
        current_date=$(date -d "$start_date +$date days" "+%Y-%m-%d")
        day_of_week=$(date -d "$current_date" "+%u")

        if [[ $day_of_week -ge 6 ]]; then
            continue
        fi

        for hour in "${hours[@]}"; do
            teacher_busy=$(echo "$teacher_schedule" | grep "$current_date" | awk -v hour="$hour" '$2 <= hour && $3 > hour')
            student_busy=$(echo "$student_schedule" | grep "$current_date" | awk -v hour="$hour" '$2 <= hour && $3 > hour')

            if [[ -z $teacher_busy && -z $student_busy ]]; then
                echo "Next free period: $current_date at $(echo "$hour" | sed 's/^\(..\)\(..\)$/\1:\2/')"
                return
            fi
        done
    done

    echo "No free period match found in the next 14 days."
}
