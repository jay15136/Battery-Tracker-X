/// Platform camera/webcam boundary. Cancellation is represented by `null`.
abstract interface class CameraService {
  Future<Uri?> capturePhoto();
}
