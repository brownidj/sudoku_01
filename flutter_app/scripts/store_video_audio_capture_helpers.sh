#!/usr/bin/env bash

run_coreaudio_swift() {
  /usr/bin/swift -suppress-warnings - "$@" <<'EOF'
import AudioToolbox
import CoreAudio
import Foundation

enum DeviceRole: String {
  case input
  case output
  case systemOutput = "system"
}

func propertyAddress(
  selector: AudioObjectPropertySelector,
  scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal
) -> AudioObjectPropertyAddress {
  AudioObjectPropertyAddress(
    mSelector: selector,
    mScope: scope,
    mElement: kAudioObjectPropertyElementMain
  )
}

func deviceName(for id: AudioDeviceID) throws -> String {
  var name: CFString = "" as CFString
  var size = UInt32(MemoryLayout<CFString>.size)
  var address = propertyAddress(selector: kAudioObjectPropertyName)
  let status = AudioObjectGetPropertyData(id, &address, 0, nil, &size, &name)
  guard status == noErr else {
    throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
  }
  return name as String
}

func allDeviceIDs() throws -> [AudioDeviceID] {
  var address = propertyAddress(selector: kAudioHardwarePropertyDevices)
  var size: UInt32 = 0
  var status = AudioObjectGetPropertyDataSize(
    AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size
  )
  guard status == noErr else {
    throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
  }
  let count = Int(size) / MemoryLayout<AudioDeviceID>.size
  var ids = Array(repeating: AudioDeviceID(0), count: count)
  status = AudioObjectGetPropertyData(
    AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &ids
  )
  guard status == noErr else {
    throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
  }
  return ids
}

func selector(for role: DeviceRole) -> AudioObjectPropertySelector {
  switch role {
  case .input: return kAudioHardwarePropertyDefaultInputDevice
  case .output: return kAudioHardwarePropertyDefaultOutputDevice
  case .systemOutput: return kAudioHardwarePropertyDefaultSystemOutputDevice
  }
}

func getCurrentDeviceID(role: DeviceRole) throws -> AudioDeviceID {
  var address = propertyAddress(selector: selector(for: role))
  var id = AudioDeviceID(0)
  var size = UInt32(MemoryLayout<AudioDeviceID>.size)
  let status = AudioObjectGetPropertyData(
    AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &id
  )
  guard status == noErr else {
    throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
  }
  return id
}

func setCurrentDeviceID(role: DeviceRole, id: AudioDeviceID) throws {
  var address = propertyAddress(selector: selector(for: role))
  var mutableId = id
  let size = UInt32(MemoryLayout<AudioDeviceID>.size)
  let status = AudioObjectSetPropertyData(
    AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, size, &mutableId
  )
  guard status == noErr else {
    throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
  }
}

let command = CommandLine.arguments[1]

do {
  switch command {
  case "get":
    let role = DeviceRole(rawValue: CommandLine.arguments[2])!
    let id = try getCurrentDeviceID(role: role)
    print("\(id)\t\(try deviceName(for: id))")
  case "setByName":
    let role = DeviceRole(rawValue: CommandLine.arguments[2])!
    let name = CommandLine.arguments[3]
    guard let id = try allDeviceIDs().first(where: { try deviceName(for: $0) == name }) else {
      fputs("Audio device not found: \(name)\n", stderr)
      exit(1)
    }
    try setCurrentDeviceID(role: role, id: id)
  case "setByID":
    let role = DeviceRole(rawValue: CommandLine.arguments[2])!
    try setCurrentDeviceID(
      role: role,
      id: AudioDeviceID(UInt32(CommandLine.arguments[3])!)
    )
  default:
    fputs("Unsupported command: \(command)\n", stderr)
    exit(1)
  }
} catch {
  fputs("\(error)\n", stderr)
  exit(1)
}
EOF
}

get_current_audio_device() {
  run_coreaudio_swift get "$1"
}

set_audio_device_by_name() {
  run_coreaudio_swift setByName "$1" "$2"
}

set_audio_device_by_id() {
  run_coreaudio_swift setByID "$1" "$2"
}

audio_is_audible() {
  local audio_path="$1"
  local ffmpeg_bin="$2"
  local mean_volume
  local max_volume
  local analysis

  analysis="$("$ffmpeg_bin" -i "$audio_path" -af volumedetect -f null - 2>&1)"
  mean_volume="$(printf '%s\n' "$analysis" | sed -n 's/.*mean_volume: \([-0-9.]*\) dB/\1/p' | tail -n 1)"
  max_volume="$(printf '%s\n' "$analysis" | sed -n 's/.*max_volume: \([-0-9.]*\) dB/\1/p' | tail -n 1)"
  [[ -n "$mean_volume" && -n "$max_volume" ]] || return 1
  ! awk "BEGIN { exit !($max_volume <= -60.0) }"
}

extract_background_music_track() {
  sed -n 's/.*Background music track: \(audio\/[^[:space:]]*\).*/\1/p' "$1" |
    tail -n 1
}

extract_celebration_audio_track() {
  sed -n 's/.*SCREENSHOT_CELEBRATION_AUDIO:\(audio\/[^[:space:]]*\).*/\1/p' "$1" |
    tail -n 1
}

build_fallback_background_audio() {
  local track_asset="$1"
  local raw_video_path="$2"
  local output_path="$3"
  local root_dir="$4"
  local ffmpeg_bin="$5"
  local ffprobe_bin="$6"
  local asset_path="$root_dir/assets/$track_asset"
  local duration

  [[ -f "$asset_path" ]] || return 1
  duration="$("$ffprobe_bin" -v error -show_entries format=duration -of csv=p=0 "$raw_video_path")"
  [[ -n "$duration" ]] || return 1

  "$ffmpeg_bin" -y \
    -stream_loop -1 -i "$asset_path" \
    -t "$duration" \
    -af "volume=0.7" \
    -ac 2 -ar 48000 -c:a aac -b:a 192k \
    "$output_path" >/dev/null 2>&1
}

build_delayed_loop_audio() {
  local track_asset="$1"
  local raw_video_path="$2"
  local output_path="$3"
  local root_dir="$4"
  local ffmpeg_bin="$5"
  local ffprobe_bin="$6"
  local delay_seconds="$7"
  local asset_path="$root_dir/assets/$track_asset"
  local duration
  local active_duration

  [[ -f "$asset_path" ]] || return 1
  duration="$("$ffprobe_bin" -v error -show_entries format=duration -of csv=p=0 "$raw_video_path")"
  [[ -n "$duration" ]] || return 1
  active_duration="$(awk "BEGIN { print $duration - $delay_seconds }")"
  if awk "BEGIN { exit !($active_duration <= 0) }"; then
    "$ffmpeg_bin" -y \
      -f lavfi -t "$duration" -i "anullsrc=channel_layout=stereo:sample_rate=48000" \
      -c:a aac -b:a 192k "$output_path" >/dev/null 2>&1
    return 0
  fi

  "$ffmpeg_bin" -y \
    -stream_loop -1 -i "$asset_path" \
    -t "$active_duration" \
    -af "volume=0.9,adelay=${delay_seconds}s:all=true" \
    -ac 2 -ar 48000 -c:a aac -b:a 192k \
    "$output_path" >/dev/null 2>&1
}

wait_for_done_and_capture_delay() {
  local log_file="$1" done_marker="$2" celebration_marker="$3" timeout_seconds="$4"
  local start_ts loop_start now_ts delay=""
  start_ts="$(perl -MTime::HiRes=time -e 'printf "%.3f", time')"
  loop_start="$(date +%s)"
  while true; do
    if [[ -z "$delay" ]] && grep -Fq "$celebration_marker" "$log_file" 2>/dev/null; then
      now_ts="$(perl -MTime::HiRes=time -e 'printf "%.3f", time')"
      delay="$(awk "BEGIN { print $now_ts - $start_ts }")"
    fi
    grep -Fq "$done_marker" "$log_file" 2>/dev/null && break
    if (( $(date +%s) - loop_start > timeout_seconds )); then
      echo "Timed out waiting for $done_marker" >&2
      tail -n 120 "$log_file" >&2 || true
      return 1
    fi
    sleep 0.2
  done
  printf '%s\n' "$delay"
}
