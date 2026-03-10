#!/bin/bash

set -u

SCRIPT_NAME="$(basename "$0")"
DEFAULT_PARENT_DIR="$(pwd)"
TOTAL_STEPS=10
CURRENT_STEP=0
CURRENT_STEP_TITLE=""

COLOR_BLUE="$(printf '\033[1;34m')"
COLOR_GREEN="$(printf '\033[1;32m')"
COLOR_YELLOW="$(printf '\033[1;33m')"
COLOR_RED="$(printf '\033[1;31m')"
COLOR_CYAN="$(printf '\033[1;36m')"
COLOR_WHITE="$(printf '\033[1;37m')"
COLOR_BOLD="$(printf '\033[1m')"
COLOR_RESET="$(printf '\033[0m')"

PROJECT_NAME="${1:-}"
PARENT_DIR="${2:-$DEFAULT_PARENT_DIR}"
PROJECT_DIR=""

print_blank() {
  printf "\n"
}

print_banner() {
  print_blank
  printf "${COLOR_CYAN}============================================================${COLOR_RESET}\n"
  printf "${COLOR_WHITE}%s${COLOR_RESET}\n" "$1"
  printf "${COLOR_CYAN}============================================================${COLOR_RESET}\n"
}

print_logo() {
  print_blank
  printf "${COLOR_CYAN}                     ?|(((((|(||(((|((?                     \n"
  printf "${COLOR_CYAN}                |((|((((((((((((((((((((||(|                \n"
  printf "${COLOR_CYAN}             (|(((((((((((((((((((((((((((((((|             \n"
  printf "${COLOR_CYAN}          ||((((((((((((((((((((((((((((((((((((()          \n"
  printf "${COLOR_CYAN}        (((((((((((((((((((((((((((((((((((((((((((|        \n"
  printf "${COLOR_CYAN}      )(((((((((((((((((((((((((((((((((((((((((((((()      \n"
  printf "${COLOR_CYAN}     (((((((((((((((((((|(|(|(|||((((((((((((((((((((((     \n"
  printf "${COLOR_CYAN}   O|(((((((((((((((|(        |      |(((((((((((((((((|O   \n"
  printf "${COLOR_CYAN}  \\(((((((((((((((|           ((1        ((((((((((((((((\\  \n"
  printf "${COLOR_CYAN}  (((((((((((((|?             ((((1        (((((((((((((((  \n"
  printf "${COLOR_CYAN} ((((((((((((((               ((((((1        |((((((((((((( \n"
  printf "${COLOR_CYAN}|(((((((((((((                (((((((|(        ((((((((((((|\n"
  printf "${COLOR_CYAN}|((((((((((||                 ((((((((((|        ((((((((((|\n"
  printf "${COLOR_CYAN}((((((((((((                  ((((((((((((|        |((((((((\n"
  printf "${COLOR_CYAN}|((((((((((/                  (((((((((((((||        ||((((|\n"
  printf "${COLOR_CYAN}(((((((((((                   |((((((((((((((|1        (((((\n"
  printf "${COLOR_CYAN}|((((((((((|                   (((((((((((((((((1        (((\n"
  printf "${COLOR_CYAN}|((((((((((|                ((|( |(((((((((((((((()        /\n"
  printf "${COLOR_CYAN}|(((((((((((|             ((((((|| ||((((((((((((((()       \n"
  printf "${COLOR_CYAN}O(((((((((((|1          |(((((((((|| (|(((((((((((((((|     \n"
  printf "${COLOR_CYAN} |((((((((((((|       ((((((((((((((|( (|((((((((((((((||   \n"
  printf "${COLOR_CYAN}  |(((((((((((((    (|((((((((((((((((|( ||((((((((((((((|  \n"
  printf "${COLOR_CYAN}   (((((((((((((|(((((((((((((((((((((((|((((((((((((((((   \n"
  printf "${COLOR_CYAN}    (|((((((((((((((((((((((((((((((((((((((((((((((((((    \n"
  printf "${COLOR_CYAN}     \\((((((((((((((((((((((((((((((((((((((((((((((((|     \n"
  printf "${COLOR_CYAN}       (((((((((((((((((((((||(((((((((((((((((((((((       \n"
  printf "${COLOR_CYAN}         |((((((((((((((((((    (((((((((((((((((||         \n"
  printf "${COLOR_CYAN}           |((((((((((((((        (|((((((((((((|           \n"
  printf "${COLOR_CYAN}              |((|(((((|            ((((((|((|              \n"
  printf "${COLOR_CYAN}                 ?(|||                ((|(?                 \n"
  printf "${COLOR_WHITE}                         GAMEWORKS                         \n"
  printf "${COLOR_RESET}"
}

print_status_tag() {
  printf "${COLOR_BLUE}[STEP %d/%d]${COLOR_RESET}" "$CURRENT_STEP" "$TOTAL_STEPS"
}

print_subtle_rule() {
  printf "${COLOR_CYAN}------------------------------------------------------------${COLOR_RESET}\n"
}

print_step_header() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  CURRENT_STEP_TITLE="$1"
  print_blank
  print_status_tag
  printf " ${COLOR_BOLD}%s${COLOR_RESET}\n" "$CURRENT_STEP_TITLE"
  print_subtle_rule
}

print_info() {
  printf "\033[1;44;97m INFO \033[0m %s\n" "$1"
}

print_success() {
  printf "\033[1;42;97m DONE \033[0m %s\n" "$1"
}

print_warning() {
  printf "\033[1;43;30m WARN \033[0m %s\n" "$1"
}

print_error() {
  printf "\033[1;41;97m FAIL \033[0m %s\n" "$1"
}

print_card_line() {
  printf "  %-20s %s\n" "$1" "$2"
}

print_summary_line() {
  printf "  %s: %s\n" "$1" "$2"
}

print_key() {
  printf "\033[1;100;97m %s \033[0m" "$1"
}

prompt_project_name() {
  local answer=""

  print_step_header "프로젝트 이름"
  while [ -z "$PROJECT_NAME" ]; do
    print_info "프로젝트 이름을 입력하세요."
    printf "       입력 후 "
    print_key "Enter"
    printf " 를 누르세요.\n"
    read -r answer
    PROJECT_NAME="$answer"

    if [ -z "$PROJECT_NAME" ]; then
      print_warning "프로젝트 이름은 비워둘 수 없습니다."
    fi
  done
}

prompt_parent_dir() {
  local answer=""

  print_step_header "프로젝트 위치"
  print_info "프로젝트를 만들 위치를 입력하세요. 그냥 Enter를 누르면 현재 폴더를 사용합니다."
  print_info "현재 기본 위치: $DEFAULT_PARENT_DIR"
  printf "       기본 위치를 그대로 사용하려면 "
  print_key "Enter"
  printf " 를 누르세요.\n"
  read -r answer

  if [ -n "$answer" ]; then
    PARENT_DIR="$answer"
  fi
}

validate_inputs() {
  if [ ! -d "$PARENT_DIR" ]; then
    print_error "대상 폴더가 존재하지 않습니다: $PARENT_DIR"
    exit 1
  fi

  PROJECT_DIR="$PARENT_DIR/$PROJECT_NAME"

  if [ -e "$PROJECT_DIR" ]; then
    print_error "같은 이름의 파일 또는 폴더가 이미 존재합니다: $PROJECT_DIR"
    exit 1
  fi
}

create_project_tree() {
  mkdir -p "$PROJECT_DIR/.vscode"
}

write_main_c() {
  cat > "$PROJECT_DIR/main.cpp" <<'EOF'
#include <iostream>

int main() {
    std::cout << "Hello, C++ on macOS!" << std::endl;
    return 0;
}
EOF
}

write_tasks_json() {
  cat > "$PROJECT_DIR/.vscode/tasks.json" <<'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "type": "cppbuild",
            "label": "C/C++: clang++ 활성 파일 빌드",
            "command": "/usr/bin/clang++",
            "args": [
                "-fcolor-diagnostics",
                "-fansi-escape-codes",
                "-g",
                "${file}",
                "-o",
                "${fileDirname}/${fileBasenameNoExtension}"
            ],
            "options": {
                "cwd": "${fileDirname}"
            },
            "problemMatcher": [
                "$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "detail": "자동 생성된 clang++ 빌드 작업입니다."
        }
    ]
}
EOF
}

write_launch_json() {
  cat > "$PROJECT_DIR/.vscode/launch.json" <<'EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "C/C++: 활성 파일 실행",
            "type": "lldb",
            "request": "launch",
            "program": "${fileDirname}/${fileBasenameNoExtension}",
            "args": [],
            "cwd": "${fileDirname}",
            "terminal": "integrated",
            "preLaunchTask": "C/C++: clang++ 활성 파일 빌드"
        }
    ]
}
EOF
}

write_extensions_json() {
  cat > "$PROJECT_DIR/.vscode/extensions.json" <<'EOF'
{
    "recommendations": [
        "ms-vscode.cpptools",
        "ms-vscode.cmake-tools",
        "vadimcn.vscode-lldb"
    ]
}
EOF
}

write_gitignore() {
  cat > "$PROJECT_DIR/.gitignore" <<'EOF'
main
*.dSYM/
EOF
}

print_summary() {
  print_blank
  printf "${COLOR_BOLD}%s${COLOR_RESET}\n" "생성 완료"
  print_subtle_rule
  print_summary_line "프로젝트 폴더" "$PROJECT_DIR"
  print_summary_line "소스 파일" "$PROJECT_DIR/main.cpp"
  print_summary_line "빌드 설정" "$PROJECT_DIR/.vscode/tasks.json"
  print_summary_line "실행 설정" "$PROJECT_DIR/.vscode/launch.json"
  print_summary_line "확장 추천" "$PROJECT_DIR/.vscode/extensions.json"
  print_subtle_rule
}

print_next_steps() {
  print_blank
  printf "${COLOR_BOLD}%s${COLOR_RESET}\n" "다음 단계"
  printf "  1. VS Code로 %s 폴더를 여세요.\n" "$PROJECT_DIR"
  printf "  2. 추천 확장이 뜨면 설치하세요.\n"
  printf "  3. main.cpp를 열고 F5를 누르면 빌드 후 바로 실행됩니다.\n"
}

main() {
  if [ "$#" -ge 2 ]; then
    TOTAL_STEPS=9
  fi

  print_step_header "시작"
  print_logo
  print_banner "VS Code 프로젝트 생성 스크립트"
  print_info "VS Code C/C++ 프로젝트 템플릿을 만듭니다."

  prompt_project_name
  if [ "$#" -lt 2 ]; then
    prompt_parent_dir
  fi
  validate_inputs

  print_step_header "프로젝트 폴더 생성"
  print_info "프로젝트 폴더를 생성합니다."
  create_project_tree

  print_step_header "샘플 코드 생성"
  print_info "main.cpp를 생성합니다."
  write_main_c

  print_step_header "빌드 설정 생성"
  print_info "VS Code 빌드 설정을 생성합니다."
  write_tasks_json

  print_step_header "실행 설정 생성"
  print_info "VS Code 실행 설정을 생성합니다."
  write_launch_json

  print_step_header "확장 추천 생성"
  print_info "VS Code 추천 확장 목록을 생성합니다."
  write_extensions_json

  print_step_header "기본 파일 생성"
  print_info "기본 .gitignore를 생성합니다."
  write_gitignore

  print_step_header "마무리"
  print_success "C++ 프로젝트 템플릿 생성이 완료되었습니다."
  print_summary
  print_next_steps
}

main "$@"
