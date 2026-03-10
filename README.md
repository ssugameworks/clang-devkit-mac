# clang-devkit-mac

macOS에서 `clang` C/C++ 개발 환경을 설치하고, VS Code에서 바로 실행 가능한 C++ 프로젝트를 빠르게 시작할 수 있게 도와주는 스크립트입니다.

포함된 스크립트:
## `install-clang.sh`
  - Xcode Command Line Tools 설치
  - Homebrew 설치
  - `brew shellenv` 설정
  - `cmake`, `ninja`, `git` 설치
  - VS Code 및 C/C++ 확장 설치 (선택)
  - C/C++ 컴파일 테스트

## `init-vscode.sh`
  - 새 C++ 프로젝트 폴더 생성
  - `.vscode/tasks.json` 생성
  - `.vscode/launch.json` 생성
  - `.vscode/extensions.json` 생성
  - VS Code에서 `F5`로 바로 실행 가능한 템플릿 구성

## 권장 확장

- [`ms-vscode.cpptools`](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
- [`ms-vscode.cmake-tools`](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools)
- [`vadimcn.vscode-lldb`](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb)
