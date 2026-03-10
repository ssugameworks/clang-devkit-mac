#!/bin/bash

set -u

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$(basename "$0")"
LOG_FILE="$SCRIPT_PATH/setup-clang-macos.log"
TOTAL_STEPS=11
CURRENT_STEP=0
CURRENT_STEP_TITLE=""
LAST_COMMAND=""
USER_CONFIRMED=""
WANT_VSCODE="no"

COLOR_BLUE="$(printf '\033[1;34m')"
COLOR_GREEN="$(printf '\033[1;32m')"
COLOR_YELLOW="$(printf '\033[1;33m')"
COLOR_RED="$(printf '\033[1;31m')"
COLOR_CYAN="$(printf '\033[1;36m')"
COLOR_WHITE="$(printf '\033[1;37m')"
COLOR_BOLD="$(printf '\033[1m')"
COLOR_RESET="$(printf '\033[0m')"

STATUS_XCODE="대기 중"
STATUS_BREW="대기 중"
STATUS_BREW_ENV="대기 중"
STATUS_CMAKE="대기 중"
STATUS_NINJA="대기 중"
STATUS_GIT="대기 중"
STATUS_C_TEST="대기 중"
STATUS_CPP_TEST="대기 중"
STATUS_ADMIN="대기 중"
STATUS_VSCODE="건너뜀"
STATUS_VSCODE_EXT="건너뜀"

BREW_BIN=""
BREW_PREFIX=""
PROFILE_FILE=""
ARCH_LABEL=""

exec > >(tee "$LOG_FILE") 2>&1

on_error() {
  local exit_code="$1"
  local line_number="$2"

  print_banner "INSTALL FAILED"
  print_error_line "설치가 중단되었습니다."
  print_line "  STEP    ${CURRENT_STEP_TITLE:-알 수 없음}"
  print_line "  LINE    ${SCRIPT_NAME} ${line_number}번째 줄"

  if [ -n "$LAST_COMMAND" ]; then
    print_line "  CMD     $LAST_COMMAND"
  fi

  print_blank
  printf "${COLOR_BOLD}%s${COLOR_RESET}\n" "가능한 원인"
  case "$CURRENT_STEP_TITLE" in
    *"Xcode Command Line Tools"*)
      print_line "  - Apple 개발 도구 설치 확인 창이 아직 끝나지 않았을 수 있습니다."
      print_line "  - 관리자 권한 승인 또는 시스템 팝업 확인이 필요할 수 있습니다."
      ;;
    *"Homebrew 설치"*)
      print_line "  - 인터넷 연결이 불안정하거나 Homebrew 다운로드가 차단되었을 수 있습니다."
      print_line "  - 회사/학교 네트워크 정책 때문에 설치 스크립트 실행이 막혔을 수 있습니다."
      ;;
    *"Homebrew 환경 설정"*)
      print_line "  - 셸 설정 파일에 쓰기 권한이 없거나 파일 형식이 예상과 다를 수 있습니다."
      ;;
    *"패키지 설치"*)
      print_line "  - Homebrew 저장소 갱신 또는 패키지 다운로드 중 문제가 발생했을 수 있습니다."
      ;;
    *"컴파일 테스트"*)
      print_line "  - Command Line Tools 설치가 완전히 끝나지 않았거나 경로 인식이 아직 반영되지 않았을 수 있습니다."
      ;;
    *)
      print_line "  - 일시적인 네트워크 또는 권한 문제일 수 있습니다."
      ;;
  esac

  print_blank
  printf "${COLOR_BOLD}%s${COLOR_RESET}\n" "다음에 확인할 것"
  print_line "  1. 터미널 창에 권한 승인 또는 설치 확인 창이 떠 있지 않은지 확인하세요."
  print_line "  2. 인터넷 연결이 정상인지 확인하세요."
  print_line "  3. 아래 로그 파일을 열어 자세한 내용을 확인하세요."
  print_line "     $LOG_FILE"

  print_summary
  exit "$exit_code"
}

trap 'on_error $? $LINENO' ERR

print_line() {
  printf "%s\n" "$1"
}

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

print_error_line() {
  printf "\033[1;41;97m FAIL \033[0m %s\n" "$1"
}

print_card_line() {
  printf "  %-20s %s\n" "$1" "$2"
}

print_key() {
  printf "\033[1;100;97m %s \033[0m" "$1"
}

select_editor_option() {
  local answer=""

  print_step_header "VS Code 선택"
  print_info "VS Code를 함께 설치하면 C/C++ 확장까지 자동으로 설정합니다."
  printf "\033[1;44;97m INFO \033[0m 설치하려면 "
  print_key "Y"
  printf " 를 입력하고 "
  print_key "Enter"
  printf " 를 누르세요.\n"
  printf "       건너뛰려면 "
  print_key "Enter"
  printf " 를 누르세요.\n"

  while true; do
    read -r answer
    case "$answer" in
      Y|y)
        WANT_VSCODE="yes"
        STATUS_VSCODE="대기 중"
        STATUS_VSCODE_EXT="대기 중"
        print_success "VS Code 설치를 함께 진행합니다."
        break
        ;;
      "")
        WANT_VSCODE="no"
        STATUS_VSCODE="건너뜀"
        STATUS_VSCODE_EXT="건너뜀"
        print_info "VS Code 설치는 건너뜁니다."
        break
        ;;
      *)
        printf "\033[1;43;30m WARN \033[0m "
        print_key "Y"
        printf " 를 입력해 VS Code를 설치하거나, "
        print_key "Enter"
        printf " 를 눌러 건너뛰어 주세요.\n"
        ;;
    esac
  done
}

confirm_installation() {
  local answer=""

  print_blank
  printf "${COLOR_BOLD}%s${COLOR_RESET}\n" "설치 안내"
  print_subtle_rule
  print_line "  C/C++ 과제를 바로 시작할 수 있는 환경을 준비합니다."
  print_blank
  printf "${COLOR_BOLD}%s${COLOR_RESET}\n" "  설치 항목"
  print_card_line "Xcode Tools" "clang/clang++ 컴파일러"
  print_card_line "Homebrew" "macOS용 패키지 관리자"
  print_card_line "CMake" "프로젝트 빌드 설정 도구"
  print_card_line "Ninja" "빠른 빌드 실행 도구"
  print_card_line "Git" "버전 관리 시스템"
  print_blank
  printf "${COLOR_BOLD}%s${COLOR_RESET}\n" "  참고 사항"
  print_line "  설치에는 보통 30분 정도 걸립니다."
  print_line "  설치 창이 나타나거나, 비밀번호를 요구할 수 있습니다."
  print_blank
  printf "  설치를 진행하려면 "
  print_key "Y"
  printf " 를 입력하고 "
  print_key "Enter"
  printf " 를 누르세요.\n"
  print_subtle_rule

  read -r answer

  case "$answer" in
    Y|y)
      USER_CONFIRMED="yes"
      print_success "설치를 계속 진행합니다."
      ;;
    *)
      USER_CONFIRMED="no"
      print_warning "사용자 요청으로 설치를 취소했습니다."
      exit 0
      ;;
  esac
}

run_cmd() {
  LAST_COMMAND="$*"
  "$@"
  LAST_COMMAND=""
}

run_shell_cmd() {
  LAST_COMMAND="$1"
  /bin/bash -lc "$1"
  LAST_COMMAND=""
}

detect_profile_file() {
  local shell_name
  shell_name="$(basename "${SHELL:-/bin/zsh}")"

  case "$shell_name" in
    zsh)
      PROFILE_FILE="$HOME/.zprofile"
      ;;
    bash)
      PROFILE_FILE="$HOME/.bash_profile"
      ;;
    *)
      PROFILE_FILE="$HOME/.profile"
      ;;
  esac
}

append_if_missing() {
  local target_file="$1"
  local expected_line="$2"

  if [ -f "$target_file" ] && grep -Fqx "$expected_line" "$target_file"; then
    return 0
  fi

  printf "\n%s\n" "$expected_line" >> "$target_file"
}

wait_for_clt_install() {
  local attempts=0

  while ! xcode-select -p >/dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [ "$attempts" -gt 90 ]; then
      print_warning "Xcode Command Line Tools 설치 완료를 15분 동안 기다렸지만 확인하지 못했습니다."
      print_line "  설치 창이 남아 있다면 마무리한 뒤 다시 실행해 주세요."
      return 1
    fi

    if [ "$attempts" -eq 1 ]; then
      print_info "Apple 설치 창이 뜨면 '설치'를 눌러 진행하세요."
      print_info "설치가 끝날 때까지 기다리는 중입니다."
    fi

    sleep 10
  done
}

print_summary() {
  print_blank
  printf "${COLOR_BOLD}%s${COLOR_RESET}\n" "설치 결과"
  print_subtle_rule
  print_card_line "Admin Access" "$STATUS_ADMIN"
  print_card_line "Xcode Tools" "$STATUS_XCODE"
  print_card_line "Homebrew" "$STATUS_BREW"
  print_card_line "Brew Env" "$STATUS_BREW_ENV"
  print_card_line "CMake" "$STATUS_CMAKE"
  print_card_line "Ninja" "$STATUS_NINJA"
  print_card_line "Git" "$STATUS_GIT"
  print_card_line "VS Code" "$STATUS_VSCODE"
  print_card_line "VS Code Ext" "$STATUS_VSCODE_EXT"
  print_card_line "C Test" "$STATUS_C_TEST"
  print_card_line "C++ Test" "$STATUS_CPP_TEST"
  print_subtle_rule
  print_card_line "로그 파일" "$LOG_FILE"
}

step_intro() {
  print_step_header "설치 준비"
  print_logo
  print_banner "macOS C/C++ Setup"
  print_info "게임웍스 가입을 환영합니다!"
  print_info "이 스크립트는 C/C++ 설치를 자동화합니다."
  print_info "문의사항은 부회장 홍준우에게 갠톡 주세요."
  confirm_installation
  select_editor_option
}

step_check_system() {
  print_step_header "시스템 확인"

  if [ "$(uname -s)" != "Darwin" ]; then
    print_line "이 스크립트는 macOS 전용입니다."
    exit 1
  fi

  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    print_error_line "이 스크립트는 sudo 없이 실행해야 합니다."
    print_line "  Homebrew는 root 계정으로 설치할 수 없습니다."
    print_line "  터미널에서 sudo를 빼고 다시 실행해 주세요."
    exit 1
  fi

  if ! /usr/sbin/dseditgroup -o checkmember -m "$(id -un)" admin | grep -q "yes"; then
    print_warning "이 설치는 관리자 권한이 가능한 계정이 필요합니다."
    print_line "  Homebrew와 Apple 개발 도구 설치 과정에서 macOS 관리자 인증이 필요할 수 있습니다."
    print_line "  현재 계정이 관리자 계정이 아니라면 설치 중 다음 오류가 날 수 있습니다."
    print_line "  Need sudo access on macOS (e.g. the user ... needs to be an Administrator)"
    print_blank
    print_line "  해결 방법"
    print_line "  1. 관리자 계정으로 로그인해서 다시 실행하세요."
    print_line "  2. 또는 Mac 관리자에게 현재 계정을 Administrators 그룹에 추가해 달라고 요청하세요."
    exit 1
  fi

  STATUS_ADMIN="완료"

  case "$(uname -m)" in
    arm64)
      ARCH_LABEL="Apple Silicon"
      ;;
    x86_64)
      ARCH_LABEL="Intel"
      ;;
    *)
      ARCH_LABEL="$(uname -m)"
      ;;
  esac

  detect_profile_file

  print_success "macOS 확인 완료"
  print_info "CPU 종류: $ARCH_LABEL"
  print_info "현재 셸: $(basename "${SHELL:-알 수 없음}")"
  print_info "환경 설정 파일: $PROFILE_FILE"
}

step_install_xcode_clt() {
  print_step_header "Xcode Command Line Tools 확인 및 설치"

  if xcode-select -p >/dev/null 2>&1; then
    STATUS_XCODE="완료"
    print_success "이미 설치되어 있습니다. 건너뜁니다."
    return
  fi

  print_info "Apple 개발 도구가 아직 설치되지 않았습니다."
  print_info "이제 설치를 요청합니다."
  run_cmd xcode-select --install || true
  wait_for_clt_install
  STATUS_XCODE="완료"
  print_success "Xcode Command Line Tools 설치가 확인되었습니다."
}

step_install_homebrew() {
  print_step_header "Homebrew 확인 및 설치"

  if command -v brew >/dev/null 2>&1; then
    BREW_BIN="$(command -v brew)"
    STATUS_BREW="완료"
    print_success "이미 설치되어 있습니다. 건너뜁니다."
    print_info "brew 위치: $BREW_BIN"
    return
  fi

  print_info "Homebrew가 아직 설치되지 않았습니다."
  print_info "패키지 설치를 위해 Homebrew를 설치합니다."
  run_shell_cmd 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  BREW_BIN="$(command -v brew || true)"

  if [ -z "$BREW_BIN" ]; then
    if [ -x /opt/homebrew/bin/brew ]; then
      BREW_BIN="/opt/homebrew/bin/brew"
    elif [ -x /usr/local/bin/brew ]; then
      BREW_BIN="/usr/local/bin/brew"
    fi
  fi

  if [ -z "$BREW_BIN" ]; then
    print_line "Homebrew 설치 후 brew 실행 파일을 찾지 못했습니다."
    exit 1
  fi

  STATUS_BREW="완료"
  print_success "Homebrew 설치가 완료되었습니다."
  print_info "brew 위치: $BREW_BIN"
}

step_configure_brew_env() {
  print_step_header "Homebrew 환경 설정"

  if [ -z "$BREW_BIN" ]; then
    BREW_BIN="$(command -v brew)"
  fi

  BREW_PREFIX="$("$BREW_BIN" --prefix)"

  print_info "이 세션에서 brew를 사용할 수 있게 설정합니다."
  LAST_COMMAND="eval \"\$($BREW_BIN shellenv)\""
  eval "$("$BREW_BIN" shellenv)"
  LAST_COMMAND=""

  append_if_missing "$PROFILE_FILE" "eval \"\$($BREW_BIN shellenv)\""

  if command -v brew >/dev/null 2>&1; then
    STATUS_BREW_ENV="완료"
    print_success "이제 이 세션에서 brew를 사용할 수 있습니다."
    print_success "이제 다른 세션에서도 brew를 사용할 수 있습니다."
  else
    print_line "환경 설정 후에도 brew 명령을 찾지 못했습니다."
    exit 1
  fi
}

step_install_packages() {
  print_step_header "개발 도구 설치"
  print_info "cmake, ninja, git 패키지를 설치하거나 최신 상태를 확인합니다."
  run_cmd brew install cmake ninja git
  STATUS_CMAKE="완료"
  STATUS_NINJA="완료"
  STATUS_GIT="완료"
  print_success "개발 도구 설치가 완료되었습니다."
}

step_install_vscode() {
  local code_bin=""

  print_step_header "VS Code 설치"

  if [ "$WANT_VSCODE" != "yes" ]; then
    STATUS_VSCODE="건너뜀"
    STATUS_VSCODE_EXT="건너뜀"
    print_info "VS Code 설치를 선택하지 않아 건너뜁니다."
    return
  fi

  if [ -d "/Applications/Visual Studio Code.app" ]; then
    STATUS_VSCODE="완료"
    print_success "VS Code가 이미 설치되어 있습니다."
  else
    print_info "Visual Studio Code를 설치합니다."
    run_cmd brew install --cask visual-studio-code
    STATUS_VSCODE="완료"
    print_success "VS Code 설치가 완료되었습니다."
  fi

  code_bin="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  if [ ! -x "$code_bin" ]; then
    STATUS_VSCODE_EXT="실패"
    print_line "VS Code CLI(code)를 찾지 못해 확장 설치를 완료하지 못했습니다."
    exit 1
  fi

  run_cmd "$code_bin" --install-extension ms-vscode.cpptools
  run_cmd "$code_bin" --install-extension ms-vscode.cmake-tools
  STATUS_VSCODE_EXT="완료"
  print_success "VS Code C/C++ 확장 설치가 완료되었습니다."
}

step_verify_tools() {
  print_step_header "설치 확인"
  run_cmd clang --version
  run_cmd cmake --version
  run_cmd ninja --version
  run_cmd git --version
  print_success "clang 실행이 확인되었습니다."
}

step_compile_tests() {
  print_step_header "컴파일 테스트"

  local temp_dir
  temp_dir="$(mktemp -d)"

  cat > "$temp_dir/hello.c" <<'EOF'
#include <stdio.h>

int main(void) {
    puts("hello from c");
    return 0;
}
EOF

  cat > "$temp_dir/hello.cpp" <<'EOF'
#include <iostream>

int main() {
    std::cout << "hello from cpp" << std::endl;
    return 0;
}
EOF

  run_cmd clang "$temp_dir/hello.c" -o "$temp_dir/hello_c"
  STATUS_C_TEST="완료"
  print_success "C 컴파일 테스트를 통과하였습니다."

  run_cmd clang++ "$temp_dir/hello.cpp" -o "$temp_dir/hello_cpp"
  STATUS_CPP_TEST="완료"
  print_success "C++ 컴파일 테스트를 통과하였습니다."

  run_cmd "$temp_dir/hello_c"
  run_cmd "$temp_dir/hello_cpp"

  rm -rf "$temp_dir"
}

step_finish() {
  print_step_header "설치 마무리"
  print_success "모든 작업이 끝났습니다."
  print_info "새 터미널 창에서도 brew가 바로 동작해야 합니다."
  print_summary
}

main() {
  step_intro
  step_check_system
  step_install_xcode_clt
  step_install_homebrew
  step_configure_brew_env
  step_install_packages
  step_install_vscode
  step_verify_tools
  step_compile_tests
  step_finish
}

main "$@"
