#!/bin/bash

source ./functions.sh

role=""
choice=""
args=()

usage() {
    echo "Usage: $0 [-r role] [-c choice] [additional options]"
    echo "  -r, --role      Role: 0 for student or 1 for teacher"
    echo "  -c, --choice    Menu choice number"
    echo "Additional options depend on the choice selected."
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -r|--role)
            role="$2"
            shift 2
            ;;
        -c|--choice)
            choice="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            args+=("$1")
            shift
            ;;
    esac
done


# Ask the user if he is a student or a teacher
ask_user_role() {
    if [ -z "$role" ]; then
        echo "Are you a student or a teacher? (0 for student, 1 for teacher)"
        read -r role
        [[ "$role" == "0" || "$role" == "1" ]] && return 0
        echo "Invalid input. Please enter 0 or 1."
        role=""
        ask_user_role
    else
        if [[ "$role" != "0" && "$role" != "1" ]]; then
            echo "Invalid role specified. Please enter 0 for student or 1 for teacher."
            role=""
            ask_user_role
        fi
    fi
}

# If the user is a student; student menu
student_menu() {

    echo "Welcome, student!"

    student_json="calendars/student.json"

    if [ -z "$choice" ]; then
        echo "Choose an option:"
        echo "1. See lessons for a specific week"
        echo "2. See all upcoming tests"
        echo "3. Count the amount of hours in a week"
        read -r choice
    fi

    case "$choice" in
        1)
            week_number="${args[0]}"
            if [ -z "$week_number" ]; then
                echo "Enter the week number:"
                read -r week_number
            fi
            display_lessons "$student_json" "$week_number"
            ;;
        2)
            display_upcoming_tests "$student_json"
            ;;
        3)
            week_number="${args[0]}"
            if [ -z "$week_number" ]; then
                echo "Enter the week number:"
                read -r week_number
            fi
            display_hour_for_week "$student_json" "$week_number"
            ;;
        *)
            echo "Invalid option. Please try again."
            choice=""
            student_menu
            ;;
    esac
}

# If the user is a teacher; teacher menu
teacher_menu() {

    echo "Welcome, teacher!"

    teacher_json="calendars/teacher.json"
    student_json="calendars/student.json"

    if [ -z "$choice" ]; then
        echo "Choose an option:"
        echo "1. See lessons for a specific week"
        echo "2. Count the amount of hours in a week"
        echo "3. Display the future lessons of a certain module"
        echo "4. Find an empty slot in common with a class"
        read -r choice
    fi

    case "$choice" in
        1)
            week_number="${args[0]}"
            if [ -z "$week_number" ]; then
                echo "Enter the week number:"
                read -r week_number
            fi
            display_lessons "$teacher_json" "$week_number"
            ;;
        2)
            week_number="${args[0]}"
            if [ -z "$week_number" ]; then
                echo "Enter the week number:"
                read -r week_number
            fi
            display_hour_for_week "$teacher_json" "$week_number"
            ;;
        3)
            module_name="${args[0]}"
            if [ -z "$module_name" ]; then
                echo "Enter the module name:"
                read -r module_name
            fi
            display_lessons_of_type "$teacher_json" "$module_name"
            ;;
        4)
            display_common_schedule "$teacher_json" "$student_json"
            ;;
        *)
            echo "Invalid option. Please try again."
            choice=""
            teacher_menu
            ;;
    esac

}

ask_user_role
if [[ "$role" == "0" ]]; then
    student_menu
else
    teacher_menu
fi
