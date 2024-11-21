#!/bin/bash

source ./functions.sh

# Ask the user if he is a student or a teacher
ask_user_role() {
    echo "Are you a student or a teacher? (0 for student, 1 for teacher)"
    read -r role
    [[ "$role" == "0" || "$role" == "1" ]] && return "$role"
    echo "Invalid input. Please enter 0 or 1."
    ask_user_role
}

# If the user is a student; student menu
student_menu() {

    echo "a"

    stutend_json="calendars/student.json"

    echo "Choose an option:"
    echo "1. See lessons for a specific week"
    echo "2. See all upcoming tests"
    echo "3. Count the amount of hours in a week"
    read -r choice

    case "$choice" in
        1)
            display_lessons $stutend_json
            ;;
        2)
            display_upcoming_tests $stutend_json
            ;;
        3)
            display_hour_for_week $stutend_json
            ;;
        *)
            echo "Invalid option. Please try again."
            student_menu
            ;;
    esac
}

# If the user is a teacher; teacher menu
teacher_menu() {

    echo "b"

    teacher_json="calendars/teacher.json"

    echo "Choose an option:"
    echo "1. See lessons for a specific week"
    echo "2. Count the amount of hours in a week"
    echo "3. Display the future lessons of a certain module"
    echo "4. Find an empty slot in common with a class"
    read -r choice

    case "$choice" in
        1)
            display_lessons $teacher_json
            ;;
        2)
            display_hour_for_week $teacher_json
            ;;
        3)
            display_lessons_of_type $teacher_json
            ;;
        4)
            # Implementer le recherche de créneaux communs
            ;;
        *)
            echo "Invalid option. Please try again."
            teacher_menu
            ;;
    esac

}

ask_user_role
if [[ $? -eq 0 ]]; then
    echo "Welcome, student!"
    student_menu
else
    echo "Welcome, teacher!"
    teacher_menu
fi
