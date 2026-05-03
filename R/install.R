.ort_version <- "1.25.1"
.ort_version_short <- "1.25"
.ort_checksums <- list(
  "osx-arm64" = "18987ec3187b5f29ba798109750f6135060560ad4e0a52678fcc753ee8fb3091",
  "linux-aarch64" = "daa71b56b00c4ab34798a3d96ca41a32ece4d3e302dc2386d3cca83fd4491214",
  "linux-x64" = "eb566a49cfc49ef0642f809b69340b5bb656c7c4905ba873526d226f2c005816",
  "win-x64" = "33f2e8a63774811f99a5fc224cac32f4eed8c27643d46c6cc685319fa8f18019"
)

#' ort_detect_os
#'
#' @returns str - platform
#'
#' @examples ort_detect_os()
ort_detect_os <- function(){
  os_name <- Sys.info()[['sysname']]
  arch <- R.version$arch
  if (os_name == "Darwin"){
    # apple silicon vs x86
    if (grepl("aarch64|arm64", arch)) return ("osx-arm64")
    else return('osx-arm64')
  } else {
    stop("Unsupported platform")
  }
}

ort_install_dir <- function(){
  tools::R_user_dir("nativeORT", which="data")
}

ort_binary_url <- function(){
  os <- ort_detect_os()
  base <- "https://github.com/microsoft/onnxruntime/releases/download"
  glue::glue("{base}/v{.ort_version}/onnxruntime-{os}-{.ort_version}.tgz")
}

ort_is_installed <- function(){
  lib <- file.path(ort_install_dir(), "lib", "libonnxruntime.dylib")
  file.exists(lib)
}

ort_codesign <- function(lib_dir) {
  dylibs <- list.files(
    lib_dir,
    pattern = "\\.dylib$",
    full.names = TRUE
  )

  if (length(dylibs) == 0){
    warning("No .dylib files found!")
  }

  message("Signing libraries (macOS)...")
  for (lib in dylibs) {
    system2("xattr", c("-dr", "com.apple.quarantine", shQuote(lib)))
    system2("codesign", c("--force", "--deep", "--sign", "-", shQuote(lib)))
  }

  invisible(lib_dir)
}

ort_download <- function(url, dest_dir) {
  # download
  dir.create(dest_dir, recursive = TRUE, showWarnings= FALSE)
  tgz_path <- file.path(dest_dir, basename(url))

  message("Downloading ONNX Runtime ", .ort_version, "...")
  utils::download.file(url, tgz_path, mode='wb')

  #verify checksum
  message("Verifying download...")
  os <- ort_detect_os()
  expected_sum <- .ort_checksums[[os]]
  received_sum <- digest::digest(tgz_path, algo="sha256", file=TRUE)

  # if it fails
  if (!identical(expected_sum, received_sum)) {
    unlink(tgz_path)
    stop(
      "Checksum mismatch! Download my be corrupt, try again!"
    )
  }

  # now extract
  message("Checksum verified!")
  message("Extracting...")

  utils::untar(tgz_path, exdir=dest_dir)
  unlink(tgz_path)

  invisible(dest_dir)
}

ort_install <- function() {
  # prevent re-installation
  if (ort_is_installed()) {
    message("onnxruntime ", .ort_version, " is already installed.")
    return(invisible(ort_install_dir()))
  }

  # orchestrate download
  os <- ort_detect_os()
  url <- ort_binary_url()
  dest <- ort_install_dir()

  ort_download(url, dest)

  extracted <- file.path(dest, paste0("onnxruntime-", os, "-", .ort_version))
  file.copy(file.path(extracted, "include"), dest, recursive = TRUE)
  file.copy(file.path(extracted, "lib"), dest, recursive = TRUE)
  unlink(extracted, recursive = TRUE)

  # handle macOS signatures if needed
  if (os == 'osx-arm64') {
    ort_codesign(file.path(dest, "lib"))
  }

  message("onnxruntime ", .ort_version, " installed successfully!")
  message("location: ", dest)
  invisible(dest)

}
