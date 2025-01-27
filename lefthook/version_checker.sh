#!/bin/sh

PROJECT_FLUTTER_VERSION=$(grep -m 1 flutter pubspec.yaml | sed 's/\ \ flutter: //')
RUNNING_FLUTTER_VERSION=$(flutter --version | grep -m 1 Flutter | grep -e '\d\.\d\.\d' -o)

echo "$PROJECT_FLUTTER_VERSION"
echo "$RUNNING_FLUTTER_VERSION"

if [ "$PROJECT_FLUTTER_VERSION" = "$RUNNING_FLUTTER_VERSION" ]; then
  exit 0;
else
  echo "  🔴 You're running the wrong Flutter version. This project requires flutter version ${PROJECT_FLUTTER_VERSION}. Quit"
  exit 1;
fi
