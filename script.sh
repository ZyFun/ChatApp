#!/usr/bin/env zsh

xcodebuild clean test -workspace "TinkoffChat.xcworkspace" -scheme "TinkoffChat" -destination "platform=iOS Simulator,name=iPod touch (7th generation),OS=15.4"
