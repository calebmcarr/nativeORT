#include <Rcpp.h>
#include <onnxruntime_cxx_api.h>

// TODO: replace later
// [[Rcpp::export]]
std::string ort_version() {
  return std::string(OrtGetApiBase()->GetVersionString());
}
