class ApiEndpoints {
  ApiEndpoints._();

  // Base
  static const String baseUrl = 'https://app.niletechdev.com';

  // Auth
  static const String login = '/api/login';
  static const String register = '/api/register';
  static const String logout = '/api/logout';
  static const String user = '/api/user';

  // Projects
  static const String projects = '/api/projects';
  static String projectById(int id) => '/api/projects/$id';

  // Project Landmarks
  static String projectLandmarks(int projectId) =>
      '/api/projects/$projectId/landmarks';
  static String projectLandmarkById(int projectId, int landmarkId) =>
      '/api/projects/$projectId/landmarks/$landmarkId';

  // Landmark Gallery
  static String landmarkGallery(int projectId, int landmarkId) =>
      '/api/projects/$projectId/landmarks/$landmarkId/gallery';
  static String landmarkGalleryCreate(int projectId, int landmarkId) =>
      '/api/projects/$projectId/landmarks/$landmarkId/gallery';
  static String landmarkGalleryItem(
    int projectId,
    int landmarkId,
    int itemId,
  ) => '/api/projects/$projectId/landmarks/$landmarkId/gallery/$itemId';
  static String landmarkGalleryUpdate(
    int projectId,
    int landmarkId,
    int itemId,
  ) => '/api/projects/$projectId/landmarks/$landmarkId/gallery/$itemId';
  static String landmarkGalleryAddImages(
    int projectId,
    int landmarkId,
    int itemId,
  ) => '/api/projects/$projectId/landmarks/$landmarkId/gallery/$itemId/images';
  static String landmarkGalleryDelete(
    int projectId,
    int landmarkId,
    int itemId,
  ) => '/api/projects/$projectId/landmarks/$landmarkId/gallery/$itemId';

  // Landmark Files
  static String landmarkFiles(int projectId, int landmarkId) =>
      '/api/projects/$projectId/landmarks/$landmarkId/files';
  static String landmarkFilesDownload(int projectId, int landmarkId) =>
      '/api/projects/$projectId/landmarks/$landmarkId/files/download';

  // Signature
  static const String signatureDetector = '/api/signature-detector';
  static const String signatureConfiguration = '/api/signature-configuration';
}
