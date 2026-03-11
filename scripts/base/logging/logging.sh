#!/usr/bin/env bash

################################################################################
# Logging Library
#
# Description:
#   Provides color-coded logging with levels, timestamps, and log rotation.
#   Source this file to use logging functions in your scripts.
#
# Usage:
#   source "$(dirname "$0")/logging/logging.sh"
#   log_info "Application started"
#   log_error "Something went wrong"
#
# Log Levels:
#   DEBUG, INFO, WARN, ERROR, CRITICAL
#
# Environment Variables:
#   LOG_LEVEL          - Minimum level to log (default: INFO)
#   LOG_DIR            - Directory for log files (default: ./logs)
#   LOG_MAX_SIZE       - Max size in bytes before rotation (default: 10485760)
#   LOG_RETENTION_DAYS - Days to keep old logs (default: 14)
################################################################################

# Color definitions
readonly LOG_COLOR_DEBUG='\033[0;36m'    # Cyan
readonly LOG_COLOR_INFO='\033[0;34m'     # Blue
readonly LOG_COLOR_WARN='\033[1;33m'     # Yellow
readonly LOG_COLOR_ERROR='\033[0;31m'    # Red
readonly LOG_COLOR_CRITICAL='\033[1;35m' # Magenta
readonly LOG_COLOR_RESET='\033[0m'

# Log level priority (using case statement instead of associative array for compatibility)
get_log_level_priority() {
    local level="$1"
    case "$level" in
        DEBUG) echo 0 ;;
        INFO) echo 1 ;;
        WARN) echo 2 ;;
        ERROR) echo 3 ;;
        CRITICAL) echo 4 ;;
        *) echo 1 ;;  # Default to INFO
    esac
}

# Configuration (with defaults)
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_DIR="${LOG_DIR:-./logs}"
LOG_MAX_SIZE="${LOG_MAX_SIZE:-10485760}"  # 10MB
LOG_RETENTION_DAYS="${LOG_RETENTION_DAYS:-14}"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Get current log file
get_log_file() {
    local script_name
    script_name="$(basename "$0" .sh)"
    echo "${LOG_DIR}/${script_name}.log"
}

# Check if log file needs rotation
rotate_log_if_needed() {
    local log_file="$1"
    
    if [[ ! -f "$log_file" ]]; then
        return 0
    fi
    
    local file_size
    file_size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file" 2>/dev/null || echo 0)
    
    if [[ "$file_size" -ge "$LOG_MAX_SIZE" ]]; then
        local timestamp
        timestamp=$(date +%Y%m%d_%H%M%S)
        mv "$log_file" "${log_file}.${timestamp}"
        log_info "Log rotated: ${log_file}.${timestamp}"
    fi
}

# Clean old log files
clean_old_logs() {
    find "$LOG_DIR" -name "*.log.*" -type f -mtime +"$LOG_RETENTION_DAYS" -delete 2>/dev/null || true
}

# Generic log function
_log() {
    local level="$1"
    local color="$2"
    shift 2
    local message="$*"
    
    # Check if we should log this level
    local current_priority
    current_priority=$(get_log_level_priority "$LOG_LEVEL")
    local message_priority
    message_priority=$(get_log_level_priority "$level")
    
    if [[ "$message_priority" -lt "$current_priority" ]]; then
        return 0
    fi
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local log_file
    log_file=$(get_log_file)
    
    # Rotate if needed
    rotate_log_if_needed "$log_file"
    
    # Console output (colored)
    echo -e "${color}[${level}]${LOG_COLOR_RESET} ${message}"
    
    # File output (no colors)
    echo "[${timestamp}] [${level}] ${message}" >> "$log_file"
    
    # Clean old logs periodically (only for ERROR and CRITICAL to avoid overhead)
    if [[ "$level" == "ERROR" ]] || [[ "$level" == "CRITICAL" ]]; then
        clean_old_logs
    fi
}

# Public logging functions
log_debug() {
    _log "DEBUG" "$LOG_COLOR_DEBUG" "$@"
}

log_info() {
    _log "INFO" "$LOG_COLOR_INFO" "$@"
}

log_warn() {
    _log "WARN" "$LOG_COLOR_WARN" "$@"
}

log_error() {
    _log "ERROR" "$LOG_COLOR_ERROR" "$@" >&2
}

log_critical() {
    _log "CRITICAL" "$LOG_COLOR_CRITICAL" "$@" >&2
}

# Export functions
export -f log_debug log_info log_warn log_error log_critical
