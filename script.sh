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
    echo "Choose an option:"
    echo "1. See lessons for a specific week"
    echo "2. See all upcoming tests"
    echo "3. Count the amount of hours in a week"
    read -r choice

    case "$choice" in
        1)
            see_student_lessons
            ;;
        2)
            display_upcoming_tests
            ;;
        3)
            # Calculer le nb d'heure pour une semaine donnée: à implementer
            ;;
        *)
            echo "Invalid option. Please try again."
            student_menu
            ;;
    esac
}

ask_user_role
if [[ $? -eq 0 ]]; then
    echo "Welcome, student!"
    student_menu
else
    echo "Welcome, teacher!"
fi
