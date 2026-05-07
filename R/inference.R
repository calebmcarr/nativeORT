#' ort_infer_raw
#'
#' @param session ORT session
#' @param input tensor to infer on
#'
#' @returns ORT output
#' @export
#'
#' @examples
#' \donttest{
#'   if (file.exists("model.onnx")) {
#'     session <- ort_session("model.onnx")
#'     input <- array(runif(1 * 3 * 256 * 256), dim = c(1L, 3L, 256L, 256L))
#'     ort_infer_raw(session, input)
#'   }
#' }
ort_infer_raw <- function(session, input){
  ort_run(
    session_ptr = session$ptr,
    input_array = as.numeric(input),
    input_shape = as.integer(dim(input)),
    input_name = session$input_names[1],
    output_name = session$output_names[1]
  )
}
