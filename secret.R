#!/usr/bin/env Rscript
library(base64enc)

create_key <- function(password, length) {
  # Create SHA256 hash of password
  key_hash <- digest::digest(
    password,
    algo = "sha256",
    serialize = FALSE,
    raw = TRUE
  )

  # Repeat key to match data length
  key <- rep(key_hash, length.out = length)
  return(key)
}

xor_data <- function(data, key) {
  # Convert raw to integer, XOR, then back to raw
  data_int <- as.integer(data)
  key_int <- as.integer(key)
  result_int <- bitwXor(data_int, key_int)
  result <- as.raw(result_int)
  return(result)
}

# Helper function to find pattern in raw bytes
find_pattern_in_raw <- function(data, pattern) {
  pattern_bytes <- charToRaw(pattern)
  pattern_len <- length(pattern_bytes)
  data_len <- length(data)

  if (pattern_len > data_len) {
    return(-1)
  }

  for (i in 1:(data_len - pattern_len + 1)) {
    if (all(data[i:(i + pattern_len - 1)] == pattern_bytes)) {
      return(i)
    }
  }
  return(-1)
}

decrypt_file <- function(
  input_file,
  output_file,
  password = askpass::askpass("Secret phrase")
) {
  tryCatch(
    {
      # Read and decode base64
      encoded <- readLines(input_file, warn = FALSE)
      encrypted <- base64decode(encoded)

      # Create key and decrypt
      key <- create_key(password, length(encrypted))
      decrypted <- xor_data(encrypted, key)

      # Find the boundary markers in raw bytes (avoid string conversion)
      start_pattern <- "REAL:"
      end_pattern <- ":REAL"

      start_pos <- find_pattern_in_raw(decrypted, start_pattern)
      if (start_pos == -1) {
        stop("Invalid decryption - start REAL: marker not found")
      }

      end_pos <- find_pattern_in_raw(decrypted, end_pattern)
      if (end_pos == -1) {
        stop("Invalid decryption - end :REAL marker not found")
      }

      # Extract the boundary section and convert only that part to string
      boundary_end_pos <- end_pos + nchar(end_pattern) - 1
      boundary_section <- decrypted[start_pos:boundary_end_pos]
      boundary_text <- rawToChar(boundary_section)

      # Parse: "REAL:1234:5678:REAL"
      parts <- strsplit(boundary_text, ":")[[1]]
      prefix_size <- as.integer(parts[2])
      real_data_size <- as.integer(parts[3])

      if (is.na(prefix_size) || is.na(real_data_size)) {
        stop("Invalid decryption - could not parse boundary information")
      }

      # Calculate positions
      boundary_info_size <- length(boundary_section)
      real_data_start <- boundary_info_size + prefix_size + 1
      real_data_end <- real_data_start + real_data_size - 1

      # Validate positions
      if (
        real_data_start > length(decrypted) || real_data_end > length(decrypted)
      ) {
        stop("Invalid decryption - boundary information points beyond file")
      }

      # Extract real data
      real_data <- decrypted[real_data_start:real_data_end]

      # Save decrypted file
      writeBin(real_data, output_file)
      cli::cli_inform(
        "Decryption successful! File saved to {.path {output_file}}."
      )
    },
    error = function(err) {
      cli::cli_abort(
        "Decryption failed. Please check your password and try again.",
        parent = err
      )
    }
  )
}
