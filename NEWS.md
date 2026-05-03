# nativeORT 0.1.1

* Added Linux & Windows Support
* Native ONNX Runtime inference via Rcpp bindings to the ORT C API
* CPU and CoreML execution providers (for Apple Silicion users)
* `ort_install()` for automatic ORT binary download and setup
* `ort_session()`, `ort_infer_raw()`, `ort_infer()` for inference
* Benchmark vignette comparing CPU vs CoreML latency
